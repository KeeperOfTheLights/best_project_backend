import React, { useState } from "react";
import "./ConsumerComplaints.css";

const dummyComplaints = [
  {
    id: 1,
    supplierName: "Fresh Farm Products",
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
    supplierName: "Dairy Dreams Co.",
    title: "Spoiled milk",
    description: "Milk was expired upon delivery.",
    status: "Rejected",
    date: "2025-11-05"
  }
];

export default function ConsumerComplaints() {
  const [complaints, setComplaints] = useState(dummyComplaints);
  const [filterStatus, setFilterStatus] = useState("all");
  const [newComplaint, setNewComplaint] = useState({
    supplierName: "",
    title: "",
    description: ""
  });

  const handleFilterChange = (status) => setFilterStatus(status);

  const filteredComplaints = filterStatus === "all"
    ? complaints
    : complaints.filter(c => c.status === filterStatus);

  const handleInputChange = (e) => {
    setNewComplaint({
      ...newComplaint,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmitComplaint = (e) => {
    e.preventDefault();
    if (!newComplaint.supplierName || !newComplaint.title || !newComplaint.description) {
      alert("Please fill all fields");
      return;
    }
    const complaint = {
      id: complaints.length + 1,
      supplierName: newComplaint.supplierName,
      title: newComplaint.title,
      description: newComplaint.description,
      status: "Pending",
      date: new Date().toISOString().split("T")[0]
    };
    setComplaints([complaint, ...complaints]);
    setNewComplaint({ supplierName: "", title: "", description: "" });
    alert("Complaint submitted successfully");
  };

  const handleResetComplaints = () => setComplaints([]);

  return (
    <div className="complaints-container">
      {/* Header with title and reset button */}
      <div className="complaints-header-card">
        <h2>My Complaints</h2>
        <button className="reset-data-btn" onClick={handleResetComplaints}>
          Reset Complaints
        </button>
      </div>

      {/* Filters */}
      <div className="complaints-filters">
        <button className={filterStatus === "all" ? "active" : ""} onClick={() => handleFilterChange("all")}>
          All
        </button>
        <button className={filterStatus === "Pending" ? "active" : ""} onClick={() => handleFilterChange("Pending")}>
          Pending
        </button>
        <button className={filterStatus === "Resolved" ? "active" : ""} onClick={() => handleFilterChange("Resolved")}>
          Resolved
        </button>
        <button className={filterStatus === "Rejected" ? "active" : ""} onClick={() => handleFilterChange("Rejected")}>
          Rejected
        </button>
      </div>

      {/* Complaints List */}
      <div className="complaints-list">
        {filteredComplaints.length === 0 ? (
          <div className="no-complaints">
            <p>No complaints found for this status.</p>
          </div>
        ) : (
          filteredComplaints.map(c => (
            <div key={c.id} className={`complaint-card ${c.status.toLowerCase()}`}>
              <h4>{c.title}</h4>
              <p><strong>Supplier:</strong> {c.supplierName}</p>
              <p>{c.description}</p>
              <p><strong>Status:</strong> {c.status}</p>
              <p><small>Date: {c.date}</small></p>
            </div>
          ))
        )}
      </div>

      {/* New Complaint Form */}
      <div className="complaint-form">
        <h3>Submit a New Complaint</h3>
        <form onSubmit={handleSubmitComplaint}>
          <input
            type="text"
            name="supplierName"
            placeholder="Supplier Name"
            value={newComplaint.supplierName}
            onChange={handleInputChange}
          />
          <input
            type="text"
            name="title"
            placeholder="Complaint Title"
            value={newComplaint.title}
            onChange={handleInputChange}
          />
          <textarea
            name="description"
            placeholder="Complaint Description"
            value={newComplaint.description}
            onChange={handleInputChange}
          />
          <button type="submit">Submit Complaint</button>
        </form>
      </div>
    </div>
  );
}
