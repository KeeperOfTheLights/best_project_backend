import React, { useEffect, useMemo, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import "./ConsumerSupplierProducts.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function ConsumerSupplierProducts() {
  const { supplierId } = useParams();
  const navigate = useNavigate();
  const { token, logout, loading: authLoading } = useAuth();

  const [supplier, setSupplier] = useState(null);
  const [products, setProducts] = useState([]);
  const [quantities, setQuantities] = useState({});
  const [searchQuery, setSearchQuery] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("all");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [cartItems, setCartItems] = useState([]);
  const [cartLoading, setCartLoading] = useState(false);
  const [cartActionLoading, setCartActionLoading] = useState("");
  const [cartMessage, setCartMessage] = useState("");
  const [cartError, setCartError] = useState("");
  const [checkoutLoading, setCheckoutLoading] = useState(false);

  const supplierNumericId = Number(supplierId);

  const parseErrorResponse = async (response) => {
    const text = await response.text();
    if (!text) return "Request failed";
    try {
      const payload = JSON.parse(text);
      return payload.detail || payload.message || payload.error || "Request failed";
    } catch {
      return text;
    }
  };

  const ensureAuth = () => {
    if (authLoading) return false;
    if (!token) {
      logout();
      navigate("/login");
      return false;
    }
    return true;
  };

  const fetchCart = async () => {
    if (!ensureAuth()) return;
    setCartLoading(true);
    setCartError("");
    try {
      const res = await fetch(`${API_BASE}/cart/`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }
      if (!res.ok) throw new Error(await parseErrorResponse(res));
      const data = await res.json();
      setCartItems(Array.isArray(data) ? data : []);
    } catch (err) {
      setCartItems([]);
      setCartError(err.message || "Failed to load cart");
    } finally {
      setCartLoading(false);
    }
  };

  const initializeQuantities = (items) => {
    const map = {};
    items.forEach((product) => {
      map[product.id] = product.minOrder || 1;
    });
    setQuantities(map);
  };

  const fetchSupplierData = async () => {
    if (!ensureAuth()) return;
    setLoading(true);
    setError("");
    try {
      const [supplierRes, catalogRes] = await Promise.all([
        fetch(`${API_BASE}/suppliers/`, { headers: { Authorization: `Bearer ${token}` } }),
        fetch(`${API_BASE}/supplier/${supplierNumericId}/catalog/`, {
          headers: { Authorization: `Bearer ${token}` },
        }),
      ]);

      if (supplierRes.status === 401 || catalogRes.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (supplierRes.ok) {
        const suppliers = await supplierRes.json();
        const match = suppliers.find((s) => Number(s.id) === supplierNumericId);
        setSupplier(match || null);
      } else {
        throw new Error("Failed to load supplier info");
      }

      if (catalogRes.status === 403) {
        setError("You are not linked with this supplier yet.");
        setProducts([]);
        return;
      }

      if (!catalogRes.ok) {
        throw new Error(await parseErrorResponse(catalogRes));
      }

      const catalog = await catalogRes.json();
      const normalized = Array.isArray(catalog) ? catalog : [];
      setProducts(normalized);
      initializeQuantities(normalized);
    } catch (err) {
      setError(err.message || "Failed to load supplier catalog");
      setProducts([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!supplierId) return;
    fetchSupplierData();
    fetchCart();
  }, [supplierId, token]);

  const supplierCartItems = useMemo(
    () =>
      cartItems.filter((item) => Number(item.product_supplier_id) === supplierNumericId),
    [cartItems, supplierNumericId]
  );

  const categories = useMemo(() => {
    const set = new Set();
    products.forEach((p) => {
      if (p.category) set.add(p.category);
    });
    return ["all", ...Array.from(set)];
  }, [products]);

  const filteredProducts = products.filter((product) => {
    const matchesSearch = product.name ?.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = categoryFilter === "all" || product.category === categoryFilter;
    return matchesSearch && matchesCategory;
  });

  const handleQuantityChange = (productId, value, minOrder = 1, stock = Infinity) => {
    let next = Number(value);
    if (Number.isNaN(next)) next = minOrder;
    next = Math.max(minOrder, Math.min(stock, next));
    setQuantities((prev) => ({ ...prev, [productId]: next }));
  };

  const handleAddToCart = async (product) => {
    const quantity = quantities[product.id] || product.minOrder || 1;
    setCartActionLoading(`add-${product.id}`);
    setCartMessage("");
    setCartError("");
    try {
      const res = await fetch(`${API_BASE}/cart/add/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ product_id: product.id, quantity }),
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) throw new Error(await parseErrorResponse(res));
      await fetchCart();
      setCartMessage(`Added ${quantity} ${product.unit || ""} of ${product.name} to cart.`);
    } catch (err) {
      setCartError(err.message || "Failed to add to cart");
    } finally {
      setCartActionLoading("");
    }
  };

  const handleUpdateCartItem = async (itemId, quantity) => {
    setCartActionLoading(`update-${itemId}`);
    setCartError("");
    setCartMessage("");
    try {
      const res = await fetch(`${API_BASE}/cart/${itemId}/`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ quantity }),
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) throw new Error(await parseErrorResponse(res));
      await fetchCart();
    } catch (err) {
      setCartError(err.message || "Failed to update cart");
    } finally {
      setCartActionLoading("");
    }
  };

  const handleRemoveCartItem = async (itemId) => {
    setCartActionLoading(`remove-${itemId}`);
    setCartError("");
    setCartMessage("");
    try {
      const res = await fetch(`${API_BASE}/cart/${itemId}/`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${token}` },
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) throw new Error(await parseErrorResponse(res));
      await fetchCart();
    } catch (err) {
      setCartError(err.message || "Failed to remove item");
    } finally {
      setCartActionLoading("");
    }
  };

  const handleCheckout = async () => {
    if (!supplierCartItems.length) {
      setCartError("Add items from this supplier before checking out.");
      return;
    }

    setCheckoutLoading(true);
    setCartError("");
    setCartMessage("");

    try {
      const res = await fetch(`${API_BASE}/orders/checkout/`, {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) throw new Error(await parseErrorResponse(res));
      const data = await res.json();
      setCartMessage(`Order #${data.id} placed successfully.`);
      await fetchCart();
      navigate("/ConsumerOrders");
    } catch (err) {
      setCartError(err.message || "Checkout failed");
    } finally {
      setCheckoutLoading(false);
    }
  };

  const formatCurrency = (value) => `${Number(value || 0).toLocaleString()} ₸`;

  const cartTotalAmount = supplierCartItems.reduce((total, item) => {
    const line = Number(item.line_total);
    if (!Number.isNaN(line) && line > 0) return total + line;
    return total + Number(item.product_price || 0) * Number(item.quantity || 0);
  }, 0);

  if (loading) {
    return <div className="supplier-products-container"><p>Loading supplier products...</p></div>;
  }

  if (error) {
    return (
      <div className="supplier-products-container">
        <div className="error-state">{error}</div>
      </div>
    );
  }

  return (
    <div className="supplier-products-container">
      <div className="supplier-header-card">
        <div className="supplier-header-image placeholder-image">
          {supplier?.supplier_company?.[0] || supplier?.full_name?.[0] || "S"}
        </div>
        <div className="supplier-header-info">
          <h1>{supplier?.full_name || "Supplier"}</h1>
          <p className="supplier-category">{supplier?.supplier_company || "Private Supplier"}</p>
          <p className="supplier-location">📧 {supplier?.email}</p>
          <p className="supplier-description">
            Products available for wholesale ordering. Linked suppliers only.
          </p>
        </div>
      </div>

      <div className="products-filters">
        <input
          type="text"
          placeholder="Search products..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="search-input"
        />
        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          className="category-filter"
        >
          {categories.map((cat) => (
            <option key={cat} value={cat}>
              {cat === "all" ? "All Categories" : cat}
            </option>
          ))}
        </select>
      </div>

      <div className="products-grid">
        {filteredProducts.map((product) => {
          const inCart = supplierCartItems.find((item) => item.product === product.id);
          const currentQty = quantities[product.id] || product.minOrder || 1;

          return (
            <div key={product.id} className="product-card">
              <div className="product-image-wrapper">
                {product.image ? (
                  <img src={product.image} alt={product.name} className="product-image" />
                ) : (
                  <div className="product-image product-placeholder">{product.name[0]}</div>
                )}
                {product.stock < 50 && <span className="low-stock-badge">Low Stock</span>}
              </div>

              <div className="product-info">
                <h3 className="product-name">{product.name}</h3>
                <p className="product-description">{product.description || "No description"}</p>
                <div className="product-details">
                  <div className="product-price">
                    {product.discounted_price && product.discount > 0 ? (
                      <>
                        <span style={{ textDecoration: "line-through", color: "#999", marginRight: "8px" }}>
                          {formatCurrency(product.price)}
                        </span>
                        <span style={{ color: "#e74c3c", fontWeight: "bold" }}>
                          {formatCurrency(product.discounted_price)}
                        </span>
                        <span style={{ color: "#e74c3c", marginLeft: "8px", fontSize: "0.9rem" }}>
                          ({product.discount}% off)
                        </span>
                      </>
                    ) : (
                      formatCurrency(product.price)
                    )} / {product.unit}
                  </div>
                  <div className="product-stock">
                    Stock: {product.stock} {product.unit}
                  </div>
                </div>
                <div className="product-min-order">
                  Min. Order: {product.minOrder} {product.unit}
                </div>
                {product.delivery_option && (
                  <div className="product-delivery">
                    {product.delivery_option === "delivery" && "🚚 Delivery"}
                    {product.delivery_option === "pickup" && "📦 Pickup"}
                    {product.delivery_option === "both" && "🚚📦 Delivery & Pickup"}
                  </div>
                )}
                {product.lead_time_days > 0 && (
                  <div className="product-lead-time">
                    ⏱️ Lead Time: {product.lead_time_days} {product.lead_time_days === 1 ? "day" : "days"}
                  </div>
                )}
                <div className="product-actions">
                  <div className="quantity-control">
                    <button
                      onClick={() => handleQuantityChange(product.id, currentQty - 1, product.minOrder, product.stock)}
                      disabled={currentQty <= (product.minOrder || 1)}
                    >
                      −
                    </button>
                    <input
                      type="number"
                      value={currentQty}
                      onChange={(e) =>
                        handleQuantityChange(
                          product.id,
                          e.target.value,
                          product.minOrder,
                          product.stock
                        )
                      }
                      min={product.minOrder}
                      max={product.stock}
                    />
                    <button
                      onClick={() =>
                        handleQuantityChange(
                          product.id,
                          currentQty + 1,
                          product.minOrder,
                          product.stock
                        )
                      }
                      disabled={currentQty >= product.stock}
                    >
                      +
                    </button>
                  </div>
                  <button
                    className="add-to-cart-btn"
                    onClick={() => handleAddToCart(product)}
                    disabled={product.stock === 0 || cartActionLoading === `add-${product.id}`}
                  >
                    {product.stock === 0
                      ? "Out of Stock"
                      : cartActionLoading === `add-${product.id}`
                        ? "Adding..."
                        : "Add to Cart"}
                  </button>
                </div>
                {inCart && (
                  <div className="in-cart-indicator">
                    ✓ In Cart: {inCart.quantity} {product.unit}
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>

      {filteredProducts.length === 0 && (
        <div className="no-products">
          <p>No products found</p>
        </div>
      )}

      <div className="floating-cart">
        <div className="cart-header">
          <h3>Cart ({supplierCartItems.length} items)</h3>
          {cartLoading && <span className="cart-loading">Refreshing...</span>}
        </div>

        {cartError && <div className="catalog-inline-alert error">{cartError}</div>}
        {cartMessage && <div className="catalog-inline-alert success">{cartMessage}</div>}

        {supplierCartItems.length === 0 ? (
          <p className="cart-empty">No items from this supplier yet.</p>
        ) : (
          <>
            <div className="cart-items">
              {supplierCartItems.map((item) => (
                <div key={item.id} className="cart-item">
                  {item.product_image && (
                    <img src={item.product_image} alt={item.product_name} className="cart-item-image" />
                  )}
                  <div className="cart-item-info">
                    <h4>{item.product_name}</h4>
                    <p>
                      {item.product_discounted_price && item.product_discount > 0 ? (
                        <>
                          <span style={{ textDecoration: "line-through", color: "#999", marginRight: "8px", fontSize: "0.9rem" }}>
                            {formatCurrency(item.product_price)}
                          </span>
                          <span style={{ color: "#e74c3c", fontWeight: "bold" }}>
                            {formatCurrency(item.product_discounted_price)}
                          </span>
                        </>
                      ) : (
                        formatCurrency(item.product_price)
                      )}
                    </p>
                  </div>
                  <div className="cart-item-quantity">
                    <button
                      onClick={() => handleUpdateCartItem(item.id, item.quantity - 1)}
                      disabled={
                        cartActionLoading === `update-${item.id}` ||
                        item.quantity <= (item.product_min_order || 1)
                      }
                    >
                      −
                    </button>
                    <span>{item.quantity}</span>
                    <button
                      onClick={() => handleUpdateCartItem(item.id, item.quantity + 1)}
                      disabled={
                        cartActionLoading === `update-${item.id}` ||
                        item.quantity >= (item.product_stock || item.quantity)
                      }
                    >
                      +
                    </button>
                  </div>
                  <div className="cart-item-total">{formatCurrency(item.line_total)}</div>
                  <button
                    className="remove-item-btn"
                    onClick={() => handleRemoveCartItem(item.id)}
                    disabled={cartActionLoading === `remove-${item.id}`}
                  >
                    ✕
                  </button>
                </div>
              ))}
            </div>

            <div className="cart-footer">
              <div className="cart-total">
                <span>Total:</span>
                <strong>{formatCurrency(cartTotalAmount)}</strong>
              </div>
              <button
                className="checkout-btn"
                onClick={handleCheckout}
                disabled={checkoutLoading || supplierCartItems.length === 0}
              >
                {checkoutLoading ? "Placing Order..." : "Place Order"}
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
