import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import "./ConsumerLinkManagement.css";

export default function ConsumerLinkManagement() {
  const { token } = useAuth();
  const [suppliers, setSuppliers] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const navigate = useNavigate();

  useEffect(() => {
    fetchSuppliers();
  }, []);

  const fetchSuppliers = async () => {
    try {
      const response = await fetch("http://127.0.0.1:8000/api/accounts/links/", {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error("Failed to fetch suppliers");
      const data = await response.json();
      setSuppliers(data);
    } catch (err) {
      alert(err.message);
    }
  };

  // Accept link
  const handleAccept = async (id) => {
    try {
      const response = await fetch(`http://127.0.0.1:8000/api/accounts/link/${id}/accept/`, {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error("Failed to accept link");
      fetchSuppliers();
    } catch (err) {
      alert(err.message);
    }
  };

  // Reject link
  const handleReject = async (id) => {
    try {
      const response = await fetch(`http://127.0.0.1:8000/api/accounts/link/${id}/reject/`, {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error("Failed to reject link");
      fetchSuppliers();
    } catch (err) {
      alert(err.message);
    }
  };

  // Block link
  const handleBlock = async (id) => {
    try {
      const response = await fetch(`http://127.0.0.1:8000/api/accounts/link/${id}/block/`, {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error("Failed to block link");
      fetchSuppliers();
    } catch (err) {
      alert(err.message);
    }
  };

  // Unblock link
  const handleUnblock = async (id) => {
    try {
      const response = await fetch(`http://127.0.0.1:8000/api/accounts/link/${id}/unblock/`, {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error("Failed to unblock link");
      fetchSuppliers();
    } catch (err) {
      alert(err.message);
    }
  };

  // Unlink
  const handleUnlink = async (id) => {
    if (!window.confirm("Are you sure you want to unlink?")) return;
    try {
      const response = await fetch(`http://127.0.0.1:8000/api/accounts/link/${id}/`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error("Failed to unlink");
      fetchSuppliers();
    } catch (err) {
      alert(err.message);
    }
  };

  const filteredSuppliers = filterStatus === "all"
    ? suppliers
    : suppliers.filter(s => s.link_status === filterStatus);

  const counts = {
    all: suppliers.length,
    approved: suppliers.filter(s => s.link_status === "approved").length,
    pending: suppliers.filter(s => s.link_status === "pending").length,
    not_linked: suppliers.filter(s => s.link_status === "not_linked").length,
    rejected: suppliers.filter(s => s.link_status === "rejected").length,
  };

  return (
    <div className="link-management-container">
      <h2>Supplier Connections</h2>

      <div className="link-filters">
        {["all","approved","pending","not_linked","rejected"].map(status => (
          <button
            key={status}
            className={filterStatus === status ? "active" : ""}
            onClick={() => setFilterStatus(status)}
          >
            {status.charAt(0).toUpperCase() + status.slice(1)} ({counts[status]})
          </button>
        ))}
      </div>

      <div className="suppliers-grid">
        {filteredSuppliers.map(s => (
          <div key={s.id} className="supplier-card">
            <img src={s.image} alt={s.name} className="supplier-image"/>
            <h3>{s.name}</h3>
            <p>{s.category}</p>
            <p>{s.location}</p>
            <p>Status: {s.link_status}</p>

            <div className="actions">
              {s.link_status === "pending" && (
                <>
                  <button onClick={() => handleAccept(s.id)}>Accept</button>
                  <button onClick={() => handleReject(s.id)}>Reject</button>
                </>
              )}
              {s.link_status === "approved" && (
                <>
                  <button onClick={() => navigate(`/consumer/supplier/${s.id}/products`)}>View Catalog</button>
                  <button onClick={() => handleUnlink(s.id)}>Unlink</button>
                </>
              )}
              {s.link_status === "not_linked" && (
                <button onClick={() => handleSendRequest(s.id)}>Send Request</button>
              )}
              {s.link_status === "rejected" && (
                <button onClick={() => handleSendRequest(s.id)}>Send Again</button>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
