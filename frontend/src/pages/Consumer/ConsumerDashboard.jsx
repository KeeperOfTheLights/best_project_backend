import "./ConsumerDashboard.css";
import { Link } from "react-router-dom";
import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function ConsumerDashboard() {
  const navigate = useNavigate();
  const { token, logout, loading: authLoading } = useAuth();
  const [stats, setStats] = useState({
    completed_orders: 0,
    in_progress_orders: 0,
    cancelled_orders: 0,
    total_spent: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (authLoading) return;
    fetchStats();
  }, [token, authLoading]);

  const fetchStats = async () => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/orders/stats/`, {
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
        completed_orders: data.completed_orders || 0,
        in_progress_orders: data.in_progress_orders || 0,
        cancelled_orders: data.cancelled_orders || 0,
        total_spent: data.total_spent || 0,
      });
    } catch (err) {
      setError(err.message || "Failed to load statistics");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="consumer-dashboard-container">
      <h2></h2>
      <header className="dashboard-header">
        <h2>Welcome back!</h2>
        <p>Here’s an overview of your order activity.</p>
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
          <div className="stat-card completed">
            <h3>{stats.completed_orders}</h3>
            <p>Completed Orders</p>
          </div>
          <div className="stat-card in-progress">
            <h3>{stats.in_progress_orders}</h3>
            <p>Orders in Progress</p>
          </div>
          <div className="stat-card cancelled">
            <h3>{stats.cancelled_orders}</h3>
            <p>Cancelled Orders</p>
          </div>
          <div className="stat-card total">
            <h3>{Number(stats.total_spent || 0).toLocaleString()} ₸</h3>
            <p>Total Spent</p>
          </div>
        </section>
      )}

      <section className="quick-actions">
        <h3>Quick Actions</h3>
        <div className="actions-grid">
          <Link to="/ConsumerCatalog" className="action-btn browse-btn">Browse Catalog</Link>
         
          <Link to="/Chat" className="action-btn support-btn">Open Chat</Link>
          <Link to="/ConsumerOrders" className="action-btn orders-btn">View All Orders</Link>
        </div>
      </section>
    </div>
  );
}
