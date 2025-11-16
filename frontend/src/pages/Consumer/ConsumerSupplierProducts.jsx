import React, { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import "./ConsumerSupplierProducts.css";

// Массив поставщиков
const dummySuppliers = [
  {
    id: 1,
    name: "Fresh Farm Products",
    category: "Vegetables & Fruits",
    location: "Almaty Region",
    rating: 4.8,
    description: "Premium quality fresh produce from local farms",
    image: "https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400"
  },
  {
    id: 2,
    name: "Premium Meat Supply",
    category: "Meat & Poultry",
    location: "Astana",
    rating: 4.5,
    description: "High quality meat and poultry products",
    image: "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400"
  }
];

// Массив продуктов
const dummyProducts = [
  { id: 1, supplierId: 1, name: "Fresh Tomatoes", category: "Vegetables", price: 750, unit: "kg", stock: 500, minOrder: 10, image: "https://images.unsplash.com/photo-1546470427-e26264be0b0d?w=400", description: "Fresh red tomatoes, locally grown" },
  { id: 2, supplierId: 1, name: "Organic Cucumbers", category: "Vegetables", price: 600, unit: "kg", stock: 300, minOrder: 5, image: "https://images.unsplash.com/photo-1568584711271-1a4b85d49c4f?w=400", description: "Crisp organic cucumbers" },
  { id: 3, supplierId: 2, name: "Beef Steak", category: "Meat", price: 2500, unit: "kg", stock: 200, minOrder: 5, image: "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400", description: "Premium beef steak" },
  { id: 4, supplierId: 2, name: "Chicken Breast", category: "Meat", price: 1500, unit: "kg", stock: 300, minOrder: 5, image: "https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400", description: "Fresh chicken breast" }
];

export default function ConsumerSupplierProducts() {
  const { supplierId } = useParams();
  const navigate = useNavigate();
  const [cart, setCart] = useState([]);
  const [quantities, setQuantities] = useState({});
  const [searchQuery, setSearchQuery] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("all");

  // Найти поставщика по id
  const supplier = dummySuppliers.find(s => s.id === parseInt(supplierId));
  if (!supplier) return <div>Supplier not found</div>;

  // Продукты этого поставщика
  const productsForSupplier = dummyProducts.filter(p => p.supplierId === supplier.id);

  const handleQuantityChange = (productId, value) => {
    const quantity = parseInt(value) || 0;
    setQuantities({ ...quantities, [productId]: quantity });
  };

  const addToCart = (product) => {
    const quantity = quantities[product.id] || product.minOrder;

    if (quantity < product.minOrder) {
      alert(`Minimum order quantity is ${product.minOrder} ${product.unit}`);
      return;
    }

    if (quantity > product.stock) {
      alert(`Only ${product.stock} ${product.unit} available in stock`);
      return;
    }

    const existingItem = cart.find(item => item.id === product.id);

    if (existingItem) {
      setCart(cart.map(item =>
        item.id === product.id ? { ...item, quantity: item.quantity + quantity } : item
      ));
    } else {
      setCart([...cart, { ...product, quantity }]);
    }

    setQuantities({ ...quantities, [product.id]: product.minOrder });
    alert(`Added ${quantity} ${product.unit} of ${product.name} to cart`);
  };

  const removeFromCart = (productId) => {
    setCart(cart.filter(item => item.id !== productId));
  };

  const updateCartQuantity = (productId, newQuantity) => {
    const product = productsForSupplier.find(p => p.id === productId);
    if (!product) return;

    if (newQuantity < product.minOrder) {
      alert(`Minimum order quantity is ${product.minOrder} ${product.unit}`);
      return;
    }

    if (newQuantity > product.stock) {
      alert(`Only ${product.stock} ${product.unit} available`);
      return;
    }

    setCart(cart.map(item =>
      item.id === productId ? { ...item, quantity: newQuantity } : item
    ));
  };

  const getTotalAmount = () => cart.reduce((total, item) => total + item.price * item.quantity, 0);

  const handleCheckout = () => {
    if (cart.length === 0) {
      alert("Your cart is empty");
      return;
    }
    alert(`Order total: ${getTotalAmount().toLocaleString()} ₸\nOrder will be sent to supplier for approval.`);
    navigate("/consumer/orders");
  };

  const filteredProducts = productsForSupplier.filter(product => {
    const matchesSearch = product.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = categoryFilter === "all" || product.category === categoryFilter;
    return matchesSearch && matchesCategory;
  });

  const categories = ["all", ...new Set(productsForSupplier.map(p => p.category))];

  return (
    <div className="supplier-products-container">
      {/* Supplier Header */}
      <div className="supplier-header-card">
        <img src={supplier.image} alt={supplier.name} className="supplier-header-image" />
        <div className="supplier-header-info">
          <h1>{supplier.name}</h1>
          <p className="supplier-category">{supplier.category}</p>
          <p className="supplier-location">📍 {supplier.location}</p>
          <p className="supplier-description">{supplier.description}</p>
          <div className="supplier-rating">⭐ {supplier.rating}</div>
        </div>
      </div>

      {/* Filters */}
      <div className="products-filters">
        <input
          type="text"
          placeholder="Search products..."
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          className="search-input"
        />
        <select
          value={categoryFilter}
          onChange={e => setCategoryFilter(e.target.value)}
          className="category-filter"
        >
          {categories.map(cat => (
            <option key={cat} value={cat}>{cat === "all" ? "All Categories" : cat}</option>
          ))}
        </select>
      </div>

      {/* Products Grid */}
      <div className="products-grid">
        {filteredProducts.map(product => {
          const inCart = cart.find(item => item.id === product.id);
          const currentQty = quantities[product.id] || product.minOrder;

          return (
            <div key={product.id} className="product-card">
              <div className="product-image-wrapper">
                <img src={product.image} alt={product.name} className="product-image" />
                {product.stock < 50 && <span className="low-stock-badge">Low Stock</span>}
              </div>

              <div className="product-info">
                <h3 className="product-name">{product.name}</h3>
                <p className="product-description">{product.description}</p>
                <div className="product-details">
                  <div className="product-price">{product.price} ₸/{product.unit}</div>
                  <div className="product-stock">Stock: {product.stock} {product.unit}</div>
                </div>
                <div className="product-min-order">Min. Order: {product.minOrder} {product.unit}</div>
                <div className="product-actions">
                  <div className="quantity-control">
                    <button onClick={() => handleQuantityChange(product.id, currentQty - 1)} disabled={currentQty <= product.minOrder}>−</button>
                    <input type="number" value={currentQty} onChange={e => handleQuantityChange(product.id, e.target.value)} min={product.minOrder} max={product.stock} />
                    <button onClick={() => handleQuantityChange(product.id, currentQty + 1)} disabled={currentQty >= product.stock}>+</button>
                  </div>
                  <button className="add-to-cart-btn" onClick={() => addToCart(product)} disabled={product.stock === 0}>
                    {product.stock === 0 ? "Out of Stock" : "Add to Cart"}
                  </button>
                </div>
                {inCart && <div className="in-cart-indicator">✓ In Cart: {inCart.quantity} {product.unit}</div>}
              </div>
            </div>
          );
        })}
      </div>

      {filteredProducts.length === 0 && <div className="no-products"><p>No products found</p></div>}

      {/* Floating Cart */}
      {cart.length > 0 && (
        <div className="floating-cart">
          <div className="cart-header">
            <h3>Cart ({cart.length} items)</h3>
            <button className="close-cart-btn" onClick={() => setCart([])}>Clear All</button>
          </div>

          <div className="cart-items">
            {cart.map(item => (
              <div key={item.id} className="cart-item">
                <img src={item.image} alt={item.name} className="cart-item-image" />
                <div className="cart-item-info">
                  <h4>{item.name}</h4>
                  <p>{item.price} ₸/{item.unit}</p>
                </div>
                <div className="cart-item-quantity">
                  <button onClick={() => updateCartQuantity(item.id, item.quantity - 1)}>−</button>
                  <span>{item.quantity}</span>
                  <button onClick={() => updateCartQuantity(item.id, item.quantity + 1)}>+</button>
                </div>
                <div className="cart-item-total">{(item.price * item.quantity).toLocaleString()} ₸</div>
                <button className="remove-item-btn" onClick={() => removeFromCart(item.id)}>✕</button>
              </div>
            ))}
          </div>

          <div className="cart-footer">
            <div className="cart-total"><span>Total:</span><strong>{getTotalAmount().toLocaleString()} ₸</strong></div>
            <button className="checkout-btn" onClick={handleCheckout}>Place Order</button>
          </div>
        </div>
      )}
    </div>
  );
}
