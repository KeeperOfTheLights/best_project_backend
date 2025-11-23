import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import OrderDetailModal from "../../components/OrderDetailModal";
import "./ConsumerOrders.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

const STATUS_CONFIG = {
  pending: { label: "Pending", class: "status-pending" },
  "in-transit": { label: "In Transit", class: "status-transit" },
  approved: { label: "Approved", class: "status-transit" },
  delivered: { label: "Delivered", class: "status-delivered" },
  cancelled: { label: "Cancelled", class: "status-cancelled" },
};

export default function ConsumerOrders() {
  const navigate = useNavigate();
  const { token, logout, loading: authLoading } = useAuth();
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selectedOrderId, setSelectedOrderId] = useState(null);

  const fetchOrders = async () => {
    if (authLoading) return;
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/orders/my/`, {
        headers: { Authorization: `Bearer ${token}` },
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
    if (authLoading) return;
    fetchOrders();
  }, [token, authLoading]);

  const stats = useMemo(() => {
    return orders.reduce(
      (acc, order) => {
        acc.total++;
        if (order.status === "pending") acc.pending++;
        if (order.status === "approved" || order.status === "in-transit") acc.transit++;
        if (order.status === "delivered") acc.delivered++;
        return acc;
      },
      { pending: 0, transit: 0, delivered: 0, total: 0 }
    );
  }, [orders]);

  const formatCurrency = (value) => {
    return `${Number(value || 0).toLocaleString()} ₸`;
  };

  const formatDate = (value) => {
    if (!value) return "-";
    try {
      return new Date(value).toLocaleDateString();
    } catch {
      return value;
    }
  };

  const getStatusInfo = (status) => {
    return STATUS_CONFIG[status] || { label: status, class: "" };
  };

  return (
    <div className="orders-page">
      <div className="orders-page-header">
        <h1>My Orders</h1>
        <button
          className="refresh-button"
          onClick={fetchOrders}
          disabled={loading}
        >
          {loading ? "Refreshing..." : "Refresh"}
        </button>
      </div>

      {error && <div className="error-banner">{error}</div>}

      <div className="stats-grid">
        <div className="stat-box">
          <div className="stat-icon stat-icon-pending">⏳</div>
          <div className="stat-content">
            <div className="stat-number">{stats.pending}</div>
            <div className="stat-label">Pending</div>
          </div>
        </div>
        <div className="stat-box">
          <div className="stat-icon stat-icon-transit">🏎</div>
          <div className="stat-content">
            <div className="stat-number">{stats.transit}</div>
            <div className="stat-label">In Transit</div>
          </div>
        </div>
        <div className="stat-box">
          <div className="stat-icon stat-icon-delivered">✔</div>
          <div className="stat-content">
            <div className="stat-number">{stats.delivered}</div>
            <div className="stat-label">Delivered</div>
          </div>
        </div>
        <div className="stat-box">
          <div className="stat-icon stat-icon-total">🍱</div>
          <div className="stat-content">
            <div className="stat-number">{stats.total}</div>
            <div className="stat-label">Total Orders</div>
          </div>
        </div>
      </div>

      {loading && orders.length === 0 && (
        <div className="loading-state">Loading orders...</div>
      )}

      {!loading && orders.length === 0 && !error && (
        <div className="empty-state">You haven't placed any orders yet.</div>
      )}

      <div className="orders-grid">
        {orders.map((order) => {
          const statusInfo = getStatusInfo(order.status);
          return (
            <div key={order.id} className="order-box">
              <div className="order-top">
                <div className="order-id-section">
                  <h3 className="order-number">Order #{order.id}</h3>
                  <span className={`status-badge ${statusInfo.class}`}>
                    {statusInfo.label}
                  </span>
                </div>
                <div className="supplier-info">
                  <span className="supplier-text">Supplier:</span>
                  <span className="supplier-name">{order.supplier_name || "Unknown"}</span>
                </div>
              </div>

              <div className="order-dates-section">
                <div className="date-box">
                  <span className="date-label">Order Date:</span>
                  <span className="date-value">{formatDate(order.created_at)}</span>
                </div>
                {order.updated_at && (
                  <div className="date-box">
                    <span className="date-label">Last Update:</span>
                    <span className="date-value">{formatDate(order.updated_at)}</span>
                  </div>
                )}
              </div>

              <div className="order-items-section">
                <h4 className="items-heading">Order Items:</h4>
                <div className="items-list">
                  {(order.items || []).map((item) => (
                    <div key={`${order.id}-${item.id}`} className="item-line">
                      <span className="item-name-text">{item.product_name}</span>
                      <span className="item-qty">{item.quantity}</span>
                      <span className="item-price-text">{formatCurrency(item.price)}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="order-bottom">
                <div className="total-section">
                  <span className="total-label-text">Total:</span>
                  <span className="total-value">{formatCurrency(order.total_price)}</span>
                </div>
                <div className="action-buttons">
                  <button
                    className="btn complaint-btn"
                    onClick={() =>
                      navigate("/consumer/complaints", {
                        state: { orderId: order.id },
                      })
                    }
                  >
                    File Complaint
                  </button>
                  {order.status === "pending" && (
                    <button className="btn btn-disabled" disabled>
                      Awaiting approval
                    </button>
                  )}
                  {order.status === "delivered" && (
                    <button className="btn btn-disabled" disabled>
                      Reorder
                    </button>
                  )}
                  <button
                    className="btn details-btn"
                    onClick={() => setSelectedOrderId(order.id)}
                  >
                    View Details
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <OrderDetailModal
        show={selectedOrderId !== null}
        orderId={selectedOrderId}
        onClose={() => setSelectedOrderId(null)}
      />
    </div>
  );
}
