import React, { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useAuth } from "../context/Auth-Context";
import "./OrderDetailModal.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function OrderDetailModal({ show, orderId, onClose }) {
  const { t } = useTranslation();
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
        throw new Error(text || t("orders.failedToLoad"));
      }

      const data = await res.json();
      setOrder(data);
    } catch (err) {
      setError(err.message || t("orders.failedToLoad"));
      setOrder(null);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (value) => {
    return `${Number(value || 0).toLocaleString()} ₸`;
  };

  const formatDate = (value) => {
    if (!value) return "-";
    try {
      return new Date(value).toLocaleString();
    } catch {
      return value;
    }
  };

  const getStatusInfo = (status) => {
    const statusMap = {
      pending: { label: t("orders.pending"), class: "status-pending" },
      approved: { label: t("orders.approved"), class: "status-approved" },
      "in-transit": { label: t("orders.inTransit"), class: "status-transit" },
      delivered: { label: t("orders.delivered"), class: "status-delivered" },
      cancelled: { label: t("orders.cancelled"), class: "status-cancelled" },
    };
    return statusMap[status] || { label: status, class: "" };
  };

  if (!show) return null;

  return (
    <div className="order-detail-modal-overlay" onClick={onClose}>
      <div className="order-detail-modal-box" onClick={(e) => e.stopPropagation()}>
        <div className="order-detail-modal-header">
          <h2>{t("orders.orderDetails")}</h2>
          <button className="order-detail-modal-close" onClick={onClose}>
            x
          </button>
        </div>

        <div className="order-detail-modal-content">
          {loading && (
            <div className="order-detail-loading">
              <p>{t("orders.loadingOrderDetails")}</p>
            </div>
          )}

          {error && (
            <div className="order-detail-error">
              <p>{error}</p>
              <button onClick={fetchOrderDetails}>{t("common.retry")}</button>
            </div>
          )}

          {!loading && !error && order && (
            <>
              <div className="order-detail-section">
                <div className="order-detail-row">
                  <span className="order-detail-label">{t("orders.orderNumber", { id: "" }).replace("#", "")} ID:</span>
                  <span className="order-detail-value">#{order.id}</span>
                </div>
                <div className="order-detail-row">
                  <span className="order-detail-label">{t("products.status")}:</span>
                  <span className={`order-detail-status ${getStatusInfo(order.status).class}`}>
                    {getStatusInfo(order.status).label}
                  </span>
                </div>
                <div className="order-detail-row">
                  <span className="order-detail-label">{t("orders.orderDate")}:</span>
                  <span className="order-detail-value">{formatDate(order.created_at)}</span>
                </div>
              </div>

              <div className="order-detail-section">
                <h3 className="order-detail-section-title">{t("orders.customerInformation")}</h3>
                <div className="order-detail-row">
                  <span className="order-detail-label">{t("orders.consumer")}:</span>
                  <span className="order-detail-value">
                    {order.consumer_name || `${t("orders.consumer")} #${order.consumer}`}
                  </span>
                </div>
                <div className="order-detail-row">
                  <span className="order-detail-label">{t("orders.supplier")}:</span>
                  <span className="order-detail-value">
                    {order.supplier_name || `${t("orders.supplier")} #${order.supplier}`}
                  </span>
                </div>
              </div>

              <div className="order-detail-section">
                <h3 className="order-detail-section-title">{t("orders.orderItems")}</h3>
                <div className="order-detail-items">
                  <div className="order-detail-items-header">
                    <span>{t("products.productName")}</span>
                    <span>{t("catalog.quantity")}</span>
                    <span>{t("products.price")}</span>
                    <span>{t("catalog.subtotal")}</span>
                  </div>
                  {order.items && order.items.length > 0 ? (
                    order.items.map((item) => (
                      <div key={item.id} className="order-detail-item">
                        <span className="order-detail-item-name">{item.product_name || `${t("products.productName")} #${item.product}`}</span>
                        <span className="order-detail-item-qty">{item.quantity}</span>
                        <span className="order-detail-item-price">{formatCurrency(item.price)}</span>
                        <span className="order-detail-item-subtotal">
                          {formatCurrency(Number(item.price) * Number(item.quantity))}
                        </span>
                      </div>
                    ))
                  ) : (
                    <div className="order-detail-no-items">{t("orders.noItemsFound")}</div>
                  )}
                </div>
              </div>

              <div className="order-detail-section order-detail-total-section">
                <div className="order-detail-total-row">
                  <span className="order-detail-total-label">{t("orders.total")}:</span>
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

