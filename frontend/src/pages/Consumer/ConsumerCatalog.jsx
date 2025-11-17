import React, { useState, useEffect } from "react";
import "./ConsumerCatalog.css";

export default function ConsumerLinkManagement() {
  const [suppliers, setSuppliers] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");

  const API_BASE = "http://127.0.0.1:8000/api/accounts";

  // ----- FETCH SUPPLIERS AND LINKS -----
  const fetchSuppliers = async () => {
    setLoading(true);
    setErrorMsg("");
    const token = localStorage.getItem("token");

    try {
      // 1. Все поставщики
      const resSuppliers = await fetch(`${API_BASE}/suppliers/`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!resSuppliers.ok) throw new Error("Failed to fetch suppliers");
      const allSuppliers = await resSuppliers.json();

      // 2. Ссылки пользователя
      const resLinks = await fetch(`${API_BASE}/links/`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!resLinks.ok) throw new Error("Failed to fetch links");
      const linksData = await resLinks.json();

      // 3. Объединяем
      const mapped = allSuppliers.map((sup) => {
        const link = linksData.find((l) => l.id === sup.id);
        return {
          id: sup.id,
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

      if (!res.ok) throw new Error(`Failed: ${res.status}`);
      fetchSuppliers();
    } catch (err) {
      console.error(err);
      setErrorMsg("Error sending link request");
    }
  };

  // ----- CANCEL / UNLINK -----
  const handleDeleteLink = async (supplierId) => {
    if (!window.confirm("Are you sure?")) return;
    const token = localStorage.getItem("token");

    try {
      const res = await fetch(`${API_BASE}/link/${supplierId}/`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) throw new Error(`Failed: ${res.status}`);
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
              className={`filter-btn ${
                filterStatus === status ? "active" : ""
              }`}
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
                {supplier.linkStatus === "not_linked" && (
                  <button
                    className="link-btn send-request-btn"
                    onClick={() => handleSendRequest(supplier.id)}
                  >
                    Send Link Request
                  </button>
                )}
                {supplier.linkStatus === "pending" && (
                  <button
                    className="link-btn cancel-btn"
                    onClick={() => handleDeleteLink(supplier.id)}
                  >
                    Cancel Request
                  </button>
                )}
                {supplier.linkStatus === "approved" && (
                  <>
                    <button
                      className="link-btn view-catalog-btn"
                      onClick={() =>
                        alert(`View catalog for ${supplier.name}`)
                      }
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
                )}
                {supplier.linkStatus === "rejected" && (
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
                )}
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
