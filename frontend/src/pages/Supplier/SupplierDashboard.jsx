import React, { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import { is_catalog_manager, is_owner, is_sales } from "../../utils/roleUtils";
import "./SupplierDashboard.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function SupplierDashboard() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { token, logout, role, loading: authLoading } = useAuth();
  const [stats, setStats] = useState({
    active_orders: 0,
    completed_orders: 0,
    pending_deliveries: 0,
    total_revenue: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (authLoading) return;
    
    if (!is_sales(role)) {
      fetchStats();
    } else {
      setLoading(false);
    }
  }, [token, role, authLoading]);

  const fetchStats = async () => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/orders/supplier/stats/`, {
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
        throw new Error(text || t("dashboard.failedToLoad"));
      }

      const data = await res.json();
      setStats({
        active_orders: data.active_orders || 0,
        completed_orders: data.completed_orders || 0,
        pending_deliveries: data.pending_deliveries || 0,
        total_revenue: data.total_revenue || 0,
      });
    } catch (err) {
      setError(err.message || t("dashboard.failedToLoad"));
    } finally {
      setLoading(false);
    }
  };

  const getGreeting = () => {
    if (role === "owner") return t("dashboard.helloOwner");
    if (role === "manager") return t("dashboard.helloManager");
    if (role === "sales") return t("dashboard.helloSales");
    return t("dashboard.welcomeBack");
  };

  const getSubtitle = () => {
    if (is_sales(role)) return t("dashboard.manageCommunications");
    return t("dashboard.overview");
  };

  return (
    <div className="supplier-dashboard-container">
      <header className="dashboard-header">
        <h2>{getGreeting()}</h2>
        <p>{getSubtitle()}</p>
      </header>

      {error && (
        <div className="error-banner">
          {error}
          <button onClick={fetchStats} style={{ marginLeft: "1rem", padding: "0.5rem 1rem" }}>
            {t("common.retry")}
          </button>
        </div>
      )}

      {!is_sales(role) && (
        <>
          {loading ? (
            <div className="loading-state">{t("dashboard.loadingStatistics")}</div>
          ) : (
            <section className="dashboard-stats">
              <div className="stat-card active">
                <h3>{stats.active_orders}</h3>
                <p>{t("dashboard.activeOrders")}</p>
              </div>
              <div className="stat-card completed">
                <h3>{stats.completed_orders}</h3>
                <p>{t("dashboard.completedOrders")}</p>
              </div>
              <div className="stat-card pending">
                <h3>{stats.pending_deliveries}</h3>
                <p>{t("dashboard.pendingDeliveries")}</p>
              </div>
              <div className="stat-card revenue">
                <h3>{Number(stats.total_revenue || 0).toLocaleString()} ₸</h3>
                <p>{t("dashboard.totalRevenue")}</p>
              </div>
            </section>
          )}
        </>
      )}

      <section className="quick-actions">
        <h3>{t("dashboard.quickActions")}</h3>
        <div className="actions-grid">
          <Link to="/SupplierOrders" className="action-btn orders-btn">
            {t("dashboard.viewOrders")}
          </Link>
          <Link to="/supplier/complaints" className="action-btn complaints-btn">
            {t("dashboard.manageComplaints")}
          </Link>
          {is_catalog_manager(role) && (
            <Link to="/SupplierCatalog" className="action-btn catalog-btn">
              {t("dashboard.manageLinks")}
            </Link>
          )}
          {is_catalog_manager(role) && (
            <Link to="/supplier/products" className="action-btn catalog-btn">
              {t("dashboard.editCatalog")}
            </Link>
          )}
          {is_owner(role) && (
            <Link to="/supplier/company" className="action-btn company-btn">
              {t("dashboard.manageCompany")}
            </Link>
          )}
          <Link to="/Chat" className="action-btn support-btn">
            {t("dashboard.openChat")}
          </Link>
        </div>
      </section>
    </div>
  );
}
