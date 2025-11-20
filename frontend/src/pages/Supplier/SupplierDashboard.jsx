import React, { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import "./SupplierDashboard.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function SupplierDashboard() {
  const navigate = useNavigate();
  const { token, logout } = useAuth();
  const [stats, setStats] = useState({
    active_orders: 0,
    completed_orders: 0,
    pending_deliveries: 0,
    total_revenue: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchStats();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [token]);

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

  return (
    <div className="supplier-dashboard-container">
      <header className="dashboard-header">
        <h2>Welcome Back!</h2>
        <p>Here’s an overview of your performance and current activity.</p>
      </header>

      {error && (
        <div className="error-banner">
          {error}
          <button onClick={fetchStats} style={{ marginLeft: "1rem", padding: "0.5rem 1rem" }}>
            Retry
          </button>
        </div>
      )}

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

      <section className="quick-actions">
        <h3>Quick Actions</h3>
        <div className="actions-grid">
          <Link to="/SupplierOrders" className="action-btn orders-btn">
            View Orders
          </Link>
          <Link to="/supplier/complaints" className="action-btn complaints-btn">
            Manage Complaints
          </Link>
          <Link to="/SupplierCatalog" className="action-btn catalog-btn">
            Edit Catalog
          </Link>
          <Link to="/Chat" className="action-btn support-btn">
            Open Chat
          </Link>
        </div>
      </section>
    </div>
  );
}
