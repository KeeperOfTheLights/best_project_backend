import React from "react";
import "./SupplierDashboard.css";

const SupplierDashboard = () => {
  return (
    <div className="supplier-dashboard">
      <h1 className="dashboard-title">Welcome Back!</h1>
      <p className="dashboard-subtitle">
        Here’s an overview of your performance and current activity.
      </p>

      <div className="dashboard-stats">
        <div className="stat-card">
          <h2>Active Orders</h2>
          <p>8</p>
        </div>
        <div className="stat-card">
          <h2>Completed Orders</h2>
          <p>27</p>
        </div>
        <div className="stat-card">
          <h2>Pending Deliveries</h2>
          <p>4</p>
        </div>
        <div className="stat-card">
          <h2>Total Revenue</h2>
          <p>$12,540</p>
        </div>
      </div>

      

      <div className="section">
        <h2>Recent Feedback</h2>
        <div className="feedback">
          <p>⭐ "High quality and fast delivery!" — Green Café</p>
          <p>⭐ "Excellent packaging, will reorder soon." — Hotel Luna</p>
          <p>⭐ "A bit delayed this time, but products were fresh." — Ocean Restaurant</p>
        </div>
      </div>
    </div>
  );
};

export default SupplierDashboard;
