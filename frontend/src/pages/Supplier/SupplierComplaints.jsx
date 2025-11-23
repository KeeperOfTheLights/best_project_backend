import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import { is_sales } from "../../utils/roleUtils";
import "./SupplierComplaints.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function SupplierComplaints() {
  const navigate = useNavigate();
  const { token, logout, role, loading: authLoading } = useAuth();
  const [complaints, setComplaints] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [actionLoading, setActionLoading] = useState(null);

  const fetchComplaints = async () => {
    if (authLoading) return;
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/complaints/supplier/`, {
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
        throw new Error(text || "Failed to load complaints");
      }

      const data = await res.json();
      setComplaints(Array.isArray(data) ? data : []);
    } catch (err) {
      setError(err.message || "Failed to load complaints");
      setComplaints([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (authLoading) return;
    fetchComplaints();
  }, [token, authLoading]);

  const handleResolve = async (complaintId) => {
    if (authLoading) return;
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setActionLoading(complaintId);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/complaints/${complaintId}/resolve/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || "Failed to resolve complaint");
      }

      await fetchComplaints();
    } catch (err) {
      setError(err.message || "Failed to resolve complaint");
    } finally {
      setActionLoading(null);
    }
  };

  const handleReject = async (complaintId) => {
    if (authLoading) return;
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setActionLoading(complaintId);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/complaints/${complaintId}/reject/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || "Failed to reject complaint");
      }

      await fetchComplaints();
    } catch (err) {
      setError(err.message || "Failed to reject complaint");
    } finally {
      setActionLoading(null);
    }
  };

  const handleEscalate = async (complaintId) => {
    if (authLoading) return;
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setActionLoading(complaintId);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/complaints/${complaintId}/escalate/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || "Failed to escalate complaint");
      }

      await fetchComplaints();
    } catch (err) {
      setError(err.message || "Failed to escalate complaint");
    } finally {
      setActionLoading(null);
    }
  };

  const handleFilterChange = (status) => setFilterStatus(status);

  const filteredComplaints =
    filterStatus === "all"
      ? complaints
      : complaints.filter((c) => c.status.toLowerCase() === filterStatus.toLowerCase());

  const formatDate = (value) => {
    if (!value) return "-";
    try {
      return new Date(value).toLocaleDateString();
    } catch {
      return value;
    }
  };

  const getStatusLabel = (status) => {
    const statusMap = {
      pending: "Pending",
      resolved: "Resolved",
      rejected: "Rejected",
      escalated: "Escalated",
    };
    return statusMap[status?.toLowerCase()] || status;
  };

  const counts = {
    all: complaints.length,
    pending: complaints.filter((c) => c.status?.toLowerCase() === "pending").length,
    resolved: complaints.filter((c) => c.status?.toLowerCase() === "resolved").length,
    rejected: complaints.filter((c) => c.status?.toLowerCase() === "rejected").length,
    escalated: complaints.filter((c) => c.status?.toLowerCase() === "escalated").length,
  };

  const getComplaintDescription = () => {
    if (is_sales(role)) {
      return "Handle customer complaints and escalate when manager review is needed.";
    }
    return "Review escalated complaints and manage order-related issues.";
  };

  if (loading) {
    return (
      <div className="complaints-container">
        <p>Loading complaints...</p>
      </div>
    );
  }

  return (
    <div className="complaints-container">
      <div className="complaints-header-card">
        <div>
          <h2>Complaints Management</h2>
          <p style={{ color: "#6b6464ff", marginTop: "0.5rem", fontSize: "0.9rem" }}>
            {getComplaintDescription()}
          </p>
        </div>
        <button className="refresh-btn" onClick={fetchComplaints} disabled={loading}>
          {loading ? "Refreshing..." : "Refresh"}
        </button>
      </div>

      {error && (
        <div className="error-message">
          {error}
          <button onClick={() => setError("")} className="close-btn">
            X
          </button>
        </div>
      )}

      <div className="complaints-stats">
        {is_sales(role) ? (
          <>
            <div className="stat-card">
              <div className="stat-icon pending-icon">⏳</div>
              <div className="stat-info">
                <h3>{counts.pending}</h3>
                <p>Pending</p>
              </div>
            </div>
            <div className="stat-card">
              <div className="stat-icon resolved-icon">✔</div>
              <div className="stat-info">
                <h3>{counts.resolved}</h3>
                <p>Resolved</p>
              </div>
            </div>
            <div className="stat-card">
              <div className="stat-icon rejected-icon">X</div>
              <div className="stat-info">
                <h3>{counts.rejected}</h3>
                <p>Rejected</p>
              </div>
            </div>
          </>
        ) : (
          <div className="stat-card">
            <div className="stat-icon escalated-icon">💀</div>
            <div className="stat-info">
              <h3>{counts.escalated}</h3>
              <p>Escalated</p>
            </div>
          </div>
        )}
      </div>

      <div className="complaints-filters">
        {is_sales(role) ? (
          <>
            <button
              className={filterStatus === "all" ? "active" : ""}
              onClick={() => handleFilterChange("all")}
            >
              All ({counts.all})
            </button>
            <button
              className={filterStatus === "pending" ? "active" : ""}
              onClick={() => handleFilterChange("pending")}
            >
              Pending ({counts.pending})
            </button>
            <button
              className={filterStatus === "resolved" ? "active" : ""}
              onClick={() => handleFilterChange("resolved")}
            >
              Resolved ({counts.resolved})
            </button>
            <button
              className={filterStatus === "rejected" ? "active" : ""}
              onClick={() => handleFilterChange("rejected")}
            >
              Rejected ({counts.rejected})
            </button>
          </>
        ) : (
          <>
            <button
              className={filterStatus === "all" ? "active" : ""}
              onClick={() => handleFilterChange("all")}
            >
              All ({counts.all})
            </button>
            <button
              className={filterStatus === "escalated" ? "active" : ""}
              onClick={() => handleFilterChange("escalated")}
            >
              Escalated ({counts.escalated})
            </button>
          </>
        )}
      </div>

      <div className="complaints-list">
        {filteredComplaints.length === 0 ? (
          <div className="no-complaints">
            <p>No complaints found for this status.</p>
          </div>
        ) : (
          filteredComplaints.map((c) => (
            <div key={c.id} className={`complaint-card ${c.status?.toLowerCase()}`}>
              <div className="complaint-header">
                <h4>{c.title}</h4>
                <span className={`status-badge ${c.status?.toLowerCase()}`}>
                  {getStatusLabel(c.status)}
                </span>
              </div>
              <div className="complaint-info">
                <p>
                  <strong>Consumer:</strong> {c.consumer_name || `Consumer #${c.consumer}`}
                </p>
                <p>
                  <strong>Order ID:</strong> #{c.order}
                </p>
                <p className="complaint-description">{c.description}</p>
              </div>
              <div className="complaint-dates">
                <p>
                  <small>Created: {formatDate(c.created_at)}</small>
                </p>
                {c.resolved_at && (
                  <p>
                    <small>Resolved: {formatDate(c.resolved_at)}</small>
                  </p>
                )}
              </div>

              <div className="complaint-actions-row">
                <button
                  className="open-chat-btn"
                  onClick={() => navigate("/chat", { state: { selectConsumerId: c.consumer } })}
                >
                  Open Chat
                </button>
                {c.status?.toLowerCase() === "pending" && (
                  <div className="action-btns">
                    {is_sales(role) ? (
                      <>
                        <button
                          className="resolve-btn"
                          onClick={() => handleResolve(c.id)}
                          disabled={actionLoading === c.id}
                        >
                          {actionLoading === c.id ? "Processing..." : "Resolve"}
                        </button>
                        <button
                          className="reject-btn"
                          onClick={() => handleReject(c.id)}
                          disabled={actionLoading === c.id}
                        >
                          {actionLoading === c.id ? "Processing..." : "Reject"}
                        </button>
                        <button
                          className="escalate-btn"
                          onClick={() => handleEscalate(c.id)}
                          disabled={actionLoading === c.id}
                        >
                          {actionLoading === c.id ? "Processing..." : "Escalate"}
                        </button>
                      </>
                    ) : (
                      <>
                        <button
                          className="resolve-btn"
                          onClick={() => handleResolve(c.id)}
                          disabled={actionLoading === c.id}
                        >
                          {actionLoading === c.id ? "Processing..." : "Resolve"}
                        </button>
                        <button
                          className="reject-btn"
                          onClick={() => handleReject(c.id)}
                          disabled={actionLoading === c.id}
                        >
                          {actionLoading === c.id ? "Processing..." : "Reject"}
                        </button>
                      </>
                    )}
                  </div>
                )}
                {c.status?.toLowerCase() === "escalated" && !is_sales(role) && (
                  <div className="action-btns">
                    <button
                      className="resolve-btn"
                      onClick={() => handleResolve(c.id)}
                      disabled={actionLoading === c.id}
                    >
                      {actionLoading === c.id ? "Processing..." : "Resolve"}
                    </button>
                    <button
                      className="reject-btn"
                      onClick={() => handleReject(c.id)}
                      disabled={actionLoading === c.id}
                    >
                      {actionLoading === c.id ? "Processing..." : "Reject"}
                    </button>
                  </div>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
