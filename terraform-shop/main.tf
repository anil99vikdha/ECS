# VPC module
module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source = "./modules/rds"
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_groups.rds_sg_id
}

module "cache" {
  source = "./modules/elasticache"
  private_subnet_ids = module.vpc.private_subnet_ids
  redis_sg_id = module.security_groups.redis_sg_id
}

module "vpc_endpoints" {
  source = "./modules/vpcendpoints"
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  private_route_table_ids = [module.vpc.route_table_private_id]
  vpc_endpoints_sg_id = module.security_groups.vpc_endpoints_sg_id
}

module "s3" {
  source = "./modules/s3"
}


module "cloudfront" {
  source = "./modules/cloudfront"
  s3_bucket_name = module.s3.bucket_name
  s3_bucket_arn = module.s3.bucket_arn
  s3_bucket_regional_domain_name = module.s3.bucket_regional_domain_name
}

module "iam" {
  source = "./modules/iam"
  s3_bucket = module.s3.bucket_name
  aws_region    = "us-east-1"
}

module "ecs" {
  source = "./modules/ecscluster"
}


#Run dbinit Task
resource "terraform_data" "run_db_init" {
  triggers_replace = {
    task_definition = module.task_definiton.dbinit_task_arn
    cluster_id      = module.ecs.cluster_id
    rds_endpoint    = module.rds.db_instance_endpoint
  }

  provisioner "local-exec" {
    interpreter = ["sh", "-c"]

    command = <<-EOT
      aws ecs run-task \
        --cluster ${module.ecs.cluster_id} \
        --task-definition ${module.task_definiton.dbinit_task_arn} \
        --launch-type FARGATE \
        --network-configuration '{
          "awsvpcConfiguration": {
            "subnets": ${jsonencode(module.vpc.private_subnet_ids)},
             "securityGroups": ["${module.security_groups.ecs_tasks_sg_id}"],
            "assignPublicIp": "DISABLED"
          }
        }' \
        --region us-east-1
    EOT
  }
}

locals {
  rds_endpoint_host = split(":", module.rds.db_instance_endpoint)[0]
}


module "task_definiton" {
  source = "./modules/task-definitions"
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn = module.iam.ecs_task_role_arn
  aws_region = "us-east-1"
  s3_bucket = module.s3.bucket_name
  rds_endpoint = local.rds_endpoint_host
  valkey_endpoint = module.cache.primary_endpoint_address
  cloudfront_domain_name = module.cloudfront.domain_name
  flask_secret_key = "trainxops-seller-secret-2025"
  mysql_username = module.rds.db_secret_key_username
  mysql_password = module.rds.db_secret_key_password
  mysql_database = "shopdb"
  buyer_image = "913524921896.dkr.ecr.us-east-1.amazonaws.com/testing/buyer:2.0"
  seller_image = "913524921896.dkr.ecr.us-east-1.amazonaws.com/testing/seller:3.0"
  dbinit_image = "913524921896.dkr.ecr.us-east-1.amazonaws.com/product/dbinit:5.0"

}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id = module.security_groups.alb_sg_id
}

module "ecs_service" {
  source = "./modules/ecs-services"
  cluster_id = module.ecs.cluster_id
  buyer_task_arn = module.task_definiton.buyer_task_arn
  seller_task_arn = module.task_definiton.seller_task_arn
  ecs_tasks_sg_id = [module.security_groups.ecs_tasks_sg_id, module.security_groups.vpc_endpoints_sg_id]
  private_subnet_ids = module.vpc.private_subnet_ids
  buyer_target_group_arn = module.alb.buyer_target_group_arn
  seller_target_group_arn = module.alb.seller_target_group_arn
  
  depends_on = [ module.alb ]
}

