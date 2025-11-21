import React, { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import "./ConsumerComplaints.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function ConsumerComplaints() {
  const navigate = useNavigate();
  const location = useLocation();
  const { token, logout } = useAuth();
  const [orders, setOrders] = useState([]);
  const [complaints, setComplaints] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [selectedOrderId, setSelectedOrderId] = useState(null);
  const [newComplaint, setNewComplaint] = useState({
    title: "",
    description: "",
  });

  const fetchComplaints = async () => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    try {
      const res = await fetch(`${API_BASE}/complaints/my/`, {
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
        throw new Error(text || "Failed to load complaints");
      }

      const data = await res.json();
      setComplaints(Array.isArray(data) ? data : []);
    } catch (err) {
      setError(err.message || "Failed to load complaints");
      setComplaints([]);
    }
  };

  const fetchOrders = async () => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/orders/my/`, {
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
        throw new Error(text || "Failed to load orders");
      }

      const data = await res.json();
      setOrders(Array.isArray(data) ? data : []);
    } catch (err) {
      setError(err.message || "Failed to load orders");
      setOrders([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
    fetchComplaints();
  }, [token]);

  useEffect(() => {
    if (location.state?.orderId) {
      const orderId = Number(location.state.orderId);
      if (!isNaN(orderId)) {
        setSelectedOrderId(orderId);
        setShowForm(true);
      }
    }
  }, [location.state]);

  const handleInputChange = (e) => {
    setNewComplaint({
      ...newComplaint,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmitComplaint = async (e) => {
    e.preventDefault();
    
    if (!selectedOrderId) {
      setError("Please select an order");
      return;
    }

    if (!newComplaint.title.trim() || !newComplaint.description.trim()) {
      setError("Please fill all fields");
      return;
    }

    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setSubmitting(true);
    setError("");

    try {
      const orderId = Number(selectedOrderId);
      if (!orderId || isNaN(orderId)) {
        setError("Please select a valid order");
        setSubmitting(false);
        return;
      }

      const res = await fetch(`${API_BASE}/complaints/${orderId}/create/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          order: orderId,
          title: newComplaint.title.trim(),
          description: newComplaint.description.trim(),
        }),
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        let errorMessage = "Failed to submit complaint";
        try {
          const errorData = await res.json();
          errorMessage = 
            errorData.detail || 
            errorData.message ||
            errorData.title?.[0] || 
            errorData.description?.[0] ||
            errorData.order?.[0] ||
            JSON.stringify(errorData) ||
            `Server error: ${res.status}`;
        } catch (e) {
          errorMessage = `Server error: ${res.status} ${res.statusText}`;
        }
        throw new Error(errorMessage);
      }

      await res.json();
      await fetchComplaints();
      setNewComplaint({ title: "", description: "" });
      setSelectedOrderId(null);
      setShowForm(false);
      setError("");
    } catch (err) {
      setError(err.message || "Failed to submit complaint");
    } finally {
      setSubmitting(false);
    }
  };

  const handleFilterChange = (status) => setFilterStatus(status);

  const filteredComplaints =
    filterStatus === "all"
      ? complaints
      : complaints.filter((c) => c.status?.toLowerCase() === filterStatus.toLowerCase());

  const formatDate = (value) => {
    if (!value) return "—";
    try {
      return new Date(value).toLocaleDateString();
    } catch {
      return value;
    }
  };

  const getStatusLabel = (status) => {
    const statusMap = {
      pending: "Pending",
      resolved: "Resolved",
      rejected: "Rejected",
      escalated: "Escalated",
    };
    return statusMap[status?.toLowerCase()] || status;
  };

  const selectedOrder = orders.find((o) => o.id === selectedOrderId);

  if (loading) {
    return (
      <div className="complaints-container">
        <p>Loading...</p>
      </div>
    );
  }

  return (
    <div className="complaints-container">
      <div className="complaints-header-card">
        <h2>My Complaints</h2>
        <button className="new-complaint-btn" onClick={() => setShowForm(!showForm)}>
          {showForm ? "Cancel" : "New Complaint"}
        </button>
      </div>

      {error && (
        <div className="error-message">
          {error}
          <button onClick={() => setError("")} className="close-btn">
            ✕
          </button>
        </div>
      )}

      {showForm && (
        <div className="complaint-form">
          <h3>Submit a New Complaint</h3>
          <form onSubmit={handleSubmitComplaint}>
            <div className="form-group">
              <label htmlFor="order-select">Select Order:</label>
              <select
                id="order-select"
                value={selectedOrderId ? String(selectedOrderId) : ""}
                onChange={(e) => setSelectedOrderId(e.target.value ? Number(e.target.value) : null)}
                required
              >
                <option value="">-- Select an order --</option>
                {orders.map((order) => (
                  <option key={order.id} value={order.id}>
                    Order #{order.id} - {order.supplier_name || "Unknown Supplier"} - {formatDate(order.created_at)}
                  </option>
                ))}
              </select>
              {selectedOrder && (
                <div className="order-preview">
                  <p><strong>Supplier:</strong> {selectedOrder.supplier_name}</p>
                  <p><strong>Total:</strong> {Number(selectedOrder.total_price || 0).toLocaleString()} ₸</p>
                </div>
              )}
            </div>
            <div className="form-group">
              <label htmlFor="complaint-title">Complaint Title:</label>
              <input
                id="complaint-title"
                type="text"
                name="title"
                placeholder="e.g., Late delivery, Wrong product, etc."
                value={newComplaint.title}
                onChange={handleInputChange}
                required
              />
            </div>
            <div className="form-group">
              <label htmlFor="complaint-description">Description:</label>
              <textarea
                id="complaint-description"
                name="description"
                placeholder="Describe your complaint in detail..."
                value={newComplaint.description}
                onChange={handleInputChange}
                rows="5"
                required
              />
            </div>
            <div className="form-actions">
              <button type="submit" disabled={submitting}>
                {submitting ? "Submitting..." : "Submit Complaint"}
              </button>
              <button type="button" onClick={() => {
                setShowForm(false);
                setNewComplaint({ title: "", description: "" });
                setSelectedOrderId(null);
                setError("");
              }}>
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}

      <div className="complaints-filters">
        <button
          className={filterStatus === "all" ? "active" : ""}
          onClick={() => handleFilterChange("all")}
        >
          All
        </button>
        <button
          className={filterStatus === "pending" ? "active" : ""}
          onClick={() => handleFilterChange("pending")}
        >
          Pending
        </button>
        <button
          className={filterStatus === "resolved" ? "active" : ""}
          onClick={() => handleFilterChange("resolved")}
        >
          Resolved
        </button>
        <button
          className={filterStatus === "rejected" ? "active" : ""}
          onClick={() => handleFilterChange("rejected")}
        >
          Rejected
        </button>
        <button
          className={filterStatus === "escalated" ? "active" : ""}
          onClick={() => handleFilterChange("escalated")}
        >
          Escalated
        </button>
      </div>

      <div className="complaints-list">
        {filteredComplaints.length === 0 ? (
          <div className="no-complaints">
            <p>No complaints found for this status.</p>
            {complaints.length === 0 && (
              <p>Create a complaint by clicking "New Complaint" above.</p>
            )}
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
                  <strong>Supplier:</strong> {c.supplier_name || `Supplier #${c.supplier}`}
                </p>
                <p>
                  <strong>Order ID:</strong> #{c.order}
                </p>
                <p className="complaint-description">{c.description}</p>
              </div>
              <div className="complaint-dates">
                <p>
                  <small>Created: {formatDate(c.created_at)}</small>
                </p>
                {c.resolved_at && (
                  <p>
                    <small>Resolved: {formatDate(c.resolved_at)}</small>
                  </p>
                )}
              </div>
              <div className="complaint-actions">
                <button
                  className="open-chat-btn"
                  onClick={() => navigate("/chat", { state: { selectSupplierId: c.supplier } })}
                >
                  Open Chat
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
