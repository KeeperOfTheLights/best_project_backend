import React from "react";
import { Link } from "react-router-dom";
import "./SupplierDashboard.css";

export default function SupplierDashboard() {
  const stats = {
    activeOrders: 8,
    completedOrders: 27,
    pendingDeliveries: 4,
    totalRevenue: 12540,
  };

  return (
    <div className="supplier-dashboard-container">
      <header className="dashboard-header">
        <h2>Welcome Back!</h2>
        <p>Here’s an overview of your performance and current activity.</p>
      </header>

      <section className="dashboard-stats">
        <div className="stat-card active">
          <h3>{stats.activeOrders}</h3>
          <p>Active Orders</p>
        </div>
        <div className="stat-card completed">
          <h3>{stats.completedOrders}</h3>
          <p>Completed Orders</p>
        </div>
        <div className="stat-card pending">
          <h3>{stats.pendingDeliveries}</h3>
          <p>Pending Deliveries</p>
        </div>
        <div className="stat-card revenue">
          <h3>${stats.totalRevenue.toLocaleString()}</h3>
          <p>Total Revenue</p>
        </div>
      </section>

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
