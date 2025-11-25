import React, { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import { is_sales } from "../../utils/roleUtils";
import "./SupplierComplaints.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function SupplierComplaints() {
  const { t } = useTranslation();
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
        throw new Error(text || t("complaints.failedToLoad"));
      }

      const data = await res.json();
      setComplaints(Array.isArray(data) ? data : []);
    } catch (err) {
      setError(err.message || t("complaints.failedToLoad"));
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
        throw new Error(errorData.detail || t("complaints.failedToResolve"));
      }

      await fetchComplaints();
    } catch (err) {
      setError(err.message || t("complaints.failedToResolve"));
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
        throw new Error(errorData.detail || t("complaints.failedToReject"));
      }

      await fetchComplaints();
    } catch (err) {
      setError(err.message || t("complaints.failedToReject"));
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
        throw new Error(errorData.detail || t("complaints.failedToEscalate"));
      }

      await fetchComplaints();
    } catch (err) {
      setError(err.message || t("complaints.failedToEscalate"));
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
      pending: t("complaints.pending"),
      resolved: t("complaints.resolved"),
      rejected: t("complaints.rejected"),
      escalated: t("complaints.escalated"),
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
      return t("complaints.salesDescription");
    }
    return t("complaints.managerDescription");
  };

  if (loading) {
    return (
      <div className="complaints-container">
        <p>{t("complaints.loadingComplaints")}</p>
      </div>
    );
  }

  return (
    <div className="complaints-container">
      <div className="complaints-header-card">
        <div>
          <h2>{t("complaints.supplierComplaints")}</h2>
          <p style={{ color: "#6b6464ff", marginTop: "0.5rem", fontSize: "0.9rem" }}>
            {getComplaintDescription()}
          </p>
        </div>
        <button className="refresh-btn" onClick={fetchComplaints} disabled={loading}>
          {loading ? t("common.processing") : t("common.refresh")}
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
                <p>{t("complaints.pending")}</p>
              </div>
            </div>
            <div className="stat-card">
              <div className="stat-icon resolved-icon">✔</div>
              <div className="stat-info">
                <h3>{counts.resolved}</h3>
                <p>{t("complaints.resolved")}</p>
              </div>
            </div>
            <div className="stat-card">
              <div className="stat-icon rejected-icon">X</div>
              <div className="stat-info">
                <h3>{counts.rejected}</h3>
                <p>{t("complaints.rejected")}</p>
              </div>
            </div>
          </>
        ) : (
          <div className="stat-card">
            <div className="stat-icon escalated-icon">💀</div>
            <div className="stat-info">
              <h3>{counts.escalated}</h3>
              <p>{t("complaints.escalated")}</p>
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
              {t("common.all")} ({counts.all})
            </button>
            <button
              className={filterStatus === "pending" ? "active" : ""}
              onClick={() => handleFilterChange("pending")}
            >
              {t("complaints.pending")} ({counts.pending})
            </button>
            <button
              className={filterStatus === "resolved" ? "active" : ""}
              onClick={() => handleFilterChange("resolved")}
            >
              {t("complaints.resolved")} ({counts.resolved})
            </button>
            <button
              className={filterStatus === "rejected" ? "active" : ""}
              onClick={() => handleFilterChange("rejected")}
            >
              {t("complaints.rejected")} ({counts.rejected})
            </button>
          </>
        ) : (
          <>
            <button
              className={filterStatus === "all" ? "active" : ""}
              onClick={() => handleFilterChange("all")}
            >
              {t("common.all")} ({counts.all})
            </button>
            <button
              className={filterStatus === "escalated" ? "active" : ""}
              onClick={() => handleFilterChange("escalated")}
            >
              {t("complaints.escalated")} ({counts.escalated})
            </button>
          </>
        )}
      </div>

      <div className="complaints-list">
        {filteredComplaints.length === 0 ? (
          <div className="no-complaints">
            <p>{t("complaints.noComplaints")}</p>
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
                  <strong>{t("orders.consumer")}:</strong> {c.consumer_name || t("orders.consumer")} #{c.consumer}
                </p>
                <p>
                  <strong>{t("orders.orderNumber", { id: "" }).replace("#", "")} ID:</strong> #{c.order}
                </p>
                <p className="complaint-description">{c.description}</p>
              </div>
              <div className="complaint-dates">
                <p>
                  <small>{t("complaints.created")}: {formatDate(c.created_at)}</small>
                </p>
                {c.resolved_at && (
                  <p>
                    <small>{t("complaints.resolved")}: {formatDate(c.resolved_at)}</small>
                  </p>
                )}
              </div>

              <div className="complaint-actions-row">
                <button
                  className="open-chat-btn"
                  onClick={() => navigate("/chat", { state: { selectConsumerId: c.consumer } })}
                >
                  {t("complaints.openChat")}
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
                          {actionLoading === c.id ? t("common.processing") : t("complaints.resolve")}
                        </button>
                        <button
                          className="reject-btn"
                          onClick={() => handleReject(c.id)}
                          disabled={actionLoading === c.id}
                        >
                          {actionLoading === c.id ? t("common.processing") : t("complaints.reject")}
                        </button>
                        <button
                          className="escalate-btn"
                          onClick={() => handleEscalate(c.id)}
                          disabled={actionLoading === c.id}
                        >
                          {actionLoading === c.id ? t("common.processing") : t("complaints.escalate")}
                        </button>
                      </>
                    ) : (
                      <>
                        <button
                          className="resolve-btn"
                          onClick={() => handleResolve(c.id)}
                          disabled={actionLoading === c.id}
                        >
                          {actionLoading === c.id ? t("common.processing") : t("complaints.resolve")}
                        </button>
                        <button
                          className="reject-btn"
                          onClick={() => handleReject(c.id)}
                          disabled={actionLoading === c.id}
                        >
                          {actionLoading === c.id ? t("common.processing") : t("complaints.reject")}
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
                      {actionLoading === c.id ? t("common.processing") : t("complaints.resolve")}
                    </button>
                    <button
                      className="reject-btn"
                      onClick={() => handleReject(c.id)}
                      disabled={actionLoading === c.id}
                    >
                      {actionLoading === c.id ? t("common.processing") : t("complaints.reject")}
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
