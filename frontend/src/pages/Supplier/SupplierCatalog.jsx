import React, { useState, useEffect } from "react";
import "./SupplierCatalog.css";

export default function SupplierLinkRequests() {
  const [requests, setRequests] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");
  const [actionLoading, setActionLoading] = useState(null);

  const API_BASE = "http://127.0.0.1:8000/api/accounts";

  // ----- FETCH LINK REQUESTS -----
  const fetchRequests = async () => {
    setLoading(true);
    setErrorMsg("");
    const token = localStorage.getItem("token");

    if (!token) {
      setErrorMsg("No authentication token found. Please login again.");
      setLoading(false);
      return;
    }

    try {
      const res = await fetch(`${API_BASE}/links/`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (res.status === 401) {
        setErrorMsg("Authentication failed. Please login again.");
        localStorage.removeItem("token");
        setLoading(false);
        return;
      }

      if (!res.ok) throw new Error("Failed to fetch requests");
      const data = await res.json();
      
      setRequests(data);
    } catch (err) {
      console.error(err);
      setErrorMsg(err.message);
      setRequests([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRequests();
  }, []);

  // ----- ACCEPT REQUEST -----
  const handleAccept = async (linkId) => {
    const token = localStorage.getItem("token");
    setActionLoading(linkId);
    setErrorMsg("");

    try {
      const res = await fetch(`${API_BASE}/link/${linkId}/accept/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || "Failed to accept request");
      }

      await fetchRequests();
    } catch (err) {
      console.error(err);
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  // ----- REJECT REQUEST -----
  const handleReject = async (linkId) => {
    if (!window.confirm("Reject this link request?")) return;

    const token = localStorage.getItem("token");
    setActionLoading(linkId);
    setErrorMsg("");

    try {
      const res = await fetch(`${API_BASE}/link/${linkId}/reject/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || "Failed to reject request");
      }

      await fetchRequests();
    } catch (err) {
      console.error(err);
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  // ----- BLOCK CONSUMER -----
  const handleBlock = async (linkId) => {
    if (!window.confirm("Block this consumer? They won't be able to send requests again.")) return;

    const token = localStorage.getItem("token");
    setActionLoading(linkId);
    setErrorMsg("");

    try {
      const res = await fetch(`${API_BASE}/link/${linkId}/block/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || "Failed to block consumer");
      }

      await fetchRequests();
    } catch (err) {
      console.error(err);
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  // ----- UNBLOCK CONSUMER -----
  const handleUnblock = async (linkId) => {
    if (!window.confirm("Unblock this consumer?")) return;

    const token = localStorage.getItem("token");
    setActionLoading(linkId);
    setErrorMsg("");

    try {
      const res = await fetch(`${API_BASE}/link/${linkId}/unblock/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || "Failed to unblock consumer");
      }

      await fetchRequests();
    } catch (err) {
      console.error(err);
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  // ----- UNLINK CONSUMER -----
  const handleUnlink = async (linkId) => {
    if (!window.confirm("Unlink this consumer? They will lose access to your catalog.")) return;

    const token = localStorage.getItem("token");
    setActionLoading(linkId);
    setErrorMsg("");

    try {
      const res = await fetch(`${API_BASE}/link/${linkId}/`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || "Failed to unlink consumer");
      }

      await fetchRequests();
    } catch (err) {
      console.error(err);
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const filteredRequests = filterStatus === "all" 
    ? requests 
    : requests.filter(r => r.status === filterStatus);

  const counts = {
    all: requests.length,
    pending: requests.filter(r => r.status === "pending").length,
    linked: requests.filter(r => r.status === "linked").length,
    rejected: requests.filter(r => r.status === "rejected").length,
    blocked: requests.filter(r => r.status === "blocked").length
  };

  if (loading) return <p>Loading link requests...</p>;

  return (
    <div className="link-requests-container">
      <div className="requests-header">
        <h2>Consumer Link Requests</h2>
        <p className="requests-subtitle">Manage consumer connections and access</p>
      </div>

      {errorMsg && (
        <div className="error-message">
          {errorMsg}
          <button 
            onClick={() => setErrorMsg("")}
            style={{ marginLeft: '10px', cursor: 'pointer' }}
          >
            ✕
          </button>
        </div>
      )}

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
            <h3>{counts.linked}</h3>
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
          className={`filter-btn ${filterStatus === "linked" ? "active" : ""}`}
          onClick={() => setFilterStatus("linked")}
        >
          Linked ({counts.linked})
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
            <div className="request-content">
              <div className="request-header-info">
                <h3 className="consumer-name">{request.consumer_name || 'Unknown Consumer'}</h3>
                <span className={`request-status-badge ${request.status}`}>
                  {request.status === "pending" && "⏳ Pending"}
                  {request.status === "linked" && "✓ Linked"}
                  {request.status === "rejected" && "✕ Rejected"}
                  {request.status === "blocked" && "🚫 Blocked"}
                </span>
              </div>

              <div className="request-details">
                <div className="detail-row">
                  <span className="detail-icon">📅</span>
                  <span className="detail-text">
                    Request Date: {new Date(request.created_at).toLocaleDateString()}
                  </span>
                </div>
                <div className="detail-row">
                  <span className="detail-icon">🆔</span>
                  <span className="detail-text">Consumer ID: {request.consumer}</span>
                </div>
              </div>

              <div className="request-actions">
                {request.status === "pending" && (
                  <>
                    <button 
                      className="action-btn accept-btn"
                      onClick={() => handleAccept(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      {actionLoading === request.id ? "Processing..." : "✓ Accept"}
                    </button>
                    <button 
                      className="action-btn reject-btn"
                      onClick={() => handleReject(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      ✕ Reject
                    </button>
                    <button 
                      className="action-btn block-btn"
                      onClick={() => handleBlock(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      🚫 Block
                    </button>
                  </>
                )}

                {request.status === "linked" && (
                  <>
                    <button 
                      className="action-btn view-orders-btn"
                      onClick={() => alert(`View orders from ${request.consumer_name}`)}
                    >
                      View Orders
                    </button>
                    <button 
                      className="action-btn message-btn"
                      onClick={() => alert(`Message ${request.consumer_name}`)}
                    >
                      Message
                    </button>
                    <button 
                      className="action-btn unlink-btn"
                      onClick={() => handleUnlink(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      {actionLoading === request.id ? "Unlinking..." : "Unlink"}
                    </button>
                  </>
                )}

                {request.status === "rejected" && (
                  <>
                    <span className="status-message">Request was rejected</span>
                    <button 
                      className="action-btn accept-btn"
                      onClick={() => handleAccept(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      {actionLoading === request.id ? "Processing..." : "Accept Now"}
                    </button>
                    <button 
                      className="action-btn block-btn"
                      onClick={() => handleBlock(request.id)}
                      disabled={actionLoading === request.id}
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
                      disabled={actionLoading === request.id}
                    >
                      {actionLoading === request.id ? "Unblocking..." : "Unblock"}
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