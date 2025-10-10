import "./SupplierOrders.css";

const dummyOrders = [
  {
    id: "ORD-2024-001",
    customer: "Green Leaf Restaurant",
    customerType: "Restaurant",
    orderDate: "2024-10-05",
    deliveryDate: "2024-10-06",
    status: "completed",
    total: 45000,
    items: [
      { name: "Tomatoes", quantity: "20 kg", price: 15000 },
      { name: "Cucumbers", quantity: "15 kg", price: 12000 },
      { name: "Lettuce", quantity: "10 kg", price: 8000 },
      { name: "Peppers", quantity: "12 kg", price: 10000 }
    ],
    deliveryAddress: "123 Main Street, Almaty"
  },
  {
    id: "ORD-2024-002",
    customer: "Cozy Cafe",
    customerType: "Cafe",
    orderDate: "2024-10-07",
    deliveryDate: "2024-10-08",
    status: "processing",
    total: 32000,
    items: [
      { name: "Tomatoes", quantity: "15 kg", price: 11250 },
      { name: "Cucumbers", quantity: "10 kg", price: 8000 },
      { name: "Lettuce", quantity: "8 kg", price: 6400 },
      { name: "Peppers", quantity: "8 kg", price: 6667 }
    ],
    deliveryAddress: "456 Park Avenue, Almaty"
  },
  {
    id: "ORD-2024-003",
    customer: "Mountain Resort Hotel",
    customerType: "Hotel",
    orderDate: "2024-10-08",
    deliveryDate: "2024-10-09",
    status: "pending",
    total: 78000,
    items: [
      { name: "Tomatoes", quantity: "40 kg", price: 30000 },
      { name: "Cucumbers", quantity: "30 kg", price: 24000 },
      { name: "Lettuce", quantity: "15 kg", price: 12000 },
      { name: "Peppers", quantity: "15 kg", price: 12500 }
    ],
    deliveryAddress: "789 Mountain Road, Almaty Region"
  },
  {
    id: "ORD-2024-004",
    customer: "City Bistro",
    customerType: "Restaurant",
    orderDate: "2024-09-30",
    deliveryDate: "2024-10-01",
    status: "cancelled",
    total: 25000,
    items: [
      { name: "Tomatoes", quantity: "12 kg", price: 9000 },
      { name: "Cucumbers", quantity: "10 kg", price: 8000 },
      { name: "Peppers", quantity: "10 kg", price: 8333 }
    ],
    deliveryAddress: "321 Center Street, Astana"
  }
];

const getStatusColor = (status) => {
  switch (status) {
    case "completed":
      return "status-completed";
    case "processing":
      return "status-processing";
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
    case "completed":
      return "Completed";
    case "processing":
      return "Processing";
    case "pending":
      return "Pending";
    case "cancelled":
      return "Cancelled";
    default:
      return status;
  }
};

export default function SupplierOrders() {
  return (
    <div className="supplier-orders-container">
      <div className="orders-header">
        <h2>Order Management</h2>
        <div className="header-filters">
          <select className="filter-select">
            <option value="all">All Orders</option>
            <option value="pending">Pending</option>
            <option value="processing">Processing</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </select>
          <input 
            type="text" 
            placeholder="Search by order ID or customer..." 
            className="search-input"
          />
        </div>
      </div>

      <div className="orders-stats">
        <div className="stat-card">
          <div className="stat-icon pending-icon">📋</div>
          <div className="stat-info">
            <h3>1</h3>
            <p>Pending Orders</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon processing-icon">⚙️</div>
          <div className="stat-info">
            <h3>1</h3>
            <p>Processing</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon completed-icon">✓</div>
          <div className="stat-info">
            <h3>1</h3>
            <p>Completed</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon revenue-icon">💰</div>
          <div className="stat-info">
            <h3>180k ₸</h3>
            <p>Total Revenue</p>
          </div>
        </div>
      </div>

      <div className="orders-list">
        {dummyOrders.map((order) => (
          <div key={order.id} className="supplier-order-card">
            <div className="order-header-section">
              <div className="order-main-info">
                <h3 className="order-id">{order.id}</h3>
                <span className={`order-status ${getStatusColor(order.status)}`}>
                  {getStatusText(order.status)}
                </span>
              </div>
              <div className="order-customer">
                <span className="customer-name">{order.customer}</span>
                <span className="customer-type">{order.customerType}</span>
              </div>
            </div>

            <div className="order-info-grid">
              <div className="info-item">
                <span className="info-icon">📅</span>
                <div className="info-content">
                  <span className="info-label">Order Date</span>
                  <span className="info-value">{order.orderDate}</span>
                </div>
              </div>
              <div className="info-item">
                <span className="info-icon">🚚</span>
                <div className="info-content">
                  <span className="info-label">Delivery Date</span>
                  <span className="info-value">{order.deliveryDate}</span>
                </div>
              </div>
              <div className="info-item">
                <span className="info-icon">📍</span>
                <div className="info-content">
                  <span className="info-label">Delivery Address</span>
                  <span className="info-value">{order.deliveryAddress}</span>
                </div>
              </div>
            </div>

            <div className="order-items">
              <h4 className="items-title">Order Items</h4>
              <div className="items-table">
                <div className="table-header">
                  <span>Product</span>
                  <span>Quantity</span>
                  <span>Price</span>
                </div>
                {order.items.map((item, index) => (
                  <div key={index} className="table-row">
                    <span className="item-name">{item.name}</span>
                    <span className="item-quantity">{item.quantity}</span>
                    <span className="item-price">{item.price.toLocaleString()} ₸</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="order-footer">
              <div className="order-total">
                <span className="total-label">Total Amount:</span>
                <span className="total-amount">{order.total.toLocaleString()} ₸</span>
              </div>
              <div className="order-actions">
                {order.status === "pending" && (
                  <>
                    <button className="action-btn accept-btn">Accept Order</button>
                    <button className="action-btn reject-btn">Reject</button>
                  </>
                )}
                {order.status === "processing" && (
                  <button className="action-btn complete-btn">Mark as Complete</button>
                )}
                {order.status === "completed" && (
                  <button className="action-btn invoice-btn">Generate Invoice</button>
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