Services:
seller contin
Buyer conainer
Mysql rds
Elasticache redis (valkey)

S3 bucket for storing images (private)
cloudfront

secretsmanager

ECR

ECS  cluster
Task definitions
Services

ALB
Target group

IAM

======================

Create Network:
-----------------------
vpc 
subnets 
public -3
private -3
IGW
Pub Route table- Assocaite pub subnets and add route to IGW

EC2
==============
Launched EC2 for docker image push to ECR
install docker package
install mysql-client 
########
# Enable MySQL repo
sudo dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm

# Install client only
sudo dnf install -y mysql-community-client

# Verify
mysql --version
#########


Security group - testing-server

create IAM role with "AmazonEC2ContainerRegistryFullAccess" and assign to EC2 to authenticate to ECR

Build docker images for seller and buyer by following ECR push commands and push to ECR


ECR
------------
create repos for seller and buyer


MYSQL
=============

mysql rds with minimal instance type and 20GB storage. Private db
Security group created - testing-rds-sg

allow 3306 from testing-server security group

create db- shopdb
tables - products and orders

with init.sql query


Elasticache
=============
valkey cache -serverless
use custom settings - vpc, sg (open port 6379 for ec2 sg)

install redis-cli - sudo dnf install -y redis6
redis6-cli --tls -h testingcache-kdszze.serverless.use1.cache.amazonaws.com -p 6379


S3 bucket
============
testingshop123 

Cloudfront
============
E17WLPB471QE20



ECS
=============
cluster creation
task definition -seller
- ecs task role - none
ecs task execution role -default (ecstaskexecutionrole)
service: 
selecred td and vpc private subnets
sg: testing-ecs-sg

	No NAT
service seller-service-xaq0vgxm was unable to place a task. Reason: ResourceInitializationError: unable to pull secrets or registry auth: unable to retrieve secret from asm: There is a connection issue between the task and AWS Secrets Manager. Check your task network configuration. failed to fetch secret arn:aws:secretsmanager:us-east-1:913524921896:secret:rds!db-a57bd929-5fa6-42c0-8024-fe8c94e49451 from secrets manager: operation error Secrets Manager: GetSecretValue, https response error StatusCode: 0, RequestID: , canceled, context deadline exceeded.

	No IAM
service seller-service-xaq0vgxm was unable to place a task. Reason: ResourceInitializationError: unable to pull secrets or registry auth: execution resource retrieval failed: unable to retrieve secret from asm: service call has been retried 1 time(s): failed to fetch secret arn:aws:secretsmanager:us-east-1:913524921896:secret:rds!db-a57bd929-5fa6-42c0-8024-fe8c94e49451 from secrets manager: operation error Secrets Manager: GetSecretValue, https response error StatusCode: 400, RequestID: 2bf6cb29-04f9-43d0-b8a4-f1247cbe8c0b, api error AccessDeniedException: User: arn:aws:sts::913524921896:assumed-role/ecsTaskExecutionRole/a20b735e9bbc41598825b6f0269f6fef is not authorized to perform: secretsmanager:GetSecretValue on resource: arn:aws:secretsmanager:us-east-1:913524921896:secret:rds!db-a57bd929-5fa6-42c0-8024-fe8c94e49451 because no identity-based policy allows the secretsmanager:GetSecretValue action.

========== ecstaskrole and  default (executionrolepolicy) + secret manager access
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:us-east-2:913524921896:secret:rds!db-0350df00-e558-4d43-8a3d-2c70968d3906-ZaeqeH"
        }
    ]
}
============
** No NAT to save costs **

Going with private endpoints
==========
create a sg vpce-ecr-sg
custom tcp 443 - 10.10.0.0/16
https to ecs sg

1️⃣ ENDPOINT 1: ecr.dkr
Service: com.amazonaws.us-east-1.ecr.dkr
Name: vpce-ecr-dkr-seller
Type: Gateway (Route Tables)

2️⃣ ENDPOINT 2: ecr.api  
Service: com.amazonaws.us-east-1.ecr.api
Name: vpce-ecr-api-seller
Type: Interface (Subnets + SG)

3️⃣ ENDPOINT 3: logs
Service: com.amazonaws.us-east-1.logs
Name: vpce-cloudwatchlogs-seller
Type: Interface (Subnets + SG)


4. com.amazonaws.us-east-1.secretsmanager → Interface  

5. s3 gateway endpoint (com.amazonaws.us-east-1.s3) add to Routetable private route

Allow ecs sg in rds sg for 3306 inbound


arn:aws:secretsmanager:us-east-1:913524921896:secret:rds!db-a57bd929-5fa6-42c0-8024-fe8c94e49451:username::
arn:aws:secretsmanager:us-east-1:913524921896:secret:rds!db-a57bd929-5fa6-42c0-8024-fe8c94e49451:password::


arn:aws:secretsmanager:us-east-2:913524921896:secret:rds!db-0350df00-e558-4d43-8a3d-2c70968d3906:username::
arn:aws:secretsmanager:us-east-2:913524921896:secret:rds!db-0350df00-e558-4d43-8a3d-2c70968d3906:password::

ECStaskrole permission for s3 bucket
=====================
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowS3ReadWritetestingshop123",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::testingshop123",
                "arn:aws:s3:::testingshop123/*"
            ]
        }
    ]
}


MYSQL:
mysql -h <rdd endpoint> -u shopuser 
password: retrive from secretmanager

Valkey:
GET cart:demo-buyer-123