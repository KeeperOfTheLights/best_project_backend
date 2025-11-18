import React, { useState, useEffect } from "react";
import { useAuth } from "../../context/Auth-Context";
import { useNavigate } from "react-router-dom";
import "./ConsumerCatalog.css";

export default function ConsumerLinkManagement() {
  const { token, logout } = useAuth();
  const navigate = useNavigate();

  const [suppliers, setSuppliers] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");
  const [actionLoading, setActionLoading] = useState(null);

  const API_BASE = "http://127.0.0.1:8000/api/accounts";

  // ----- FETCH SUPPLIERS AND LINKS -----
  const fetchSuppliers = async () => {
    setLoading(true);
    setErrorMsg("");

    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    try {
      const resSuppliers = await fetch(`${API_BASE}/suppliers/`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (resSuppliers.status === 401) {
        setErrorMsg("Authentication failed. Please login again.");
        logout();
        navigate("/login");
        return;
      }

      if (!resSuppliers.ok) throw new Error("Failed to fetch suppliers");
      const allSuppliers = await resSuppliers.json();

      const resLinks = await fetch(`${API_BASE}/consumer/links/`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (resLinks.status === 401) {
        setErrorMsg("Authentication failed. Please login again.");
        logout();
        navigate("/login");
        return;
      }

      if (!resLinks.ok) throw new Error("Failed to fetch links");
      const linksData = await resLinks.json();

      const mapped = allSuppliers.map((sup) => {
        const link = linksData.find((l) => Number(l.supplier) === Number(sup.id));

        return {
          id: sup.id,
          linkId: link?.id,
          name: sup.full_name,
          company: sup.supplier_company || "N/A",
          email: sup.email,
          username: sup.username,
          linkStatus: link ? link.status : "not_linked",
        };
      });

      setSuppliers(mapped);
    } catch (err) {
      console.error(err);
      setErrorMsg(err.message);
      setSuppliers([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSuppliers();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [token]);

  // ----- SEND LINK REQUEST -----
  const handleSendRequest = async (supplierId) => {
    const supplier = suppliers.find((s) => s.id === supplierId);
    if (supplier && supplier.linkStatus !== "not_linked" && supplier.linkStatus !== "rejected") {
      setErrorMsg(`Cannot send request - link already exists with status: ${supplier.linkStatus}`);
      return;
    }

    setActionLoading(supplierId);
    setErrorMsg("");

    // Optimistic UI update
    setSuppliers((prev) =>
      prev.map((s) => (s.id === supplierId ? { ...s, linkStatus: "pending" } : s))
    );

    try {
      const res = await fetch(`${API_BASE}/link/send/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ supplier_id: supplierId }),
      });

      if (res.status === 401) {
        setErrorMsg("Authentication failed. Please login again.");
        logout();
        navigate("/login");
        return;
      }

      const responseText = await res.text();
      let data;
      try {
        data = JSON.parse(responseText);
      } catch {
        data = { detail: responseText };
      }

      if (!res.ok) {
        await fetchSuppliers();
        throw new Error(data.detail || data.message || "Failed to send link request");
      }

      await fetchSuppliers();
    } catch (err) {
      console.error("Send request error:", err.message);
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  // ----- CANCEL / UNLINK -----
  const handleDeleteLink = async (supplierId) => {
    const supplier = suppliers.find((s) => s.id === supplierId);
    if (!supplier || !supplier.linkId) {
      setErrorMsg("No link found. Please refresh the page and try again.");
      await fetchSuppliers();
      return;
    }

    const confirmMessage =
      supplier.linkStatus === "pending"
        ? "Are you sure you want to cancel this request?"
        : "Are you sure you want to unlink this supplier?";

    if (!window.confirm(confirmMessage)) return;

    setActionLoading(supplierId);
    setErrorMsg("");

    try {
      const res = await fetch(`${API_BASE}/link/${supplier.linkId}/`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.status === 401) {
        setErrorMsg("Authentication failed. Please login again.");
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || `Failed: ${res.status}`);
      }

      await fetchSuppliers();
    } catch (err) {
      console.error(err);
      setErrorMsg(err.message || "Error deleting link");
    } finally {
      setActionLoading(null);
    }
  };

  // ----- FILTERING -----
  const filteredSuppliers =
    filterStatus === "all"
      ? suppliers
      : suppliers.filter((s) => s.linkStatus === filterStatus);

  const counts = {
    all: suppliers.length,
    linked: suppliers.filter((s) => s.linkStatus === "linked").length,
    pending: suppliers.filter((s) => s.linkStatus === "pending").length,
    not_linked: suppliers.filter((s) => s.linkStatus === "not_linked").length,
    rejected: suppliers.filter((s) => s.linkStatus === "rejected").length,
  };

  if (loading) return <p>Loading suppliers...</p>;

  return (
    <div className="link-management-container">
      <div className="link-header">
        <h2>Supplier Connections</h2>
        <p className="link-subtitle">Manage your supplier relationships</p>
      </div>

      {errorMsg && (
        <div className="error-message">
          {errorMsg}
          <button onClick={() => setErrorMsg("")} style={{ marginLeft: "10px", cursor: "pointer" }}>
            ✕
          </button>
        </div>
      )}

      {/* Stats */}
      <div className="link-stats">
        <div className="stat-card">
          <div className="stat-icon approved-icon">✓</div>
          <div className="stat-info">
            <h3>{counts.linked}</h3>
            <p>Linked</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon pending-icon">⏳</div>
          <div className="stat-info">
            <h3>{counts.pending}</h3>
            <p>Pending</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon available-icon">🔍</div>
          <div className="stat-info">
            <h3>{counts.not_linked}</h3>
            <p>Available</p>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="link-filters">
        {["all", "linked", "pending", "not_linked", "rejected"].map((status) => (
          <button
            key={status}
            className={`filter-btn ${filterStatus === status ? "active" : ""}`}
            onClick={() => setFilterStatus(status)}
          >
            {status.replace("_", " ")} ({counts[status] || 0})
          </button>
        ))}
      </div>

      {/* Supplier Cards */}
      <div className="suppliers-grid">
        {filteredSuppliers.map((supplier) => (
          <div key={supplier.id} className="supplier-link-card">
            <div className="supplier-content">
              <h3 className="supplier-name">{supplier.name}</h3>
              <p className="supplier-email">📧 {supplier.email}</p>

              <div className="link-actions">
                {supplier.linkStatus === "not_linked" ? (
                  <button
                    className="link-btn send-request-btn"
                    onClick={() => handleSendRequest(supplier.id)}
                    disabled={actionLoading === supplier.id}
                  >
                    {actionLoading === supplier.id ? "Sending..." : "Send Link Request"}
                  </button>
                ) : supplier.linkStatus === "pending" ? (
                  <button
                    className="link-btn cancel-btn"
                    onClick={() => handleDeleteLink(supplier.id)}
                    disabled={actionLoading === supplier.id}
                  >
                    {actionLoading === supplier.id ? "Cancelling..." : "Cancel Request"}
                  </button>
                ) : supplier.linkStatus === "linked" ? (
                  <>
                    <button
                      className="link-btn view-catalog-btn"
                      onClick={() => alert(`View catalog for ${supplier.name}`)}
                    >
                      View Catalog
                    </button>
                    <button
                      className="link-btn unlink-btn"
                      onClick={() => handleDeleteLink(supplier.id)}
                      disabled={actionLoading === supplier.id}
                    >
                      {actionLoading === supplier.id ? "Unlinking..." : "Unlink"}
                    </button>
                  </>
                ) : supplier.linkStatus === "rejected" ? (
                  <>
                    <span className="rejected-message">Request was rejected</span>
                    <button
                      className="link-btn send-request-btn"
                      onClick={() => handleSendRequest(supplier.id)}
                      disabled={actionLoading === supplier.id}
                    >
                      {actionLoading === supplier.id ? "Sending..." : "Send Again"}
                    </button>
                  </>
                ) : null}
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredSuppliers.length === 0 && (
        <div className="empty-state">
          <p>No suppliers found with the status: {filterStatus}</p>
        </div>
      )}
    </div>
  );
}
