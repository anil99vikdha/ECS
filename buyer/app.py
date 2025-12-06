from flask import Flask, request, render_template_string, session, jsonify
import mysql.connector
import redis
import os
import json

app = Flask(__name__)

secret_key = os.getenv('FLASK_SECRET_KEY')
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

USER_ID = os.getenv("USER_ID", "demo-buyer-123")

def get_db():
    return mysql.connector.connect(**db_config)

# Redis connection with timeout (FIXED SSL for ECS ElastiCache)
r = None  # global placeholder

def get_redis():
    global r
    if r is None:
        r = redis.Redis(
            host=os.getenv("REDIS_HOST"),
            port=int(os.getenv("REDIS_PORT", 6379)),
            db=0,
            decode_responses=True,
            ssl=True,
            ssl_cert_reqs=None,
            socket_connect_timeout=10,
            socket_timeout=10,
            retry_on_timeout=True
        )
        # Test connection
        try:
            r.ping()
            print("✅ Redis connection OK", flush=True)
        except Exception as e:
            print(f"❌ Redis connection failed: {e}", flush=True)
    return r

def get_cart():
    try:
        r = get_redis()
        cart_key = f"cart:{USER_ID}"
        cart_json = r.get(cart_key) or '{}'
        cart = json.loads(cart_json)
        # Ensure cart structure is valid
        for item_id in cart:
            if not isinstance(cart[item_id], dict):
                cart[item_id] = {'name': '', 'price': 0, 'qty': 0}
            elif 'qty' not in cart[item_id]:
                cart[item_id]['qty'] = 0
        return cart
    except Exception as e:
        print(f"❌ get_cart error: {e}", flush=True)
        return {}

def save_cart(cart):
    try:
        r = get_redis()
        cart_key = f"cart:{USER_ID}"
        r.setex(cart_key, 3600, json.dumps(cart))
        print(f"💾 Cart saved for {USER_ID}", flush=True)
    except Exception as e:
        print(f"❌ save_cart error: {e}", flush=True)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html><head><title>🛒 TrainXOps Shop</title>
<style>
body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;max-width:1200px;margin:50px auto;background:#f8fafc;padding:0;}
.header{background:linear-gradient(135deg,#2563eb,#1d4ed8);color:white;padding:2rem;text-align:center;border-radius:16px 16px 0 0;box-shadow:0 10px 25px rgba(37,99,235,0.3);}
.header h1{margin:0;font-size:2.5rem;font-weight:700;}
.header p{margin:0.5rem 0;font-size:1.1rem;opacity:0.95;}
.container{background:white;border-radius:0 0 16px 16px;overflow:hidden;box-shadow:0 10px 25px rgba(0,0,0,0.1);}
.products-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:24px;padding:2rem;}
.product-card{border:1px solid #e2e8f0;border-radius:12px;overflow:hidden;transition:all 0.3s;box-shadow:0 4px 6px rgba(0,0,0,0.05);}
.product-card:hover{transform:translateY(-8px);box-shadow:0 20px 40px rgba(0,0,0,0.15);}
.product-image{width:100%;height:220px;object-fit:cover;background:#f1f5f9;}
.product-info{padding:1.5rem;}
.product-name{font-size:1.25rem;font-weight:600;color:#1f2937;margin:0 0 0.5rem;line-height:1.3;}
.product-desc{color:#6b7280;margin:0 0 1rem;font-size:0.95rem;line-height:1.5;}
.price{font-size:1.5rem;font-weight:700;color:#059669;}
.add-to-cart{background:#10b981;color:white;border:none;padding:0.875rem 1.5rem;border-radius:8px;font-weight:600;cursor:pointer;width:100%;font-size:1rem;transition:all 0.2s;}
.add-to-cart:hover{background:#059669;transform:translateY(-1px);}
.add-to-cart:disabled{background:#9ca3af;cursor:not-allowed;transform:none;}
.cart-summary{position:fixed;top:20px;right:20px;background:white;padding:1.5rem;border-radius:12px;box-shadow:0 10px 25px rgba(0,0,0,0.15);min-width:320px;max-height:80vh;overflow-y:auto;}
.cart-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;}
.cart-item{display:flex;align-items:center;padding:1rem 0;border-bottom:1px solid #f1f5f9;}
.item-info{flex:1;}
.item-price{font-weight:600;color:#1f2937;}
.item-qty{font-size:0.875rem;color:#6b7280;}
.cart-total{margin-top:1rem;padding-top:1rem;border-top:2px solid #e2e8f0;}
.total-amount{font-size:1.25rem;font-weight:700;color:#059669;}
.empty-cart{text-align:center;color:#6b7280;font-style:italic;padding:2rem;}
.checkout-btn{background:#2563eb;color:white;border:none;padding:1rem;border-radius:8px;font-weight:600;cursor:pointer;width:100%;font-size:1rem;}
@media (max-width:768px){.cart-summary{position:relative;top:auto;right:auto;margin:2rem;width:100%;}}
</style></head>
<body>
<div class="header">
<h1>🛒 TrainXOps Shop</h1>
<p>Browse {{ products|length }} products from sellers</p>
</div>
<div class="container">
<div class="products-grid">
{% for p in products %}
<div class="product-card">
<img src="{{ p.image_url or 'https://via.placeholder.com/320x220/6b7280/ffffff?text=No+Image' }}" class="product-image" alt="{{ p.name }}" loading="lazy">
<div class="product-info">
<h3 class="product-name">{{ p.name }}</h3>
{% if p.description %}<p class="product-desc">{{ p.description[:100] }}{% if p.description|length > 100 %}...{% endif %}</p>{% endif %}
<div class="price">₹{{ "%.2f"|format(p.price) }}</div>
<button class="add-to-cart" onclick="addToCart({{ p.id }}, '{{ p.name|replace("'", "\\'") }}', {{ p.price }})">
🛒 Add to Cart
</button>
</div>
</div>
{% endfor %}
</div>
</div>

<div class="cart-summary" id="cartSummary">
<div class="cart-header">
<h3>🛍️ Shopping Cart</h3>
<button onclick="clearCart()" style="background:none;border:none;font-size:1.2rem;cursor:pointer;color:#6b7280;">✕</button>
</div>
<div id="cartItems"></div>
<div id="cartTotal" class="cart-total" style="display:none;">
<div class="total-amount">Total: ₹<span id="totalAmount">0</span></div>
<button class="checkout-btn" onclick="checkout()">✅ Complete Order</button>
</div>
</div>

<script>
let cart = {{ cart_json|safe }};
console.log('Initial cart:', cart);
updateCartDisplay();

function addToCart(id, name, price) {
    console.log(`Adding to cart: ID=${id}, Name=${name}, Price=${price}`);

    // FIXED: Safe cart item creation and qty handling
    if (!cart[id]) {
        cart[id] = {name: name, price: price, qty: 0};
    }
    if (typeof cart[id].qty !== 'number') {
        cart[id].qty = 0;
    }
    cart[id].qty += 1;

    console.log(`Cart updated:`, cart[id]);
    updateCartDisplay();

    // Save to backend with error handling
    fetch('/cart', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(cart)
    })
    .then(response => {
        console.log('✅ Cart saved to backend:', response.status);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
    })
    .catch(error => {
        console.error('❌ Failed to save cart:', error);
    });
}

function clearCart() {
    console.log('Clearing cart');
    cart = {};
    updateCartDisplay();
    fetch('/cart', {method: 'DELETE'})
    .then(response => console.log('🗑️ Cart cleared:', response.status))
    .catch(error => console.error('Clear cart failed:', error));
}

function updateCartDisplay() {
    const cartItems = document.getElementById('cartItems');
    const cartTotal = document.getElementById('cartTotal');
    const totalAmount = document.getElementById('totalAmount');

    cartItems.innerHTML = '';
    let total = 0;
    let itemCount = 0;

    // FIXED: Safe iteration with null checks
    for (let id in cart) {
        if (cart[id] && typeof cart[id].qty === 'number' && cart[id].qty > 0) {
            const itemTotal = cart[id].price * cart[id].qty;
            total += itemTotal;
            itemCount++;
            cartItems.innerHTML += `
                <div class="cart-item">
                    <div class="item-info">
                        <div class="item-price">${cart[id].name}</div>
                        <div class="item-qty">₹${cart[id].price.toFixed(2)} × ${cart[id].qty}</div>
                    </div>
                    <div>₹${itemTotal.toFixed(2)}</div>
                </div>
            `;
        }
    }

    if (itemCount > 0) {
        cartTotal.style.display = 'block';
        totalAmount.textContent = total.toFixed(2);
    } else {
        cartItems.innerHTML = '<div class="empty-cart">Your cart is empty<br><small>Add products to get started!</small></div>';
        cartTotal.style.display = 'none';
    }
}

function checkout() {
    if (Object.keys(cart).length === 0) {
        alert('🛒 Cart is empty!');
        return;
    }
    const total = parseFloat(document.getElementById('totalAmount').textContent);
    console.log('Checkout with total:', total);

    fetch('/checkout', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({cart: cart, total: total})
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            alert(`✅ Order #${data.order_id} placed successfully!\nTotal: ₹${total.toFixed(2)}\n\nThank you for shopping at TrainXOps! 🎉`);
            cart = {};
            updateCartDisplay();
        } else {
            alert('❌ Checkout failed: ' + (data.message || 'Please try again.'));
        }
    })
    .catch(error => {
        console.error('Checkout error:', error);
        alert('❌ Network error. Please try again.');
    });
}
</script>
"""

@app.route('/')
def index():
    print("DEBUG: entering index()", flush=True)
    try:
        conn = get_db()
        print("DEBUG: got DB connection", flush=True)
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT * FROM products ORDER BY created_at DESC LIMIT 20")
        products = cur.fetchall()
        cur.close()
        conn.close()
        print(f"DEBUG: fetched {len(products)} products", flush=True)
    except Exception as e:
        print(f"DEBUG: DB error in index(): {e}", flush=True)
        products = []

    print("DEBUG: before get_cart()", flush=True)
    cart = get_cart()
    print(f"DEBUG: after get_cart(), cart={cart}", flush=True)

    return render_template_string(HTML_TEMPLATE, products=products, cart_json=json.dumps(cart))

@app.route('/cart', methods=['POST'])
def update_cart():
    try:
        cart = request.get_json(silent=True)
        if isinstance(cart, str):
            cart = json.loads(cart)
        if not isinstance(cart, dict):
            cart = {}

        # Validate and clean cart data
        clean_cart = {}
        for item_id, item in cart.items():
            if isinstance(item, dict) and isinstance(item.get('price'), (int, float)):
                clean_cart[item_id] = {
                    'name': str(item.get('name', '')),
                    'price': float(item.get('price', 0)),
                    'qty': max(0, int(item.get('qty', 0)))
                }

        save_cart(clean_cart)
        item_count = len([item for item in clean_cart.values() if item.get('qty', 0) > 0])
        print(f"🛒 Redis cart updated: {item_count} items", flush=True)
        return jsonify({'status': 'ok'})
    except Exception as e:
        print(f"❌ update_cart error: {e}", flush=True)
        return jsonify({'status': 'error'}), 500

@app.route('/cart', methods=['DELETE'])
def clear_cart():
    try:
        get_redis()  # Ensure Redis is connected
        cart_key = f"cart:{USER_ID}"
        r.delete(cart_key)
        print(f"🗑️ Redis cart cleared for user {USER_ID}", flush=True)
        return jsonify({'status': 'ok'})
    except Exception as e:
        print(f"❌ clear_cart error: {e}", flush=True)
        return jsonify({'status': 'error'}), 500

@app.route('/checkout', methods=['POST'])
def checkout():
    try:
        order_data = request.json
        print(f"Received order data: {order_data}")
        conn = get_db()
        cur = conn.cursor()
        cur.execute("INSERT INTO orders (user_id, total, items) VALUES (%s, %s, %s)",
                    (USER_ID, order_data['total'], json.dumps(order_data['cart'])))
        conn.commit()
        order_id = cur.lastrowid
        cur.close()
        conn.close()
        print(f"✅ Order inserted with id {order_id}")
        return jsonify({'status': 'success', 'order_id': order_id})
    except Exception as e:
        print(f"❌ Error during checkout: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)), debug=True)