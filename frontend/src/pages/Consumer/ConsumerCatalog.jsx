import React, { useState, useEffect } from "react";
import { useAuth } from "../../context/Auth-Context";
import { useNavigate } from "react-router-dom";
import "./ConsumerCatalog.css";
import Modal from "../../components/common/modal";

export default function ConsumerLinkManagement() {
  const { token, logout } = useAuth();
  const navigate = useNavigate();

  const [suppliers, setSuppliers] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");
  const [actionLoading, setActionLoading] = useState(null);

  const [modalConfig, setModalConfig] = useState({
    show: false,
    type: "", // "confirm" | "catalog"
    title: "",
    text: "",
    supplierId: null,
    items: [],
  });

  const API_BASE = "http://127.0.0.1:8000/api/accounts";

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
      setErrorMsg(err.message);
      setSuppliers([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSuppliers();
  }, [token]);

  // === Actions ===
  const handleSendRequest = async (supplierId) => {
    const supplier = suppliers.find((s) => s.id === supplierId);
    if (!supplier) return;

    if (supplier.linkStatus !== "not_linked" && supplier.linkStatus !== "rejected") {
      setErrorMsg(`Cannot send request - link already exists: ${supplier.linkStatus}`);
      return;
    }

    setActionLoading(supplierId);
    setErrorMsg("");

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
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const responseText = await res.text();
        let data;
        try { data = JSON.parse(responseText); } catch { data = { detail: responseText }; }
        throw new Error(data.detail || data.message || "Failed to send link request");
      }

      await fetchSuppliers();
    } catch (err) {
      setErrorMsg(err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const handleDeleteLink = (supplierId) => {
    const supplier = suppliers.find((s) => s.id === supplierId);
    if (!supplier || !supplier.linkId) {
      setErrorMsg("No link found. Please refresh and try again.");
      return;
    }

    const type = supplier.linkStatus === "pending" ? "cancel" : "unlink";

    setModalConfig({
      show: true,
      type: "confirm",
      title: type === "cancel" ? "Cancel Request" : "Unlink Supplier",
      text:
        type === "cancel"
          ? "Are you sure you want to cancel this request?"
          : "Are you sure you want to unlink this supplier?",
      supplierId: supplier.id,
      items: [],
    });
  };

  const confirmDelete = async () => {
    const supplier = suppliers.find((s) => s.id === modalConfig.supplierId);
    if (!supplier || !supplier.linkId) return;

    setModalConfig((prev) => ({ ...prev, show: false }));
    setActionLoading(supplier.id);
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
      setErrorMsg(err.message || "Error deleting link");
    } finally {
      setActionLoading(null);
    }
  };

  const handleViewCatalog = (supplier) => {
    setModalConfig({
      show: true,
      type: "catalog",
      title: `${supplier.name}'s Catalog`,
      text: "",
      supplierId: supplier.id,
      items: [
        { id: 1, name: "Product A", description: "Description A", price: "$10" },
        { id: 2, name: "Product B", description: "Description B", price: "$15" },
        { id: 3, name: "Product C", description: "Description C", price: "$20" },
      ],
    });
  };

  const closeModal = () => setModalConfig((prev) => ({ ...prev, show: false }));

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
          <button onClick={() => setErrorMsg("")} className="close-btn">✕</button>
        </div>
      )}

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
                    disabled={actionLoading === supplier.id}
                  >
                    {actionLoading === supplier.id ? "Sending..." : "Send Link Request"}
                  </button>
                )}

                {supplier.linkStatus === "pending" && (
                  <button
                    className="link-btn cancel-btn"
                    onClick={() => handleDeleteLink(supplier.id)}
                    disabled={actionLoading === supplier.id}
                  >
                    {actionLoading === supplier.id ? "Cancelling..." : "Cancel Request"}
                  </button>
                )}

                {supplier.linkStatus === "linked" && (
                  <>
                    <button
                      className="link-btn view-catalog-btn"
                      onClick={() => handleViewCatalog(supplier)}
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
                )}

                {supplier.linkStatus === "rejected" && (
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

      <Modal
        show={modalConfig.show}
        title={modalConfig.title}
        text={modalConfig.text}
        onConfirm={modalConfig.type === "confirm" ? confirmDelete : null}
        onCancel={closeModal}
      >
        {modalConfig.type === "catalog" && (
          <div className="catalog-items">
            {modalConfig.items.map((item) => (
              <div key={item.id} className="catalog-item-card">
                <h4>{item.name}</h4>
                <p>{item.description}</p>
                <p className="item-price">{item.price}</p>
              </div>
            ))}
            {modalConfig.items.length === 0 && <p>No items to display</p>}
          </div>
        )}
      </Modal>
    </div>
  );
}
