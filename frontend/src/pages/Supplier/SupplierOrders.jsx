import "./SupplierOrders.css";
import React, { useEffect, useMemo, useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import OrderDetailModal from "../../components/OrderDetailModal";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

const STATUS_CONFIG = {
  pending: { label: "Pending", class: "status-pending", display: "pending" },
  approved: { label: "Processing", class: "status-processing", display: "processing" },
  delivered: { label: "Completed", class: "status-completed", display: "completed" },
  cancelled: { label: "Cancelled", class: "status-cancelled", display: "cancelled" },
};

const getStatusColor = (status) => {
  return STATUS_CONFIG[status]?.class || "";
};

const getStatusText = (status) => {
  return STATUS_CONFIG[status]?.label || status;
};

export default function SupplierOrders() {
  const navigate = useNavigate();
  const location = useLocation();
  const { token, logout } = useAuth();
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [filterConsumerId, setFilterConsumerId] = useState(null);
  const [actionLoading, setActionLoading] = useState(null);
  const [selectedOrderId, setSelectedOrderId] = useState(null);

  const fetchOrders = async () => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/orders/supplier/`, {
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
        const text = await res.text();
        throw new Error(text || "Failed to load orders");
      }

      const data = await res.json();
      setOrders(Array.isArray(data) ? data : []);
    } catch (err) {
      setError(err.message || "Failed to load orders");
      setOrders([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (location.state?.filterConsumerId) {
      setFilterConsumerId(location.state.filterConsumerId);
    }
    fetchOrders();
  }, [token, location.state]);

  const filteredOrders = useMemo(() => {
    if (!filterConsumerId) return orders;
    return orders.filter((order) => Number(order.consumer) === Number(filterConsumerId));
  }, [orders, filterConsumerId]);

  const stats = useMemo(() => {
    return filteredOrders.reduce(
      (acc, order) => {
        acc.total += 1;
        if (order.status === "pending") acc.pending += 1;
        if (order.status === "approved") acc.processing += 1;
        if (order.status === "delivered") acc.completed += 1;
        acc.revenue += Number(order.total_price || 0);
        return acc;
      },
      { pending: 0, processing: 0, completed: 0, total: 0, revenue: 0 }
    );
  }, [filteredOrders]);

  const formatCurrency = (value) => {
    return `${Number(value || 0).toLocaleString()} ₸`;
  };

  const formatDate = (value) => {
    if (!value) return "—";
    try {
      return new Date(value).toLocaleDateString();
    } catch {
      return value;
    }
  };

  const handleAcceptOrder = async (orderId) => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setActionLoading(orderId);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/orders/${orderId}/accept/`, {
        method: "POST",
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
        throw new Error(errorData.detail || "Failed to accept order");
      }

      await fetchOrders();
    } catch (err) {
      setError(err.message || "Failed to accept order");
    } finally {
      setActionLoading(null);
    }
  };

  const handleRejectOrder = async (orderId) => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setActionLoading(orderId);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/orders/${orderId}/reject/`, {
        method: "POST",
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
        throw new Error(errorData.detail || "Failed to reject order");
      }

      await fetchOrders();
    } catch (err) {
      setError(err.message || "Failed to reject order");
    } finally {
      setActionLoading(null);
    }
  };

  const handleDeliverOrder = async (orderId) => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setActionLoading(orderId);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/orders/${orderId}/deliver/`, {
        method: "POST",
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
        throw new Error(errorData.detail || "Failed to mark order as delivered");
      }

      await fetchOrders();
    } catch (err) {
      setError(err.message || "Failed to mark order as delivered");
    } finally {
      setActionLoading(null);
    }
  };

  return (
    <div className="supplier-orders-container">
      <div className="orders-header">
        <h2>Order Management</h2>
        <div style={{ display: "flex", gap: "1rem", alignItems: "center" }}>
          {filterConsumerId && (
            <button
              className="refresh-button"
              onClick={() => setFilterConsumerId(null)}
              style={{ backgroundColor: "#ff9800" }}
            >
              Show All Orders
            </button>
          )}
          <button className="refresh-button" onClick={fetchOrders} disabled={loading}>
            {loading ? "Refreshing..." : "Refresh"}
          </button>
        </div>
      </div>

      {error && <div className="error-banner">{error}</div>}

      <div className="orders-stats">
        <div className="stat-card">
          <div className="stat-icon pending-icon">📋</div>
          <div className="stat-info">
            <h3>{stats.pending}</h3>
            <p>Pending Orders</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon processing-icon">⚙️</div>
          <div className="stat-info">
            <h3>{stats.processing}</h3>
            <p>Processing</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon completed-icon">✓</div>
          <div className="stat-info">
            <h3>{stats.completed}</h3>
            <p>Completed</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon revenue-icon">💰</div>
          <div className="stat-info">
            <h3>{formatCurrency(stats.revenue)}</h3>
            <p>Total Revenue</p>
          </div>
        </div>
      </div>

      {filterConsumerId && (
        <div className="filter-message">
          <strong>Filtered:</strong> Showing orders from consumer ID {filterConsumerId}
        </div>
      )}

      {loading && filteredOrders.length === 0 && (
        <div className="loading-state">Loading orders...</div>
      )}

      {!loading && filteredOrders.length === 0 && !error && (
        <div className="empty-state">
          {filterConsumerId 
            ? `No orders found for consumer ID ${filterConsumerId}.` 
            : "No orders found."}
        </div>
      )}

      <div className="orders-list">
        {filteredOrders.map((order) => (
          <div key={order.id} className="supplier-order-card">
            <div className="order-header-section">
              <div className="order-main-info">
                <h3 className="order-id">Order #{order.id}</h3>
                <span className={`order-status ${getStatusColor(order.status)}`}>
                  {getStatusText(order.status)}
                </span>
              </div>
              <div className="order-customer">
                <span className="customer-name">{order.consumer_name || "Unknown Consumer"}</span>
                <span className="customer-type">Consumer</span>
              </div>
            </div>

            <div className="order-info-grid">
              <div className="info-item">
                <span className="info-icon">📅</span>
                <div className="info-content">
                  <span className="info-label">Order Date</span>
                  <span className="info-value">{formatDate(order.created_at)}</span>
                </div>
              </div>
              {order.updated_at && (
                <div className="info-item">
                  <span className="info-icon">🔄</span>
                  <div className="info-content">
                    <span className="info-label">Last Updated</span>
                    <span className="info-value">{formatDate(order.updated_at)}</span>
                  </div>
                </div>
              )}
            </div>

            <div className="order-items">
              <h4 className="items-title">Order Items</h4>
              <div className="items-table">
                <div className="table-header">
                  <span>Product</span>
                  <span>Quantity</span>
                  <span>Price</span>
                </div>
                {(order.items || []).map((item) => (
                  <div key={item.id} className="table-row">
                    <span className="item-name">{item.product_name}</span>
                    <span className="item-quantity">{item.quantity}</span>
                    <span className="item-price">{formatCurrency(item.price)}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="order-footer">
              <div className="order-total">
                <span className="total-label">Total Amount:</span>
                <span className="total-amount">{formatCurrency(order.total_price)}</span>
              </div>
              <div className="order-actions">
                {order.status === "pending" && (
                  <>
                    <button
                      className="action-btn accept-btn"
                      onClick={() => handleAcceptOrder(order.id)}
                      disabled={actionLoading === order.id}
                    >
                      {actionLoading === order.id ? "Processing..." : "Accept Order"}
                    </button>
                    <button
                      className="action-btn reject-btn"
                      onClick={() => handleRejectOrder(order.id)}
                      disabled={actionLoading === order.id}
                    >
                      {actionLoading === order.id ? "Processing..." : "Reject"}
                    </button>
                  </>
                )}
                {order.status === "approved" && (
                  <button
                    className="action-btn complete-btn"
                    onClick={() => handleDeliverOrder(order.id)}
                    disabled={actionLoading === order.id}
                  >
                    {actionLoading === order.id ? "Processing..." : "Mark as Delivered"}
                  </button>
                )}
                {order.status === "delivered" && (
                  <button className="action-btn invoice-btn" disabled>
                    Generate Invoice
                  </button>
                )}
                <button
                  className="action-btn details-btn"
                  onClick={() => setSelectedOrderId(order.id)}
                >
                  View Details
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      <OrderDetailModal
        show={selectedOrderId !== null}
        orderId={selectedOrderId}
        onClose={() => setSelectedOrderId(null)}
      />
    </div>
  );
}
