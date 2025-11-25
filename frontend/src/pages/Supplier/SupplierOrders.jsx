import "./SupplierOrders.css";
import React, { useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import { is_catalog_manager } from "../../utils/roleUtils";
import OrderDetailModal from "../../components/OrderDetailModal";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

const getStatusColor = (status) => {
  const statusMap = {
    pending: "status-pending",
    approved: "status-processing",
    delivered: "status-completed",
    cancelled: "status-cancelled",
  };
  return statusMap[status] || "";
};

export default function SupplierOrders() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const { token, logout, role, loading: authLoading } = useAuth();
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [filterConsumerId, setFilterConsumerId] = useState(null);
  const [actionLoading, setActionLoading] = useState(null);
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
        if (order.status === "delivered") {
          acc.completed += 1;
          acc.revenue += Number(order.total_price || 0);
        }
        return acc;
      },
      { pending: 0, processing: 0, completed: 0, total: 0, revenue: 0 }
    );
  }, [filteredOrders]);

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

  const handleAcceptOrder = async (orderId) => {
    if (authLoading) return;
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
        throw new Error(errorData.detail || t("orders.failedToAccept"));
      }

      await fetchOrders();
    } catch (err) {
      setError(err.message || "Failed to accept order");
    } finally {
      setActionLoading(null);
    }
  };

  const handleRejectOrder = async (orderId) => {
    if (authLoading) return;
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
        throw new Error(errorData.detail || t("orders.failedToReject"));
      }

      await fetchOrders();
    } catch (err) {
      setError(err.message || "Failed to reject order");
    } finally {
      setActionLoading(null);
    }
  };

  const handleDeliverOrder = async (orderId) => {
    if (authLoading) return;
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
        throw new Error(errorData.detail || t("orders.failedToDeliver"));
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
        <h2>{t("orders.orderManagement")}</h2>
        <div style={{ display: "flex", gap: "1rem", alignItems: "center" }}>
          {filterConsumerId && (
            <button
              className="refresh-button"
              onClick={() => setFilterConsumerId(null)}
              style={{ backgroundColor: "#f69606ff" }}
            >
              {t("orders.showAllOrders")}
            </button>
          )}
          <button className="refresh-button" onClick={fetchOrders} disabled={loading}>
            {loading ? t("common.processing") : t("common.refresh")}
          </button>
        </div>
      </div>

      {error && <div className="error-banner">{error}</div>}

      <div className="orders-stats">
        <div className="stat-card">
          <div className="stat-icon pending-icon">🗋</div>
          <div className="stat-info">
            <h3>{stats.pending}</h3>
            <p>{t("orders.pendingOrders")}</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon processing-icon">⚙</div>
          <div className="stat-info">
            <h3>{stats.processing}</h3>
            <p>{t("orders.processing")}</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon completed-icon">✔</div>
          <div className="stat-info">
            <h3>{stats.completed}</h3>
            <p>{t("orders.completed")}</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon revenue-icon">🤑</div>
          <div className="stat-info">
            <h3>{formatCurrency(stats.revenue)}</h3>
            <p>{t("orders.totalRevenue")}</p>
          </div>
        </div>
      </div>

      {filterConsumerId && (
        <div className="filter-message">
          <strong>{t("orders.filtered")}</strong> {t("orders.showingOrdersFrom")} {filterConsumerId}
        </div>
      )}

      {loading && filteredOrders.length === 0 && (
        <div className="loading-state">{t("orders.loadingOrders")}</div>
      )}

      {!loading && filteredOrders.length === 0 && !error && (
        <div className="empty-state">
          {filterConsumerId 
            ? `${t("orders.noOrdersForConsumer")} ${filterConsumerId}.` 
            : t("orders.noOrdersFound")}
        </div>
      )}

      <div className="orders-list">
        {filteredOrders.map((order) => (
          <div key={order.id} className="supplier-order-card">
            <div className="order-header-section">
              <div className="order-main-info">
                <h3 className="order-id">{t("orders.orderNumber", { id: order.id })}</h3>
                <span className={`order-status ${getStatusColor(order.status)}`}>
                  {t(`orders.${order.status === "approved" ? "processing" : order.status}`)}
                </span>
              </div>
              <div className="order-customer">
                <span className="customer-name">{order.consumer_name || t("orders.consumer")}</span>
                <span className="customer-type">{t("orders.consumer")}</span>
              </div>
            </div>

            <div className="order-info-grid">
              <div className="info-item">
                <span className="info-icon">📅</span>
                <div className="info-content">
                  <span className="info-label">{t("orders.orderDate")}</span>
                  <span className="info-value">{formatDate(order.created_at)}</span>
                </div>
              </div>
              {order.updated_at && (
                <div className="info-item">
                  <span className="info-icon">🔄</span>
                  <div className="info-content">
                    <span className="info-label">{t("orders.lastUpdate")}</span>
                    <span className="info-value">{formatDate(order.updated_at)}</span>
                  </div>
                </div>
              )}
            </div>

            <div className="order-items">
              <h4 className="items-title">{t("orders.orderItems")}</h4>
              <div className="items-table">
                <div className="table-header">
                  <span>{t("products.productName")}</span>
                  <span>{t("catalog.quantity")}</span>
                  <span>{t("products.price")}</span>
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
                <span className="total-label">{t("orders.totalAmount")}</span>
                <span className="total-amount">{formatCurrency(order.total_price)}</span>
              </div>
              <div className="order-actions">
                {is_catalog_manager(role) && order.status === "pending" && (
                  <>
                    <button
                      className="action-btn accept-btn"
                      onClick={() => handleAcceptOrder(order.id)}
                      disabled={actionLoading === order.id}
                    >
                      {actionLoading === order.id ? t("common.processing") : t("orders.acceptOrder")}
                    </button>
                    <button
                      className="action-btn reject-btn"
                      onClick={() => handleRejectOrder(order.id)}
                      disabled={actionLoading === order.id}
                    >
                      {actionLoading === order.id ? t("common.processing") : t("orders.reject")}
                    </button>
                  </>
                )}
                {is_catalog_manager(role) && order.status === "approved" && (
                  <button
                    className="action-btn complete-btn"
                    onClick={() => handleDeliverOrder(order.id)}
                    disabled={actionLoading === order.id}
                  >
                    {actionLoading === order.id ? t("common.processing") : t("orders.markAsDelivered")}
                  </button>
                )}
                {is_catalog_manager(role) && order.status === "delivered" && (
                  <button className="action-btn invoice-btn" disabled>
                    {t("orders.generateInvoice")}
                  </button>
                )}
                <button
                  className="action-btn details-btn"
                  onClick={() => setSelectedOrderId(order.id)}
                >
                  {t("orders.viewDetails")}
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
