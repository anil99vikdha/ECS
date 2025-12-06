from flask import Flask, request, render_template_string, redirect, url_for, session
import mysql.connector
import os
import uuid
import boto3
import botocore

app = Flask(__name__)

# Secret key
secret_key = os.getenv("FLASK_SECRET_KEY")
if not secret_key:
    raise RuntimeError("FLASK_SECRET_KEY environment variable not set")
app.secret_key = secret_key

# MySQL config
db_config = {
    "host": os.getenv("MYSQL_HOST"),
    "user": os.getenv("MYSQL_USER"),
    "password": os.getenv("MYSQL_PASSWORD"),
    "database": os.getenv("MYSQL_DATABASE"),
}

def get_db():
    return mysql.connector.connect(**db_config)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html><head><title>Seller Dashboard</title>
<style>
body{font-family:Arial;max-width:900px;margin:50px auto;padding:20px;background:#f5f5f5;}
.container{background:white;padding:30px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.1);}
h1{color:#2563eb;text-align:center;}
.form-group{margin-bottom:20px;}
label{display:block;margin-bottom:8px;font-weight:600;}
input,textarea{width:100%;padding:12px;border:2px solid #e5e7eb;border-radius:8px;box-sizing:border-box;}
input[type="file"]{padding:10px;}
button{background:#2563eb;color:white;padding:14px 32px;border:none;border-radius:8px;font-size:16px;cursor:pointer;width:100%;}
.products-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:20px;margin-top:30px;}
.product-card{border:1px solid #e5e7eb;border-radius:12px;padding:20px;}
.product-image{width:100%;height:150px;object-fit:cover;border-radius:8px;margin-bottom:10px;background:#f3f4f6;display:flex;align-items:center;justify-content:center;color:#6b7280;font-size:14px;}
.product-no-image{width:100%;height:150px;background:#f3f4f6;border-radius:8px;margin-bottom:10px;display:flex;align-items:center;justify-content:center;color:#6b7280;font-size:14px;}
.success-msg{background:#d1fae5;color:#065f46;padding:15px;border-radius:8px;margin:20px 0;}
.error-msg{background:#fee2e2;color:#991b1b;padding:15px;border-radius:8px;margin:20px 0;}
</style></head>
<body>
<div class="container">
<h1>📦 TrainXOps Seller Dashboard</h1>

{% if success_msg %}
<div class="success-msg">{{ success_msg }}</div>
{% endif %}

<form method="POST" enctype="multipart/form-data">
  <div class="form-group"><label>Product Name *</label><input type="text" name="name" required></div>
  <div class="form-group"><label>Description</label><textarea name="description" rows="3"></textarea></div>
  <div class="form-group"><label>Price (₹) *</label><input type="number" name="price" step="0.01" required min="0"></div>
  <div class="form-group"><label>Product Image</label><input type="file" name="image" accept="image/*"></div>
  <button type="submit">🚀 Add Product to Store</button>
</form>

<h2>Your Products ({{ products|length }})</h2>
<div class="products-grid">
{% for p in products %}
  <div class="product-card">
    {% if p.image_url %}
      <img src="{{ p.image_url }}" class="product-image" alt="Product Image"
           onerror="this.style.display='none'; this.parentNode.querySelector('.product-no-image')?.style.display='flex';">
      <div class="product-no-image" style="display: none;">No Image Available</div>
    {% else %}
      <div class="product-no-image">No Image</div>
    {% endif %}
    <h3>{{ p.name }}</h3>
    {% if p.description %}
      <p>{{ p.description[:60] }}{% if p.description|length > 60 %}...{% endif %}</p>
    {% endif %}
    <p><strong>₹{{ "%.2f"|format(p.price) }}</strong></p>
    <small>{{ p.created_at.strftime('%d %b %Y %H:%M') }}</small>
  </div>
{% endfor %}
</div>
</div>
</body></html>
"""

@app.route("/", methods=["GET", "POST"])
def dashboard():
    success_msg = session.pop("success_msg", None)

    if request.method == "POST":
        name = request.form["name"].strip()
        description = request.form.get("description", "").strip()
        price = float(request.form["price"])
        image = request.files.get("image")

        image_url = None

        # S3 upload with CloudFront URL
        if image and image.filename:
            try:
                print(f"📤 Uploading {image.filename} ({image.content_type})...")

                s3 = boto3.client(
                    "s3",
                    region_name="us-east-1",
                    config=botocore.config.Config(
                        region_name="us-east-1",
                        signature_version="s3v4",
                        s3={"addressing_style": "path"},
                    ),
                )

                bucket = os.environ.get("S3_BUCKET")
                cf_domain = os.environ.get("CLOUDFRONT_DOMAIN", "")  # dxxxxx.cloudfront.net

                ext = os.path.splitext(image.filename)[1][:5]
                key = f"products/{uuid.uuid4().hex[:8]}{ext}"

                print(f"📤 Bucket: {bucket}, Key: {key}")

                s3.upload_fileobj(
                    image,
                    bucket,
                    key,
                    ExtraArgs={
                        "ContentType": image.content_type or "image/jpeg",
                        "CacheControl": "max-age=31536000",
                    },
                )

                if cf_domain:
                    image_url = f"https://{cf_domain}/{key}"
                else:
                    image_url = f"https://{bucket}.s3.us-east-1.amazonaws.com/{key}"

                print(f"✅ Image URL: {image_url}")
                success_msg = f"✅ Product '{name}' added with image!"

            except Exception as e:
                print(f"❌ S3 FAILED: {e}")
                image_url = None  # Don't set fallback URL, let it show "No Image"
                success_msg = f"✅ Product '{name}' added (S3 failed: {str(e)[:40]}...)"
        else:
            success_msg = f"✅ Product '{name}' added successfully!"

        # Save to MySQL
        try:
            conn = get_db()
            cur = conn.cursor()
            cur.execute(
                "INSERT INTO products (name, description, price, image_url) "
                "VALUES (%s, %s, %s, %s)",
                (name, description, price, image_url),
            )
            conn.commit()
            cur.close()
            conn.close()
        except Exception as db_error:
            print(f"❌ DB Error: {db_error}")
            success_msg = f"❌ Database error: {str(db_error)[:50]}"

        session["success_msg"] = success_msg
        return redirect(url_for("dashboard"))

    # GET: list products
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT * FROM products ORDER BY created_at DESC LIMIT 50")
        products = cur.fetchall()
        cur.close()
        conn.close()
    except Exception as e:
        print(f"❌ Error fetching products: {e}")
        products = []

    return render_template_string(HTML_TEMPLATE, products=products, success_msg=success_msg)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)), debug=True)