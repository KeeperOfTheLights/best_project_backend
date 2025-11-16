import React, { useState } from "react";
import "./SupplierCatalog.css";

const dummyLinkRequests = [
  {
    id: 1,
    consumerName: "Green Leaf Restaurant",
    consumerType: "Restaurant",
    location: "Almaty, Kazakhstan",
    email: "contact@greenleaf.kz",
    phone: "+7 777 123 4567",
    requestDate: "2024-11-10",
    status: "pending",
    estimatedMonthlyOrder: 150000,
    image: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400"
  },
  {
    id: 2,
    consumerName: "Mountain Resort Hotel",
    consumerType: "Hotel",
    location: "Borovoe, Kazakhstan",
    email: "procurement@mountainresort.kz",
    phone: "+7 777 234 5678",
    requestDate: "2024-11-12",
    status: "pending",
    estimatedMonthlyOrder: 300000,
    image: "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400"
  },
  {
    id: 3,
    consumerName: "City Bistro",
    consumerType: "Cafe",
    location: "Astana, Kazakhstan",
    email: "orders@citybistro.kz",
    phone: "+7 777 345 6789",
    requestDate: "2024-11-05",
    status: "approved",
    estimatedMonthlyOrder: 80000,
    image: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400"
  },
  {
    id: 4,
    consumerName: "Sunset Lounge",
    consumerType: "Restaurant",
    location: "Shymkent, Kazakhstan",
    email: "info@sunsetlounge.kz",
    phone: "+7 777 456 7890",
    requestDate: "2024-11-08",
    status: "rejected",
    estimatedMonthlyOrder: 120000,
    image: "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=400"
  },
  {
    id: 5,
    consumerName: "Plaza Hotel & Spa",
    consumerType: "Hotel",
    location: "Almaty, Kazakhstan",
    email: "purchasing@plazahotel.kz",
    phone: "+7 777 567 8901",
    requestDate: "2024-11-01",
    status: "blocked",
    estimatedMonthlyOrder: 200000,
    image: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400"
  }
];

export default function SupplierLinkRequests() {
  const [requests, setRequests] = useState(dummyLinkRequests);
  const [filterStatus, setFilterStatus] = useState("all");

  const handleAccept = (requestId) => {
    setRequests(requests.map(r => 
      r.id === requestId ? { ...r, status: "approved" } : r
    ));
    alert(`Link request approved for ID: ${requestId}`);
  };

  const handleReject = (requestId) => {
    if (window.confirm("Reject this link request?")) {
      setRequests(requests.map(r => 
        r.id === requestId ? { ...r, status: "rejected" } : r
      ));
    }
  };

  const handleBlock = (requestId) => {
    if (window.confirm("Block this consumer? They won't be able to send requests again.")) {
      setRequests(requests.map(r => 
        r.id === requestId ? { ...r, status: "blocked" } : r
      ));
    }
  };

  const handleUnlink = (requestId) => {
    if (window.confirm("Unlink this consumer? They will lose access to your catalog.")) {
      setRequests(requests.map(r => 
        r.id === requestId ? { ...r, status: "pending" } : r
      ));
    }
  };

  const handleUnblock = (requestId) => {
    if (window.confirm("Unblock this consumer?")) {
      setRequests(requests.map(r => 
        r.id === requestId ? { ...r, status: "rejected" } : r
      ));
    }
  };

  const filteredRequests = filterStatus === "all" 
    ? requests 
    : requests.filter(r => r.status === filterStatus);

  const counts = {
    all: requests.length,
    pending: requests.filter(r => r.status === "pending").length,
    approved: requests.filter(r => r.status === "approved").length,
    rejected: requests.filter(r => r.status === "rejected").length,
    blocked: requests.filter(r => r.status === "blocked").length
  };

  return (
    <div className="link-requests-container">
      <div className="requests-header">
        <h2>Consumer Link Requests</h2>
        <p className="requests-subtitle">Manage consumer connections and access</p>
      </div>

      <div className="requests-stats">
        <div className="stat-card">
          <div className="stat-icon pending-icon">⏳</div>
          <div className="stat-info">
            <h3>{counts.pending}</h3>
            <p>Pending Requests</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon approved-icon">✓</div>
          <div className="stat-info">
            <h3>{counts.approved}</h3>
            <p>Linked Consumers</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon rejected-icon">✕</div>
          <div className="stat-info">
            <h3>{counts.rejected}</h3>
            <p>Rejected</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon blocked-icon">🚫</div>
          <div className="stat-info">
            <h3>{counts.blocked}</h3>
            <p>Blocked</p>
          </div>
        </div>
      </div>

      <div className="requests-filters">
        <button 
          className={`filter-btn ${filterStatus === "all" ? "active" : ""}`}
          onClick={() => setFilterStatus("all")}
        >
          All ({counts.all})
        </button>
        <button 
          className={`filter-btn ${filterStatus === "pending" ? "active" : ""}`}
          onClick={() => setFilterStatus("pending")}
        >
          Pending ({counts.pending})
        </button>
        <button 
          className={`filter-btn ${filterStatus === "approved" ? "active" : ""}`}
          onClick={() => setFilterStatus("approved")}
        >
          Linked ({counts.approved})
        </button>
        <button 
          className={`filter-btn ${filterStatus === "rejected" ? "active" : ""}`}
          onClick={() => setFilterStatus("rejected")}
        >
          Rejected ({counts.rejected})
        </button>
        <button 
          className={`filter-btn ${filterStatus === "blocked" ? "active" : ""}`}
          onClick={() => setFilterStatus("blocked")}
        >
          Blocked ({counts.blocked})
        </button>
      </div>

      <div className="requests-list">
        {filteredRequests.map((request) => (
          <div key={request.id} className="request-card">
            <div className="request-image-wrapper">
              <img src={request.image} alt={request.consumerName} className="request-image" />
              <span className={`request-status-badge ${request.status}`}>
                {request.status === "pending" && "⏳ Pending"}
                {request.status === "approved" && "✓ Linked"}
                {request.status === "rejected" && "✕ Rejected"}
                {request.status === "blocked" && "🚫 Blocked"}
              </span>
            </div>

            <div className="request-content">
              <div className="request-header-info">
                <h3 className="consumer-name">{request.consumerName}</h3>
                <span className="consumer-type-badge">{request.consumerType}</span>
              </div>

              <div className="request-details">
                <div className="detail-row">
                  <span className="detail-icon">📍</span>
                  <span className="detail-text">{request.location}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-icon">📧</span>
                  <span className="detail-text">{request.email}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-icon">📞</span>
                  <span className="detail-text">{request.phone}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-icon">📅</span>
                  <span className="detail-text">Request Date: {request.requestDate}</span>
                </div>
                <div className="detail-row highlight">
                  <span className="detail-icon">💰</span>
                  <span className="detail-text">
                    Est. Monthly Order: <strong>{request.estimatedMonthlyOrder.toLocaleString()} ₸</strong>
                  </span>
                </div>
              </div>

              <div className="request-actions">
                {request.status === "pending" && (
                  <>
                    <button 
                      className="action-btn accept-btn"
                      onClick={() => handleAccept(request.id)}
                    >
                      ✓ Accept
                    </button>
                    <button 
                      className="action-btn reject-btn"
                      onClick={() => handleReject(request.id)}
                    >
                      ✕ Reject
                    </button>
                    <button 
                      className="action-btn block-btn"
                      onClick={() => handleBlock(request.id)}
                    >
                      🚫 Block
                    </button>
                  </>
                )}

                {request.status === "approved" && (
                  <>
                    <button 
                      className="action-btn view-orders-btn"
                      onClick={() => alert(`View orders from ${request.consumerName}`)}
                    >
                      View Orders
                    </button>
                    <button 
                      className="action-btn message-btn"
                      onClick={() => alert(`Message ${request.consumerName}`)}
                    >
                      Message
                    </button>
                    <button 
                      className="action-btn unlink-btn"
                      onClick={() => handleUnlink(request.id)}
                    >
                      Unlink
                    </button>
                  </>
                )}

                {request.status === "rejected" && (
                  <>
                    <span className="status-message">Request was rejected</span>
                    <button 
                      className="action-btn accept-btn"
                      onClick={() => handleAccept(request.id)}
                    >
                      Accept Now
                    </button>
                    <button 
                      className="action-btn block-btn"
                      onClick={() => handleBlock(request.id)}
                    >
                      Block
                    </button>
                  </>
                )}

                {request.status === "blocked" && (
                  <>
                    <span className="status-message blocked">Consumer is blocked</span>
                    <button 
                      className="action-btn unblock-btn"
                      onClick={() => handleUnblock(request.id)}
                    >
                      Unblock
                    </button>
                  </>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredRequests.length === 0 && (
        <div className="empty-state">
          <p>No requests found with status: {filterStatus}</p>
        </div>
      )}
    </div>
  );
}