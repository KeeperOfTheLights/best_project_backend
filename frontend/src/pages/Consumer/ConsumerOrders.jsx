import "./ConsumerOrders.css";
import React from 'react';

const dummyOrders = [
  {
    id: "ORD-2025-haha",
    supplier: "Magnum",
    orderDate: "2019",
    deliveryDate: "2018",
    status: "delivered",
    total: 450000,
    items: [
      { name: "Diddy Oil", quantity: "20 kg", price: 15000 },
      { name: "Cucumbers", quantity: "15 kg", price: 12000 },
      { name: "Lettuce", quantity: "10 kg", price: 8000 },
      { name: "Chicken meat", quantity: "12 kg", price: 10000 }
    ]
  }
];

const getStatusColor = (status) => {
  switch (status) {
    case "delivered":
      return "status-delivered";
    case "in-transit":
      return "status-transit";
    case "pending":
      return "status-pending";
    case "cancelled":
      return "status-cancelled";
    default:
      return "";
  }
};

const getStatusText = (status) => {
  switch (status) {
    case "delivered":
      return "Delivered";
    case "in-transit":
      return "In Transit";
    case "pending":
      return "Pending";
    case "cancelled":
      return "Cancelled";
    default:
      return status;
  }
};

export default function ConsumerOrders() {
  return (
    <div className="orders-container">
      <div className="orders-header">
        <h2>My Orders</h2>
      </div>

      <div className="orders-stats">
        <div className="stat-card">
          <div className="stat-icon pending-icon">⏳</div>
          <div className="stat-info">
            <h3>0</h3>
            <p>Pending</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon transit-icon">🚚</div>
          <div className="stat-info">
            <h3>0</h3>
            <p>In Transit</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon delivered-icon">✓</div>
          <div className="stat-info">
            <h3>1</h3>
            <p>Delivered</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon total-icon">📦</div>
          <div className="stat-info">
            <h3>1</h3>
            <p>Total Orders</p>
          </div>
        </div>
      </div>

      <div className="orders-list">
        {dummyOrders.map((order) => (
          <div key={order.id} className="order-card">
            <div className="order-header-section">
              <div className="order-main-info">
                <h3 className="order-id">{order.id}</h3>
                <span className={`order-status ${getStatusColor(order.status)}`}>
                  {getStatusText(order.status)}
                </span>
              </div>
              <div className="order-supplier">
                <span className="supplier-label">Supplier:</span>
                <span className="supplier-name">{order.supplier}</span>
              </div>
            </div>

            <div className="order-dates">
              <div className="date-item">
                <span className="date-label">Order Date:</span>
                <span className="date-value">{order.orderDate}</span>
              </div>
              <div className="date-item">
                <span className="date-label">Delivery Date:</span>
                <span className="date-value">{order.deliveryDate}</span>
              </div>
            </div>

            <div className="order-items">
              <h4 className="items-title">Order Items:</h4>
              <div className="items-grid">
                {order.items.map((item, index) => (
                  <div key={index} className="item-row">
                    <span className="item-name">{item.name}</span>
                    <span className="item-quantity">{item.quantity}</span>
                    <span className="item-price">{item.price.toLocaleString()} ₸</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="order-footer">
              <div className="order-total">
                <span className="total-label">Total:</span>
                <span className="total-amount">{order.total.toLocaleString()} ₸</span>
              </div>
              <div className="order-actions">
                {order.status === "pending" && (
                  <button className="action-btn cancel-btn">Cancel Order</button>
                )}
                {order.status === "delivered" && (
                  <button className="action-btn reorder-btn">Reorder</button>
                )}
                <button className="action-btn details-btn">View Details</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}