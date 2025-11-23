import React, { useState, useEffect } from "react";
import { useAuth } from "../../context/Auth-Context";
import { useNavigate } from "react-router-dom";
import "./ConsumerCatalog.css";
import Modal from "../../components/common/modal";

export default function ConsumerLinkManagement() {
  const { token, logout, loading: authLoading } = useAuth();
  const navigate = useNavigate();

  const [suppliers, setSuppliers] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");
  const [actionLoading, setActionLoading] = useState(null);

  const getInitialModalState = () => ({
    show: false,
    type: "",
    title: "",
    text: "",
    supplierId: null,
    supplierName: "",
    items: [],
    loading: false,
    error: "",
  });

  const [modalConfig, setModalConfig] = useState(getInitialModalState);
  const [catalogQuantities, setCatalogQuantities] = useState({});
  const [cartItems, setCartItems] = useState([]);
  const [cartLoading, setCartLoading] = useState(false);
  const [cartError, setCartError] = useState("");
  const [cartActionLoading, setCartActionLoading] = useState(null);
  const [checkoutLoading, setCheckoutLoading] = useState(false);
  const [checkoutMessage, setCheckoutMessage] = useState("");

  const API_BASE = "http://127.0.0.1:8000/api/accounts";

  const parseErrorResponse = async (response) => {
    const text = await response.text();
    if (!text) return "Request failed";
    try {
      const data = JSON.parse(text);
      return data.detail || data.message || data.error || "Request failed";
    } catch {
      return text;
    }
  };

  const fetchCart = async () => {
    if (authLoading) return;
    if (!token) return;
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
      setCartError(err.message || "Failed to load cart");
      setCartItems([]);
    } finally {
      setCartLoading(false);
    }
  };

  const fetchSuppliers = async () => {
    if (authLoading) return;
    
    setLoading(true);
    setErrorMsg("");

    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    try {
      const resSuppliers = await fetch(`${API_BASE}/suppliers/`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (resSuppliers.status === 401) {
        logout();
        navigate("/login");
        return;
      }
      if (!resSuppliers.ok) throw new Error("Failed to fetch suppliers");
      const allSuppliers = await resSuppliers.json();

      const resLinks = await fetch(`${API_BASE}/consumer/links/`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (resLinks.status === 401) {
        logout();
        navigate("/login");
        return;
      }
      if (!resLinks.ok) throw new Error("Failed to fetch links");
      const linksData = await resLinks.json();

      const mapped = allSuppliers.map((sup) => {
        const link = linksData.find((l) => Number(l.supplier) === Number(sup.id));
        return {
          id: sup.id,
          linkId: link?.id,
          name: sup.full_name,
          company: sup.supplier_company || "N/A",
          email: sup.email,
          username: sup.username,
          linkStatus: link ? link.status : "not_linked",
        };
      });

      setSuppliers(mapped);
    } catch (err) {
      setErrorMsg(err.message);
      setSuppliers([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (authLoading) return;
    fetchSuppliers();
  }, [token, authLoading]);

  useEffect(() => {
    if (authLoading) return;
    fetchCart();
  }, [token, authLoading]);

  const handleSendRequest = async (supplierId) => {
    const supplier = suppliers.find((s) => s.id === supplierId);
    if (!supplier) return;

    if (supplier.linkStatus !== "not_linked" && supplier.linkStatus !== "rejected") {
      setErrorMsg(`Cannot send request - link already exists: ${supplier.linkStatus}`);
      return;
    }

    setActionLoading(supplierId);
    setErrorMsg("");

    setSuppliers((prev) =>
      prev.map((s) => (s.id === supplierId ? { ...s, linkStatus: "pending" } : s))
    );

    try {
      const res = await fetch(`${API_BASE}/link/send/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ supplier_id: supplierId }),
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const responseText = await res.text();
        let data;
        try { data = JSON.parse(responseText); } catch { data = { detail: responseText }; }
        throw new Error(data.detail || data.message || "Failed to send link request");
      }

      await fetchSuppliers();
    } catch (err) {
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const handleDeleteLink = (supplierId) => {
    const supplier = suppliers.find((s) => s.id === supplierId);
    if (!supplier || !supplier.linkId) {
      setErrorMsg("No link found. Please refresh and try again.");
      return;
    }

    const type = supplier.linkStatus === "pending" ? "cancel" : "unlink";

    setModalConfig({
      ...getInitialModalState(),
      show: true,
      type: "confirm",
      title: type === "cancel" ? "Cancel Request" : "Unlink Supplier",
      text:
        type === "cancel"
          ? "Are you sure you want to cancel this request?"
          : "Are you sure you want to unlink this supplier?",
      supplierId: supplier.id,
    });
  };

  const confirmDelete = async () => {
    const supplier = suppliers.find((s) => s.id === modalConfig.supplierId);
    if (!supplier || !supplier.linkId) return;

    setModalConfig(getInitialModalState());
    setActionLoading(supplier.id);
    setErrorMsg("");

    try {
      const res = await fetch(`${API_BASE}/link/${supplier.linkId}/`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || `Failed: ${res.status}`);
      }

      await fetchSuppliers();
    } catch (err) {
      setErrorMsg(err.message || "Error deleting link");
    } finally {
      setActionLoading(null);
    }
  };

  const handleViewCatalog = async (supplier) => {
    setCatalogQuantities({});
    setCheckoutMessage("");
    setCartError("");

    setModalConfig({
      ...getInitialModalState(),
      show: true,
      type: "catalog",
      title: `${supplier.name}'s Catalog`,
      text: "",
      supplierId: supplier.id,
      supplierName: supplier.name,
      items: [],
      loading: true,
      error: "",
    });

    try {
      const res = await fetch(`${API_BASE}/supplier/${supplier.id}/catalog/`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (res.status === 403) {
        setModalConfig((prev) => ({
          ...prev,
          loading: false,
          error: "You are not linked to this supplier.",
          items: [],
        }));
        return;
      }

      if (!res.ok) {
        throw new Error(await parseErrorResponse(res));
      }

      const data = await res.json();
      const normalized = Array.isArray(data) ? data : [];

      const initialQuantities = {};
      normalized.forEach((item) => {
        initialQuantities[item.id] = item.minOrder || 1;
      });

      setCatalogQuantities(initialQuantities);
      setModalConfig((prev) => ({
        ...prev,
        loading: false,
        error: "",
        items: normalized,
      }));
    } catch (err) {
      setModalConfig((prev) => ({
        ...prev,
        loading: false,
        error: err.message || "Failed to load catalog",
      }));
    }
  };

  const handleCatalogQuantityChange = (productId, nextValue, minOrder = 1, maxStock = Infinity) => {
    const parsedValue = Number(nextValue);
    let quantity = Number.isNaN(parsedValue) ? minOrder : parsedValue;
    if (quantity < minOrder) quantity = minOrder;
    if (quantity > maxStock) quantity = maxStock;

    setCatalogQuantities((prev) => ({
      ...prev,
      [productId]: quantity,
    }));
  };

  const handleAddToCart = async (product) => {
    const quantity = catalogQuantities[product.id] || product.minOrder || 1;
    const activeSupplierId = cartItems.length ? cartItems[0].product_supplier_id : null;

    if (activeSupplierId && activeSupplierId !== modalConfig.supplierId) {
      setCartError("Cart already contains products from another supplier. Please checkout or clear it first.");
      return;
    }

    setCartActionLoading(`add-${product.id}`);
    setCartError("");
    setCheckoutMessage("");

    try {
      const res = await fetch(`${API_BASE}/cart/add/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          product_id: product.id,
          quantity,
        }),
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        throw new Error(await parseErrorResponse(res));
      }

      await fetchCart();
      setCheckoutMessage(`Added ${quantity} ${product.unit || ""} of ${product.name} to cart.`);
    } catch (err) {
      setCartError(err.message || "Failed to add product to cart");
    } finally {
      setCartActionLoading(null);
    }
  };

  const handleUpdateCartItem = async (itemId, quantity) => {
    setCartActionLoading(`update-${itemId}`);
    setCartError("");
    setCheckoutMessage("");

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

      if (!res.ok) {
        throw new Error(await parseErrorResponse(res));
      }

      await fetchCart();
    } catch (err) {
      setCartError(err.message || "Failed to update cart");
    } finally {
      setCartActionLoading(null);
    }
  };

  const handleRemoveCartItem = async (itemId) => {
    setCartActionLoading(`remove-${itemId}`);
    setCartError("");
    setCheckoutMessage("");

    try {
      const res = await fetch(`${API_BASE}/cart/${itemId}/`, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        throw new Error(await parseErrorResponse(res));
      }

      await fetchCart();
    } catch (err) {
      setCartError(err.message || "Failed to remove item");
    } finally {
      setCartActionLoading(null);
    }
  };

  const handleCheckout = async () => {
    const hasSupplierItems = cartItems.some(
      (item) => item.product_supplier_id === modalConfig.supplierId
    );

    if (!hasSupplierItems) {
      setCartError("Add items from this supplier before checking out.");
      return;
    }

    setCheckoutLoading(true);
    setCartError("");
    setCheckoutMessage("");

    try {
      const res = await fetch(`${API_BASE}/orders/checkout/`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        throw new Error(await parseErrorResponse(res));
      }

      const data = await res.json();
      setCheckoutMessage(`Order #${data.id} placed successfully.`);
      await fetchCart();
    } catch (err) {
      setCartError(err.message || "Checkout failed");
    } finally {
      setCheckoutLoading(false);
    }
  };

  const formatCurrency = (value) => {
    const numberValue = Number(value || 0);
    return `${numberValue.toLocaleString()} ₸`;
  };

  const closeModal = () => {
    setModalConfig(getInitialModalState());
    setCatalogQuantities({});
    setCheckoutMessage("");
    setCartError("");
  };

  const filteredSuppliers =
    filterStatus === "all"
      ? suppliers
      : suppliers.filter((s) => s.linkStatus === filterStatus);

  const counts = {
    all: suppliers.length,
    linked: suppliers.filter((s) => s.linkStatus === "linked").length,
    pending: suppliers.filter((s) => s.linkStatus === "pending").length,
    not_linked: suppliers.filter((s) => s.linkStatus === "not_linked").length,
    rejected: suppliers.filter((s) => s.linkStatus === "rejected").length,
  };

  const supplierCartItems =
    modalConfig.type === "catalog"
      ? cartItems.filter((item) => item.product_supplier_id === modalConfig.supplierId)
      : [];

  const cartSubtotal = supplierCartItems.reduce((sum, item) => {
    const lineTotal = Number(item.line_total ?? 0);
    if (!Number.isNaN(lineTotal) && lineTotal > 0) {
      return sum + lineTotal;
    }

    const fallback = Number(item.product_price || 0) * Number(item.quantity || 0);
    return sum + (Number.isNaN(fallback) ? 0 : fallback);
  }, 0);

  const renderCatalogCards = () => {
    if (modalConfig.loading) {
      return <p className="catalog-loading">Loading catalog...</p>;
    }

    if (modalConfig.error) {
      return <div className="catalog-inline-alert error">{modalConfig.error}</div>;
    }

    if (!modalConfig.items.length) {
      return <p className="empty-catalog">No products available in this catalog</p>;
    }

    return (
      <div className="catalog-grid">
        {modalConfig.items.map((item) => {
          const quantity = catalogQuantities[item.id] || item.minOrder || 1;
          const isAddLoading = cartActionLoading === `add-${item.id}`;

          return (
            <div key={item.id} className="catalog-card">
              {item.image && (
                <img
                  src={item.image}
                  alt={item.name}
                  className="catalog-card-image"
                  onError={(e) => {
                    e.currentTarget.style.display = "none";
                  }}
                />
              )}
              <div className="catalog-card-body">
                <div className="catalog-card-header">
                  <h4>{item.name}</h4>
                  <p className="catalog-card-category">{item.category}</p>
                  <p className="catalog-card-description">{item.description || "No description"}</p>
                </div>
                <div className="catalog-card-meta">
                  <span> Stock: {item.stock} {item.unit}</span>
                  <span> Min Order: {item.minOrder} {item.unit}</span>
                  {item.delivery_option && (
                    <span>
                      {item.delivery_option === "delivery" && "🏎 Delivery"}
                      {item.delivery_option === "pickup" && "🏬 Pickup"}
                      {item.delivery_option === "both" && "🚚 Delivery & Pickup"}
                    </span>
                  )}
                  {item.lead_time_days > 0 && (
                    <span>⌚ {item.lead_time_days} {item.lead_time_days === 1 ? "day" : "days"}</span>
                  )}
                </div>
                <div className="catalog-card-price">
                  {item.discounted_price && item.discount > 0 ? (
                    <>
                      <span style={{ textDecoration: "line-through", color: "#9b9696ff", marginRight: "8px", fontSize: "0.9rem" }}>
                        {formatCurrency(item.price)}
                      </span>
                      <span style={{ color: "#e44c3bff", fontWeight: "bold" }}>
                        {formatCurrency(item.discounted_price)}
                      </span>
                      <span style={{ color: "#e24938ff", marginLeft: "4px", fontSize: "0.85rem" }}>
                        ({item.discount}% off)
                      </span>
                    </>
                  ) : (
                    formatCurrency(item.price)
                  )}
                </div>
                <div className="catalog-card-actions">
                  <div className="catalog-quantity-control">
                    <button
                      onClick={() =>
                        handleCatalogQuantityChange(item.id, quantity - 1, item.minOrder, item.stock)
                      }
                      disabled={quantity <= (item.minOrder || 1)}
                    >
                      -
                    </button>
                    <input
                      type="number"
                      min={item.minOrder}
                      max={item.stock}
                      value={quantity}
                      onChange={(e) =>
                        handleCatalogQuantityChange(
                          item.id,
                          e.target.value,
                          item.minOrder,
                          item.stock
                        )
                      }
                    />
                    <button
                      onClick={() =>
                        handleCatalogQuantityChange(item.id, quantity + 1, item.minOrder, item.stock)
                      }
                      disabled={quantity >= item.stock}
                    >
                      +
                    </button>
                  </div>

                  <button
                    className="catalog-add-btn"
                    onClick={() => handleAddToCart(item)}
                    disabled={item.stock === 0 || isAddLoading}
                  >
                    {item.stock === 0 ? "Out of Stock" : isAddLoading ? "Adding..." : "Add to Cart"}
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    );
  };

  const renderCartPanel = () => (
    <div className="catalog-cart-panel">
      <div className="cart-panel-header">
        <h3>Cart ({supplierCartItems.length} items)</h3>
        <div style={{ display: "flex", gap: "0.5rem", alignItems: "center" }}>
          {cartLoading && <span className="cart-loading">Refreshing...</span>}
          <button
            className="cart-close-btn"
            onClick={closeModal}
            style={{
              padding: "0.5rem 1rem",
              border: "none",
              borderRadius: "8px",
              background: "#f03f32ff",
              color: "white",
              fontWeight: "600",
              cursor: "pointer",
              fontSize: "0.9rem",
            }}
          >
            Close
          </button>
        </div>
      </div>

      {cartError && <div className="catalog-inline-alert error">{cartError}</div>}
      {checkoutMessage && (
        <div className="catalog-inline-alert success">{checkoutMessage}</div>
      )}

      {supplierCartItems.length === 0 ? (
        <p className="cart-empty">No items from this supplier yet.</p>
      ) : (
        <>
          <div className="cart-panel-list">
            {supplierCartItems.map((item) => {
              const minOrder = item.product_min_order || 1;
              const maxStock = item.product_stock || item.quantity;

              return (
                <div key={item.id} className="cart-panel-item">
                  {item.product_image && (
                    <img
                      src={item.product_image}
                      alt={item.product_name}
                      className="cart-panel-image"
                      onError={(e) => {
                        e.currentTarget.style.display = "none";
                      }}
                    />
                  )}

                  <div className="cart-panel-info">
                    <h4>{item.product_name}</h4>
                    <p>
                      {item.product_discounted_price && item.product_discount > 0 ? (
                        <>
                          <span style={{ textDecoration: "line-through", color: "#9a9797ff", marginRight: "8px", fontSize: "0.9rem" }}>
                            {formatCurrency(item.product_price)}
                          </span>
                          <span style={{ color: "#e14a39ff", fontWeight: "bold" }}>
                            {formatCurrency(item.product_discounted_price)}
                          </span>
                        </>
                      ) : (
                        formatCurrency(item.product_price)
                      )}
                    </p>
                  </div>

                  <div className="cart-panel-quantity">
                    <button
                      onClick={() => handleUpdateCartItem(item.id, item.quantity - 1)}
                      disabled={
                        cartActionLoading === `update-${item.id}` || item.quantity <= minOrder
                      }
                    >
                      -
                    </button>
                    <span>{item.quantity}</span>
                    <button
                      onClick={() => handleUpdateCartItem(item.id, item.quantity + 1)}
                      disabled={
                        cartActionLoading === `update-${item.id}` || item.quantity >= maxStock
                      }
                    >
                      +
                    </button>
                  </div>

                  <div className="cart-panel-total">{formatCurrency(item.line_total)}</div>
                  <button
                    className="cart-remove-btn"
                    onClick={() => handleRemoveCartItem(item.id)}
                    disabled={cartActionLoading === `remove-${item.id}`}
                  >
                    X
                  </button>
                </div>
              );
            })}
          </div>

          <div className="checkout-bar">
            <div className="cart-total">
              <span>Total</span>
              <strong>{formatCurrency(cartSubtotal)}</strong>
            </div>
            <button
              className="checkout-btn"
              onClick={handleCheckout}
              disabled={checkoutLoading || supplierCartItems.length === 0}
            >
              {checkoutLoading ? "Placing order..." : "Proceed to Checkout"}
            </button>
          </div>
        </>
      )}
    </div>
  );

  if (loading) return <p>Loading suppliers...</p>;

  return (
    <div className="link-management-container">
      <div className="link-header">
        <h2>Supplier Connections</h2>
        <p className="link-subtitle">Manage your supplier relationships</p>
      </div>

      {errorMsg && (
        <div className="error-message">
          {errorMsg}
          <button onClick={() => setErrorMsg("")} className="close-btn">✕</button>
        </div>
      )}

      <div className="link-stats">
        <div className="stat-card">
          <div className="stat-icon approved-icon">✔</div>
          <div className="stat-info">
            <h3>{counts.linked}</h3>
            <p>Linked</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon pending-icon">⏳</div>
          <div className="stat-info">
            <h3>{counts.pending}</h3>
            <p>Pending</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon available-icon">🕵🏽</div>
          <div className="stat-info">
            <h3>{counts.not_linked}</h3>
            <p>Available</p>
          </div>
        </div>
      </div>

      <div className="link-filters">
        {["all", "linked", "pending", "not_linked", "rejected"].map((status) => (
          <button
            key={status}
            className={`filter-btn ${filterStatus === status ? "active" : ""}`}
            onClick={() => setFilterStatus(status)}
          >
            {status.replace("_", " ")} ({counts[status] || 0})
          </button>
        ))}
      </div>

      <div className="suppliers-grid">
        {filteredSuppliers.map((supplier) => (
          <div key={supplier.id} className="supplier-link-card">
            <div className="supplier-content">
              <h3 className="supplier-name">{supplier.name}</h3>
              <p className="supplier-company">🏚 {supplier.company}</p>
              <p className="supplier-email">📨 {supplier.email}</p>

              <div className="link-actions">
                {supplier.linkStatus === "not_linked" && (
                  <button
                    className="link-btn send-request-btn"
                    onClick={() => handleSendRequest(supplier.id)}
                    disabled={actionLoading === supplier.id}
                  >
                    {actionLoading === supplier.id ? "Sending..." : "Send Link Request"}
                  </button>
                )}

                {supplier.linkStatus === "pending" && (
                  <button
                    className="link-btn cancel-btn"
                    onClick={() => handleDeleteLink(supplier.id)}
                    disabled={actionLoading === supplier.id}
                  >
                    {actionLoading === supplier.id ? "Cancelling..." : "Cancel Request"}
                  </button>
                )}

                {supplier.linkStatus === "linked" && (
                  <>
                    <button
                      className="link-btn view-catalog-btn"
                      onClick={() => handleViewCatalog(supplier)}
                    >
                      View Catalog
                    </button>
                    <button
                      className="link-btn unlink-btn"
                      onClick={() => handleDeleteLink(supplier.id)}
                      disabled={actionLoading === supplier.id}
                    >
                      {actionLoading === supplier.id ? "Unlinking..." : "Unlink"}
                    </button>
                  </>
                )}

                {supplier.linkStatus === "rejected" && (
                  <>
                    <span className="rejected-message">Request was rejected</span>
                    <button
                      className="link-btn send-request-btn"
                      onClick={() => handleSendRequest(supplier.id)}
                      disabled={actionLoading === supplier.id}
                    >
                      {actionLoading === supplier.id ? "Sending..." : "Send Again"}
                    </button>
                  </>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredSuppliers.length === 0 && (
        <div className="empty-state">
          <p>No suppliers found with the status: {filterStatus}</p>
        </div>
      )}

      <Modal
        show={modalConfig.show}
        title={modalConfig.title}
        text={modalConfig.text}
        onConfirm={modalConfig.type === "confirm" ? confirmDelete : null}
        onCancel={closeModal}
      >
        {modalConfig.type === "catalog" && (
          <div className="catalog-modal-content">
            <div className="catalog-body">{renderCatalogCards()}</div>
            {renderCartPanel()}
          </div>
        )}
      </Modal>
    </div>
  );
}