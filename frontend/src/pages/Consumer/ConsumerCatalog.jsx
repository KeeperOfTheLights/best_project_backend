import React, { useState, useEffect } from "react";
import "./ConsumerCatalog.css";

export default function ConsumerLinkManagement() {
  const [suppliers, setSuppliers] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");
  const [pendingRequests, setPendingRequests] = useState(
    JSON.parse(localStorage.getItem("pendingRequests")) || []
  );

  const API_BASE = "http://127.0.0.1:8000/api/accounts";

  // ----- FETCH SUPPLIERS AND LINKS -----
  const fetchSuppliers = async () => {
    setLoading(true);
    setErrorMsg("");
    const token = localStorage.getItem("token");

    try {
      const resSuppliers = await fetch(`${API_BASE}/suppliers/`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!resSuppliers.ok) throw new Error("Failed to fetch suppliers");
      const allSuppliers = await resSuppliers.json();

      const resLinks = await fetch(`${API_BASE}/links/`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!resLinks.ok) throw new Error("Failed to fetch links");
      const linksData = await resLinks.json();

      const mapped = allSuppliers.map((sup) => {
        const link = linksData.find(
          (l) => Number(l.supplier) === Number(sup.id)
        );

        return {
          id: sup.id,          // supplier id
          linkId: link?.id,    // ссылка id
          name: sup.full_name,
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
  }, []);

  // ----- SEND LINK REQUEST -----
  const handleSendRequest = async (supplierId) => {
    const token = localStorage.getItem("token");
    try {
      const res = await fetch(`${API_BASE}/link/send/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ supplier_id: supplierId }),
      });

      const responseText = await res.text();
      let data;
      try {
        data = JSON.parse(responseText);
      } catch {
        data = { detail: responseText };
      }

      if (!res.ok) {
        throw new Error(data.detail || data.message || "Failed to send link request");
      }

      // Добавляем в pending-запросы для UI
      setPendingRequests((prev) => {
        const updated = [...prev, supplierId];
        localStorage.setItem("pendingRequests", JSON.stringify(updated));
        return updated;
      });

      fetchSuppliers();
    } catch (err) {
      console.error("Send request error:", err.message);
      setErrorMsg(err.message);
    }
  };

  // ----- CANCEL / UNLINK -----
  const handleDeleteLink = async (supplierId) => {
    const supplier = suppliers.find((s) => s.id === supplierId);
    if (!supplier || !supplier.linkId) {
      setErrorMsg("No link to delete");
      return;
    }

    if (!window.confirm("Are you sure?")) return;

    const token = localStorage.getItem("token");
    try {
      const res = await fetch(`${API_BASE}/link/${supplier.linkId}/`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) throw new Error(`Failed: ${res.status}`);

      // Удаляем из pending-запросов
      setPendingRequests((prev) => {
        const updated = prev.filter((id) => id !== supplierId);
        localStorage.setItem("pendingRequests", JSON.stringify(updated));
        return updated;
      });

      fetchSuppliers();
    } catch (err) {
      console.error(err);
      setErrorMsg("Error deleting link");
    }
  };

  // ----- FILTERING -----
  const filteredSuppliers =
    filterStatus === "all"
      ? suppliers
      : suppliers.filter((s) => s.linkStatus === filterStatus);

  const counts = {
    all: suppliers.length,
    approved: suppliers.filter((s) => s.linkStatus === "approved").length,
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

      {errorMsg && <p className="error-message">{errorMsg}</p>}

      {/* Stats */}
      <div className="link-stats">
        <div className="stat-card">
          <div className="stat-icon approved-icon">✓</div>
          <div className="stat-info">
            <h3>{counts.approved}</h3>
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
        {["all", "approved", "pending", "not_linked", "rejected"].map(
          (status) => (
            <button
              key={status}
              className={`filter-btn ${filterStatus === status ? "active" : ""}`}
              onClick={() => setFilterStatus(status)}
            >
              {status} ({counts[status] || 0})
            </button>
          )
        )}
      </div>

      {/* Supplier Cards */}
      <div className="suppliers-grid">
        {filteredSuppliers.map((supplier) => (
          <div key={supplier.id} className="supplier-link-card">
            <div className="supplier-content">
              <h3 className="supplier-name">{supplier.name}</h3>
              <p className="supplier-email">📧 {supplier.email}</p>

              <div className="link-actions">
                {supplier.linkStatus === "not_linked" &&
                !pendingRequests.includes(supplier.id) ? (
                  <button
                    className="link-btn send-request-btn"
                    onClick={() => handleSendRequest(supplier.id)}
                  >
                    Send Link Request
                  </button>
                ) : supplier.linkStatus === "pending" ||
                  pendingRequests.includes(supplier.id) ? (
                  <button
                    className="link-btn cancel-btn"
                    onClick={() => handleDeleteLink(supplier.id)}
                  >
                    Cancel Request
                  </button>
                ) : supplier.linkStatus === "approved" ? (
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
                    >
                      Unlink
                    </button>
                  </>
                ) : supplier.linkStatus === "rejected" ? (
                  <>
                    <span className="rejected-message">
                      Request was rejected
                    </span>
                    <button
                      className="link-btn send-request-btn"
                      onClick={() => handleSendRequest(supplier.id)}
                    >
                      Send Again
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
