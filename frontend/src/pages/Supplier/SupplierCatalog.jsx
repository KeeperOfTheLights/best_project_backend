import React, { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import { is_catalog_manager } from "../../utils/roleUtils";
import "./SupplierCatalog.css";

export default function SupplierLinkRequests() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { role, loading: authLoading } = useAuth();
  const [requests, setRequests] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");
  const [actionLoading, setActionLoading] = useState(null);

  // modal state
  const [modalData, setModalData] = useState({
    visible: false,
    action: null,
    linkId: null,
    message: "",
  });

  const API_BASE = "http://127.0.0.1:8000/api/accounts";

  const fetchRequests = async () => {
    if (authLoading) return;
    
    setLoading(true);
    setErrorMsg("");
    const token = localStorage.getItem("token");

    if (!token) {
      setErrorMsg("No authentication token found. Redirecting to login...");
      setLoading(false);
      navigate("/login");
      return;
    }

    try {
      const res = await fetch(`${API_BASE}/links/`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (res.status === 401) {
        setErrorMsg("Authentication failed. Redirecting to login...");
        localStorage.removeItem("token");
        setLoading(false);
        navigate("/login");
        return;
      }

      if (!res.ok) throw new Error(t("catalog.failedToFetch"));

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
    if (authLoading) return;
    fetchRequests();
  }, [authLoading]);

  const openModal = (action, linkId, message) => {
    setModalData({
      visible: true,
      action,
      linkId,
      message,
    });
  };

  const closeModal = () => {
    setModalData({
      visible: false,
      action: null,
      linkId: null,
      message: "",
    });
  };

  const confirmModalAction = async () => {
    const { action, linkId } = modalData;

    if (action === "unlink") await performUnlink(linkId);
    if (action === "block") await performBlock(linkId);
    if (action === "reject") await performReject(linkId);

    closeModal();
  };

  const performReject = async (linkId) => {
    const token = localStorage.getItem("token");
    setActionLoading(linkId);

    try {
      const res = await fetch(`${API_BASE}/link/${linkId}/reject/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) throw new Error(t("catalog.failedToReject"));
      await fetchRequests();
    } catch (err) {
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const performBlock = async (linkId) => {
    const token = localStorage.getItem("token");
    setActionLoading(linkId);

    try {
      const res = await fetch(`${API_BASE}/link/${linkId}/block/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) throw new Error(t("catalog.failedToBlock"));
      await fetchRequests();
    } catch (err) {
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const performUnlink = async (linkId) => {
    const token = localStorage.getItem("token");
    setActionLoading(linkId);

    try {
      const res = await fetch(`${API_BASE}/link/${linkId}/`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) throw new Error(t("catalog.failedToUnlink"));
      await fetchRequests();
    } catch (err) {
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

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

      if (!res.ok) throw new Error(t("catalog.failedToAccept"));
      await fetchRequests();
    } catch (err) {
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const handleReject = (linkId) => {
    openModal("reject", linkId, t("catalog.rejectRequest"));
  };

  const handleBlock = (linkId) => {
    openModal(
      "block",
      linkId,
      t("catalog.blockConsumer")
    );
  };

  const handleUnblock = async (linkId) => {
    const token = localStorage.getItem("token");
    setActionLoading(linkId);

    try {
      const res = await fetch(`${API_BASE}/link/${linkId}/unblock/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) throw new Error(t("catalog.failedToUnblock"));
      await fetchRequests();
    } catch (err) {
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const handleUnlink = (linkId) => {
    openModal(
      "unlink",
      linkId,
      t("catalog.unlinkConsumer")
    );
  };

  const filteredRequests =
    filterStatus === "all"
      ? requests
      : requests.filter((r) => r.status === filterStatus);

  const counts = {
    all: requests.length,
    pending: requests.filter((r) => r.status === "pending").length,
    linked: requests.filter((r) => r.status === "linked").length,
    rejected: requests.filter((r) => r.status === "rejected").length,
    blocked: requests.filter((r) => r.status === "blocked").length,
  };

  if (!is_catalog_manager(role)) {
    return (
      <div className="link-requests-container">
        <div className="error-message" style={{ padding: "2rem", textAlign: "center" }}>
          <h2>{t("common.error")}</h2>
          <p>{t("catalog.accessDenied")}</p>
          <button onClick={() => navigate("/SupplierDashboard")} style={{ marginTop: "1rem", padding: "0.5rem 1rem" }}>
            {t("dashboard.viewOrders")}
          </button>
        </div>
      </div>
    );
  }

  if (loading) return <p>{t("catalog.loadingLinkRequests")}</p>;

  return (
    <div className="link-requests-container">
      <div className="requests-header">
        <h2>{t("catalog.consumerLinkRequests")}</h2>
        <p className="requests-subtitle">
          {t("catalog.manageConnections")}
        </p>
      </div>

      {errorMsg && (
        <div className="error-message">
          {errorMsg}
          <button
            onClick={() => setErrorMsg("")}
            style={{ marginLeft: "10px", cursor: "pointer" }}
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
            <p>{t("catalog.pendingRequests")}</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon approved-icon">✔</div>
          <div className="stat-info">
            <h3>{counts.linked}</h3>
            <p>{t("catalog.linkedConsumers")}</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon rejected-icon">X</div>
          <div className="stat-info">
            <h3>{counts.rejected}</h3>
            <p>{t("catalog.rejected")}</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon blocked-icon">🫸</div>
          <div className="stat-info">
            <h3>{counts.blocked}</h3>
            <p>{t("catalog.blocked")}</p>
          </div>
        </div>
      </div>

      <div className="requests-filters">
        <button
          className={`filter-btn ${filterStatus === "all" ? "active" : ""}`}
          onClick={() => setFilterStatus("all")}
        >
          {t("common.all")} ({counts.all})
        </button>
        <button
          className={`filter-btn ${
            filterStatus === "pending" ? "active" : ""
          }`}
          onClick={() => setFilterStatus("pending")}
        >
          {t("catalog.pending")} ({counts.pending})
        </button>
        <button
          className={`filter-btn ${filterStatus === "linked" ? "active" : ""}`}
          onClick={() => setFilterStatus("linked")}
        >
          {t("catalog.linked")} ({counts.linked})
        </button>
        <button
          className={`filter-btn ${
            filterStatus === "rejected" ? "active" : ""
          }`}
          onClick={() => setFilterStatus("rejected")}
        >
          {t("catalog.rejected")} ({counts.rejected})
        </button>
        <button
          className={`filter-btn ${
            filterStatus === "blocked" ? "active" : ""
          }`}
          onClick={() => setFilterStatus("blocked")}
        >
          {t("catalog.blocked")} ({counts.blocked})
        </button>
      </div>

      <div className="requests-list">
        {filteredRequests.map((request) => (
          <div key={request.id} className="request-card">
            <div className="request-content">
              <div className="request-header-info">
                <h3 className="consumer-name">
                  {request.consumer_name || t("catalog.unknownConsumer")}
                </h3>
                <span className={`request-status-badge ${request.status}`}>
                  {request.status === "pending" && `⏳ ${t("catalog.pending")}`}
                  {request.status === "linked" && `✔ ${t("catalog.linked")}`}
                  {request.status === "rejected" && `X ${t("catalog.rejected")}`}
                  {request.status === "blocked" && `🫸 ${t("catalog.blocked")}`}
                </span>
              </div>

              <div className="request-details">
                <div className="detail-row">
                  <span className="detail-icon">📅</span>
                  <span className="detail-text">
                    {t("catalog.requestDate")}{" "}
                    {new Date(request.created_at).toLocaleDateString()}
                  </span>
                </div>
                <div className="detail-row">
                  <span className="detail-icon">🆔</span>
                  <span className="detail-text">
                    {t("catalog.consumerId")} {request.consumer}
                  </span>
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
                      {actionLoading === request.id
                        ? t("common.processing")
                        : `✔ ${t("catalog.accept")}`}
                    </button>

                    <button
                      className="action-btn reject-btn"
                      onClick={() => handleReject(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      X {t("catalog.reject")}
                    </button>

                    <button
                      className="action-btn block-btn"
                      onClick={() => handleBlock(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      🫸 {t("catalog.block")}
                    </button>
                  </>
                )}

                {request.status === "linked" && (
                  <>
                    <button
                      className="action-btn view-orders-btn"
                      onClick={() =>
                        navigate("/SupplierOrders", {
                          state: { filterConsumerId: request.consumer },
                        })
                      }
                    >
                      {t("catalog.viewOrders")}
                    </button>
                    <button
                      className="action-btn message-btn"
                      onClick={() =>
                        navigate("/chat", {
                          state: { selectConsumerId: request.consumer },
                        })
                      }
                    >
                      {t("catalog.message")}
                    </button>
                    <button
                      className="action-btn unlink-btn"
                      onClick={() => handleUnlink(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      {actionLoading === request.id
                        ? t("common.processing")
                        : t("catalog.unlink")}
                    </button>
                  </>
                )}

                {request.status === "rejected" && (
                  <>
                    <span className="status-message">{t("catalog.requestWasRejected")}</span>

                    <button
                      className="action-btn accept-btn"
                      onClick={() => handleAccept(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      {actionLoading === request.id
                        ? t("common.processing")
                        : t("catalog.acceptNow")}
                    </button>

                    <button
                      className="action-btn block-btn"
                      onClick={() => handleBlock(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      {t("catalog.block")}
                    </button>
                  </>
                )}

                {request.status === "blocked" && (
                  <>
                    <span className="status-message blocked">
                      {t("catalog.consumerIsBlocked")}
                    </span>

                    <button
                      className="action-btn unblock-btn"
                      onClick={() => handleUnblock(request.id)}
                      disabled={actionLoading === request.id}
                    >
                      {actionLoading === request.id
                        ? t("common.processing")
                        : t("catalog.unblock")}
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
          <p>{t("catalog.noRequestsFound")} {filterStatus}</p>
        </div>
      )}

      {modalData.visible && (
        <div className="modal-overlay">
          <div className="modal-window">
            <h3 className="modal-title">{t("catalog.confirmAction")}</h3>
            <p className="modal-message">{modalData.message}</p>

            <div className="modal-buttons">
              <button className="modal-btn cancel" onClick={closeModal}>
                {t("common.cancel")}
              </button>
              <button className="modal-btn confirm" onClick={confirmModalAction}>
                {t("common.confirm")}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
