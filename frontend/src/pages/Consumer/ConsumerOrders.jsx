import React, { useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import OrderDetailModal from "../../components/OrderDetailModal";
import "./ConsumerOrders.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function ConsumerOrders() {
  const { t } = useTranslation();
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
        throw new Error(text || t("orders.failedToLoad"));
      }

      const data = await res.json();
      setOrders(Array.isArray(data) ? data : []);
    } catch (err) {
      setError(err.message || t("orders.failedToLoad"));
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
    const statusMap = {
      pending: { label: t("orders.pending"), class: "status-pending" },
      "in-transit": { label: t("orders.inTransit"), class: "status-transit" },
      approved: { label: t("orders.approved"), class: "status-transit" },
      delivered: { label: t("orders.delivered"), class: "status-delivered" },
      cancelled: { label: t("orders.cancelled"), class: "status-cancelled" },
    };
    return statusMap[status] || { label: status, class: "" };
  };

  return (
    <div className="orders-page">
      <div className="orders-page-header">
        <h1>{t("orders.myOrders")}</h1>
        <button
          className="refresh-button"
          onClick={fetchOrders}
          disabled={loading}
        >
          {loading ? t("common.processing") : t("common.refresh")}
        </button>
      </div>

      {error && <div className="error-banner">{error}</div>}

      <div className="stats-grid">
        <div className="stat-box">
          <div className="stat-icon stat-icon-pending">⏳</div>
          <div className="stat-content">
            <div className="stat-number">{stats.pending}</div>
            <div className="stat-label">{t("orders.pending")}</div>
          </div>
        </div>
        <div className="stat-box">
          <div className="stat-icon stat-icon-transit">🏎</div>
          <div className="stat-content">
            <div className="stat-number">{stats.transit}</div>
            <div className="stat-label">{t("orders.inTransit")}</div>
          </div>
        </div>
        <div className="stat-box">
          <div className="stat-icon stat-icon-delivered">✔</div>
          <div className="stat-content">
            <div className="stat-number">{stats.delivered}</div>
            <div className="stat-label">{t("orders.delivered")}</div>
          </div>
        </div>
        <div className="stat-box">
          <div className="stat-icon stat-icon-total">🍱</div>
          <div className="stat-content">
            <div className="stat-number">{stats.total}</div>
            <div className="stat-label">{t("orders.totalOrders")}</div>
          </div>
        </div>
      </div>

      {loading && orders.length === 0 && (
        <div className="loading-state">{t("orders.loadingOrders")}</div>
      )}

      {!loading && orders.length === 0 && !error && (
        <div className="empty-state">{t("orders.haventPlacedOrders")}</div>
      )}

      <div className="orders-grid">
        {orders.map((order) => {
          const statusInfo = getStatusInfo(order.status);
          return (
            <div key={order.id} className="order-box">
              <div className="order-top">
                <div className="order-id-section">
                  <h3 className="order-number">{t("orders.orderNumber", { id: order.id })}</h3>
                  <span className={`status-badge ${statusInfo.class}`}>
                    {statusInfo.label}
                  </span>
                </div>
                <div className="supplier-info">
                  <span className="supplier-text">{t("orders.supplier")}:</span>
                  <span className="supplier-name">{order.supplier_name || t("orders.supplier")}</span>
                </div>
              </div>

              <div className="order-dates-section">
                <div className="date-box">
                  <span className="date-label">{t("orders.orderDateLabel")}</span>
                  <span className="date-value">{formatDate(order.created_at)}</span>
                </div>
                {order.updated_at && (
                  <div className="date-box">
                    <span className="date-label">{t("orders.lastUpdateLabel")}</span>
                    <span className="date-value">{formatDate(order.updated_at)}</span>
                  </div>
                )}
              </div>

              <div className="order-items-section">
                <h4 className="items-heading">{t("orders.orderItems")}:</h4>
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
                  <span className="total-label-text">{t("orders.total")}:</span>
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
                    {t("orders.fileComplaint")}
                  </button>
                  {order.status === "pending" && (
                    <button className="btn btn-disabled" disabled>
                      {t("orders.awaitingApproval")}
                    </button>
                  )}
                  {order.status === "delivered" && (
                    <button className="btn btn-disabled" disabled>
                      {t("orders.reorder")}
                    </button>
                  )}
                  <button
                    className="btn details-btn"
                    onClick={() => setSelectedOrderId(order.id)}
                  >
                    {t("orders.viewDetails")}
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
