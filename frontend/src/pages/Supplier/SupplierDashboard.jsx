import React, { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import { is_catalog_manager, is_owner, is_sales } from "../../utils/roleUtils";
import "./SupplierDashboard.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function SupplierDashboard() {
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
        throw new Error(text || "Failed to load statistics");
      }

      const data = await res.json();
      setStats({
        active_orders: data.active_orders || 0,
        completed_orders: data.completed_orders || 0,
        pending_deliveries: data.pending_deliveries || 0,
        total_revenue: data.total_revenue || 0,
      });
    } catch (err) {
      setError(err.message || "Failed to load statistics");
    } finally {
      setLoading(false);
    }
  };

  const getGreeting = () => {
    if (role === "owner") return "Hello, Owner!";
    if (role === "manager") return "Hello, Manager!";
    if (role === "sales") return "Hello, Sales Representative!";
    return "Welcome Back!";
  };

  const getSubtitle = () => {
    if (is_sales(role)) return "Manage your communications and handle customer inquiries.";
    return "Here's an overview of your performance and current activity.";
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
            Retry
          </button>
        </div>
      )}

      {!is_sales(role) && (
        <>
          {loading ? (
            <div className="loading-state">Loading statistics...</div>
          ) : (
            <section className="dashboard-stats">
              <div className="stat-card active">
                <h3>{stats.active_orders}</h3>
                <p>Active Orders</p>
              </div>
              <div className="stat-card completed">
                <h3>{stats.completed_orders}</h3>
                <p>Completed Orders</p>
              </div>
              <div className="stat-card pending">
                <h3>{stats.pending_deliveries}</h3>
                <p>Pending Deliveries</p>
              </div>
              <div className="stat-card revenue">
                <h3>{Number(stats.total_revenue || 0).toLocaleString()} ₸</h3>
                <p>Total Revenue</p>
              </div>
            </section>
          )}
        </>
      )}

      <section className="quick-actions">
        <h3>Quick Actions</h3>
        <div className="actions-grid">
          <Link to="/SupplierOrders" className="action-btn orders-btn">
            View Orders
          </Link>
          <Link to="/supplier/complaints" className="action-btn complaints-btn">
            Manage Complaints
          </Link>
          {is_catalog_manager(role) && (
            <Link to="/SupplierCatalog" className="action-btn catalog-btn">
              Manage Links
            </Link>
          )}
          {is_catalog_manager(role) && (
            <Link to="/supplier/products" className="action-btn catalog-btn">
              Edit Catalog
            </Link>
          )}
          {is_owner(role) && (
            <Link to="/supplier/company" className="action-btn company-btn">
              Manage Company
            </Link>
          )}
          <Link to="/Chat" className="action-btn support-btn">
            Open Chat
          </Link>
        </div>
      </section>
    </div>
  );
}
