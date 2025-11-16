import React, { useState } from "react";
import "./ConsumerCatalog.css";

const dummySuppliers = [
  {
    id: 1,
    name: "Fresh Farm Products",
    category: "Vegetables & Fruits",
    location: "Almaty Region",
    image: "https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400",
    description: "Fresh local produce",
    linkStatus: "not_linked" // not_linked, pending, approved, rejected, blocked
  },
  {
    id: 2,
    name: "Premium Meat Supply",
    category: "Meat & Poultry",
    location: "Astana",
    image: "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400",
    description: "Premium quality meat",
    linkStatus: "approved"
  },
  {
    id: 3,
    name: "Dairy Dreams Co.",
    category: "Dairy Products",
    location: "Shymkent",
    image: "https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400",
    description: "Fresh dairy products",
    linkStatus: "pending"
  },
  {
    id: 4,
    name: "Bakery Masters",
    category: "Bakery",
    location: "Almaty",
    image: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400",
    description: "Artisan bread and pastries",
    linkStatus: "rejected"
  }
];

export default function ConsumerLinkManagement() {
  const [suppliers, setSuppliers] = useState(dummySuppliers);
  const [filterStatus, setFilterStatus] = useState("all");

  // Send link request
  const handleSendRequest = (supplierId) => {
    setSuppliers(suppliers.map(s => 
      s.id === supplierId 
        ? { ...s, linkStatus: "pending" }
        : s
    ));
    alert(`Link request sent to supplier ID: ${supplierId}`);
  };

  // Cancel pending request
  const handleCancelRequest = (supplierId) => {
    if (window.confirm("Cancel link request?")) {
      setSuppliers(suppliers.map(s => 
        s.id === supplierId 
          ? { ...s, linkStatus: "not_linked" }
          : s
      ));
    }
  };

  // Unlink from supplier
  const handleUnlink = (supplierId) => {
    if (window.confirm("Are you sure you want to unlink from this supplier?")) {
      setSuppliers(suppliers.map(s => 
        s.id === supplierId 
          ? { ...s, linkStatus: "not_linked" }
          : s
      ));
    }
  };

  // Filter suppliers
  const filteredSuppliers = filterStatus === "all" 
    ? suppliers 
    : suppliers.filter(s => s.linkStatus === filterStatus);

  // Get status counts
  const counts = {
    all: suppliers.length,
    approved: suppliers.filter(s => s.linkStatus === "approved").length,
    pending: suppliers.filter(s => s.linkStatus === "pending").length,
    not_linked: suppliers.filter(s => s.linkStatus === "not_linked").length,
    rejected: suppliers.filter(s => s.linkStatus === "rejected").length
  };

  return (
    <div className="link-management-container">
      <div className="link-header">
        <h2>Supplier Connections</h2>
        <p className="link-subtitle">Manage your supplier relationships</p>
      </div>

      {/* Statistics */}
      <div className="link-stats">
        <div className="stat-card">
          <div className="stat-icon approved-icon">✓</div>
          <div className="stat-info">
            <h3>{counts.approved}</h3>
            <p>Linked Suppliers</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon pending-icon">⏳</div>
          <div className="stat-info">
            <h3>{counts.pending}</h3>
            <p>Pending Requests</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon available-icon">🔍</div>
          <div className="stat-info">
            <h3>{counts.not_linked}</h3>
            <p>Available Suppliers</p>
          </div>
        </div>
      </div>

      {/* Filter Tabs */}
      <div className="link-filters">
        <button 
          className={`filter-btn ${filterStatus === "all" ? "active" : ""}`}
          onClick={() => setFilterStatus("all")}
        >
          All ({counts.all})
        </button>
        <button 
          className={`filter-btn ${filterStatus === "approved" ? "active" : ""}`}
          onClick={() => setFilterStatus("approved")}
        >
          Linked ({counts.approved})
        </button>
        <button 
          className={`filter-btn ${filterStatus === "pending" ? "active" : ""}`}
          onClick={() => setFilterStatus("pending")}
        >
          Pending ({counts.pending})
        </button>
        <button 
          className={`filter-btn ${filterStatus === "not_linked" ? "active" : ""}`}
          onClick={() => setFilterStatus("not_linked")}
        >
          Available ({counts.not_linked})
        </button>
        <button 
          className={`filter-btn ${filterStatus === "rejected" ? "active" : ""}`}
          onClick={() => setFilterStatus("rejected")}
        >
          Rejected ({counts.rejected})
        </button>
      </div>

      {/* Suppliers Grid */}
      <div className="suppliers-grid">
        {filteredSuppliers.map((supplier) => (
          <div key={supplier.id} className="supplier-link-card">
            <div className="supplier-image-wrapper">
              <img src={supplier.image} alt={supplier.name} className="supplier-image" />
              <span className={`link-status-badge ${supplier.linkStatus}`}>
                {supplier.linkStatus === "approved" && "✓ Linked"}
                {supplier.linkStatus === "pending" && "⏳ Pending"}
                {supplier.linkStatus === "not_linked" && "Available"}
                {supplier.linkStatus === "rejected" && "✕ Rejected"}
                {supplier.linkStatus === "blocked" && "🚫 Blocked"}
              </span>
            </div>

            <div className="supplier-content">
              <h3 className="supplier-name">{supplier.name}</h3>
              <p className="supplier-category">{supplier.category}</p>
              <p className="supplier-location">📍 {supplier.location}</p>
              <p className="supplier-description">{supplier.description}</p>

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
                    onClick={() => handleCancelRequest(supplier.id)}
                  >
                    Cancel Request
                  </button>
                )}

                {supplier.linkStatus === "approved" && (
                  <>
                    <button 
                      className="link-btn view-catalog-btn"
                      onClick={() => alert(`View catalog for ${supplier.name}`)}
                    >
                      View Catalog
                    </button>
                    <button 
                      className="link-btn unlink-btn"
                      onClick={() => handleUnlink(supplier.id)}
                    >
                      Unlink
                    </button>
                  </>
                )}

                {supplier.linkStatus === "rejected" && (
                  <>
                    <span className="rejected-message">Request was rejected</span>
                    <button 
                      className="link-btn send-request-btn"
                      onClick={() => handleSendRequest(supplier.id)}
                    >
                      Send Again
                    </button>
                  </>
                )}

                {supplier.linkStatus === "blocked" && (
                  <span className="blocked-message">You are blocked by this supplier</span>
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