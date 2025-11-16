import React, { useState } from "react";
import "./SupplierComplaints.css";

const dummyComplaints = [
  {
    id: 1,
    supplierName: "Premium Meat Supply",
    title: "Late delivery",
    description: "Order arrived 2 days late.",
    status: "Pending",
    date: "2025-11-10"
  },
  {
    id: 2,
    supplierName: "Premium Meat Supply",
    title: "Wrong product",
    description: "Received chicken instead of beef.",
    status: "Resolved",
    date: "2025-11-08"
  },
  {
    id: 3,
    supplierName: "Premium Meat Supply",
    title: "Spoiled meat",
    description: "Meat was expired upon delivery.",
    status: "Rejected",
    date: "2025-11-05"
  }
];

export default function SupplierComplaints() {
  const [complaints, setComplaints] = useState(dummyComplaints);
  const [filterStatus, setFilterStatus] = useState("all");

  const handleFilterChange = (status) => setFilterStatus(status);

  const filteredComplaints =
    filterStatus === "all"
      ? complaints
      : complaints.filter((c) => c.status === filterStatus);

  const handleReset = () => {
    setComplaints([]);
    setFilterStatus("all");
  };

  const updateStatus = (id, status) => {
    setComplaints(
      complaints.map((c) =>
        c.id === id ? { ...c, status: status } : c
      )
    );
  };

  return (
    <div className="complaints-container">
      <div className="complaints-header-card">
        <h2>Supplier Complaints Management</h2>
        <button className="reset-data-btn" onClick={handleReset}>
          Reset Complaints
        </button>
      </div>

      <div className="complaints-filters">
        <button
          className={filterStatus === "all" ? "active" : ""}
          onClick={() => handleFilterChange("all")}
        >
          All
        </button>
        <button
          className={filterStatus === "Pending" ? "active" : ""}
          onClick={() => handleFilterChange("Pending")}
        >
          Pending
        </button>
        <button
          className={filterStatus === "Resolved" ? "active" : ""}
          onClick={() => handleFilterChange("Resolved")}
        >
          Resolved
        </button>
        <button
          className={filterStatus === "Rejected" ? "active" : ""}
          onClick={() => handleFilterChange("Rejected")}
        >
          Rejected
        </button>
      </div>

      <div className="complaints-list">
        {filteredComplaints.length === 0 ? (
          <div className="no-complaints">
            <p>No complaints found for this status.</p>
          </div>
        ) : (
          filteredComplaints.map((c) => (
            <div key={c.id} className={`complaint-card ${c.status.toLowerCase()}`}>
              <h4>{c.title}</h4>
              <p><strong>Supplier:</strong> {c.supplierName}</p>
              <p>{c.description}</p>
              <p><strong>Status:</strong> {c.status}</p>
              <p><small>Date: {c.date}</small></p>

              {c.status === "Pending" && (
                <div className="action-btns">
                  <button className="resolve-btn" onClick={() => updateStatus(c.id, "Resolved")}>
                    Resolve
                  </button>
                  <button className="reject-btn" onClick={() => updateStatus(c.id, "Rejected")}>
                    Reject
                  </button>
                </div>
              )}
            </div>
          ))
        )}
      </div>
    </div>
  );
}
