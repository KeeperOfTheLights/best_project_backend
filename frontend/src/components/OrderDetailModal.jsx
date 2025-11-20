import React, { useState, useEffect } from "react";
import { useAuth } from "../context/Auth-Context";
import "./OrderDetailModal.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function OrderDetailModal({ show, orderId, onClose }) {
  const { token, logout } = useAuth();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (show && orderId) {
      fetchOrderDetails();
    } else {
      setOrder(null);
      setError("");
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [show, orderId]);

  const fetchOrderDetails = async () => {
    if (!token || !orderId) return;

    setLoading(true);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/orders/${orderId}/`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.status === 401) {
        logout();
        return;
      }

      if (!res.ok) {
        const text = await res.text();
        throw new Error(text || "Failed to load order details");
      }

      const data = await res.json();
      setOrder(data);
    } catch (err) {
      setError(err.message || "Failed to load order details");
      setOrder(null);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (value) => {
    return `${Number(value || 0).toLocaleString()} ₸`;
  };

  const formatDate = (value) => {
    if (!value) return "—";
    try {
      return new Date(value).toLocaleString();
    } catch {
      return value;
    }
  };

  const getStatusInfo = (status) => {
    const statusMap = {
      pending: { label: "Pending", class: "status-pending" },
      approved: { label: "Approved", class: "status-approved" },
      "in-transit": { label: "In Transit", class: "status-transit" },
      delivered: { label: "Delivered", class: "status-delivered" },
      cancelled: { label: "Cancelled", class: "status-cancelled" },
    };
    return statusMap[status] || { label: status, class: "" };
  };

  if (!show) return null;

  return (
    <div className="order-detail-modal-overlay" onClick={onClose}>
      <div className="order-detail-modal-box" onClick={(e) => e.stopPropagation()}>
        <div className="order-detail-modal-header">
          <h2>Order Details</h2>
          <button className="order-detail-modal-close" onClick={onClose}>
            ×
          </button>
        </div>

        <div className="order-detail-modal-content">
          {loading && (
            <div className="order-detail-loading">
              <p>Loading order details...</p>
            </div>
          )}

          {error && (
            <div className="order-detail-error">
              <p>{error}</p>
              <button onClick={fetchOrderDetails}>Retry</button>
            </div>
          )}

          {!loading && !error && order && (
            <>
              <div className="order-detail-section">
                <div className="order-detail-row">
                  <span className="order-detail-label">Order ID:</span>
                  <span className="order-detail-value">#{order.id}</span>
                </div>
                <div className="order-detail-row">
                  <span className="order-detail-label">Status:</span>
                  <span className={`order-detail-status ${getStatusInfo(order.status).class}`}>
                    {getStatusInfo(order.status).label}
                  </span>
                </div>
                <div className="order-detail-row">
                  <span className="order-detail-label">Order Date:</span>
                  <span className="order-detail-value">{formatDate(order.created_at)}</span>
                </div>
              </div>

              <div className="order-detail-section">
                <h3 className="order-detail-section-title">Customer Information</h3>
                <div className="order-detail-row">
                  <span className="order-detail-label">Consumer:</span>
                  <span className="order-detail-value">
                    {order.consumer_name || `Consumer #${order.consumer}`}
                  </span>
                </div>
                <div className="order-detail-row">
                  <span className="order-detail-label">Supplier:</span>
                  <span className="order-detail-value">
                    {order.supplier_name || `Supplier #${order.supplier}`}
                  </span>
                </div>
              </div>

              <div className="order-detail-section">
                <h3 className="order-detail-section-title">Order Items</h3>
                <div className="order-detail-items">
                  <div className="order-detail-items-header">
                    <span>Product</span>
                    <span>Quantity</span>
                    <span>Price</span>
                    <span>Subtotal</span>
                  </div>
                  {order.items && order.items.length > 0 ? (
                    order.items.map((item) => (
                      <div key={item.id} className="order-detail-item">
                        <span className="order-detail-item-name">{item.product_name || `Product #${item.product}`}</span>
                        <span className="order-detail-item-qty">{item.quantity}</span>
                        <span className="order-detail-item-price">{formatCurrency(item.price)}</span>
                        <span className="order-detail-item-subtotal">
                          {formatCurrency(Number(item.price) * Number(item.quantity))}
                        </span>
                      </div>
                    ))
                  ) : (
                    <div className="order-detail-no-items">No items found</div>
                  )}
                </div>
              </div>

              <div className="order-detail-section order-detail-total-section">
                <div className="order-detail-total-row">
                  <span className="order-detail-total-label">Total:</span>
                  <span className="order-detail-total-value">{formatCurrency(order.total_price)}</span>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

