import "./ConsumerOrders.css";

const dummyOrders = [
  {
    id: "ORD-2024-001",
    supplier: "Fresh Farm Products",
    orderDate: "2024-10-05",
    deliveryDate: "2024-10-06",
    status: "delivered",
    total: 45000,
    items: [
      { name: "Tomatoes", quantity: "20 kg", price: 15000 },
      { name: "Cucumbers", quantity: "15 kg", price: 12000 },
      { name: "Lettuce", quantity: "10 kg", price: 8000 },
      { name: "Peppers", quantity: "12 kg", price: 10000 }
    ]
  },
  {
    id: "ORD-2024-002",
    supplier: "Premium Meat Supply",
    orderDate: "2024-10-07",
    deliveryDate: "2024-10-07",
    status: "in-transit",
    total: 85000,
    items: [
      { name: "Beef", quantity: "25 kg", price: 50000 },
      { name: "Chicken", quantity: "20 kg", price: 25000 },
      { name: "Lamb", quantity: "5 kg", price: 10000 }
    ]
  },
  {
    id: "ORD-2024-003",
    supplier: "Dairy Dreams Co.",
    orderDate: "2024-10-08",
    deliveryDate: "2024-10-09",
    status: "pending",
    total: 32000,
    items: [
      { name: "Milk", quantity: "50 L", price: 15000 },
      { name: "Cheese", quantity: "10 kg", price: 12000 },
      { name: "Butter", quantity: "5 kg", price: 5000 }
    ]
  },
  {
    id: "ORD-2024-004",
    supplier: "Fresh Farm Products",
    orderDate: "2024-09-28",
    deliveryDate: "2024-09-29",
    status: "cancelled",
    total: 28000,
    items: [
      { name: "Tomatoes", quantity: "15 kg", price: 11250 },
      { name: "Peppers", quantity: "10 kg", price: 8333 },
      { name: "Lettuce", quantity: "10 kg", price: 8000 }
    ]
  },
  {
    id: "ORD-2024-009",
    supplier: "LOL",
    orderDate: "2024-20-07",
    deliveryDate: "2024-60-07",
    status: "in-transit",
    total: 125000,
    items: [
      { name: "Bee", quantity: "2 kg", price: 50000 },
      { name: "Chicken", quantity: "20 kg", price: 25000 },
      { name: "Lamb", quantity: "5 kg", price: 10000 }
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
        <div className="header-filters">
          <select className="filter-select">
            <option value="all">All Orders</option>
            <option value="pending">Pending</option>
            <option value="in-transit">In Transit</option>
            <option value="delivered">Delivered</option>
            <option value="cancelled">Cancelled</option>
          </select>
          <input 
            type="text" 
            placeholder="Search orders..." 
            className="search-input"
          />
        </div>
      </div>

      <div className="orders-stats">
        <div className="stat-card">
          <div className="stat-icon pending-icon">⏳</div>
          <div className="stat-info">
            <h3>1</h3>
            <p>Pending</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon transit-icon">🚚</div>
          <div className="stat-info">
            <h3>1</h3>
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
            <h3>4</h3>
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