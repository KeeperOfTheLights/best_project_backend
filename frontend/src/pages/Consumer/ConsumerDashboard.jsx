import "./ConsumerDashboard.css";
import { Link } from "react-router-dom";
import React from 'react';

export default function ConsumerDashboard() {
  const stats = {
    completed: 18,
    inProgress: 4,
    cancelled: 2,
    totalSpent: 1450000,
  };

  return (
    <div className="consumer-dashboard-container">
      <h2></h2>
      <header className="dashboard-header">
        <h2>Welcome back!</h2>
        <p>Here’s an overview of your order activity.</p>
      </header>

      <section className="dashboard-stats">
        <div className="stat-card completed">
          <h3>{stats.completed}</h3>
          <p>Completed Orders</p>
        </div>
        <div className="stat-card in-progress">
          <h3>{stats.inProgress}</h3>
          <p>Orders in Progress</p>
        </div>
        <div className="stat-card cancelled">
          <h3>{stats.cancelled}</h3>
          <p>Cancelled Orders</p>
        </div>
        <div className="stat-card total">
          <h3>{stats.totalSpent.toLocaleString()} ₸</h3>
          <p>Total Spent</p>
        </div>
      </section>

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
