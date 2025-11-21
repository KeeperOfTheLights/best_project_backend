import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import "./SupplierProducts.css";
import { useAuth } from "../../context/Auth-Context";
import { is_catalog_manager } from "../../utils/roleUtils";

export default function SupplierProducts() {
  const { token, role } = useAuth();
  const navigate = useNavigate();
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState("add");
  const [currentProduct, setCurrentProduct] = useState(null);
  const [formData, setFormData] = useState({
    name: "",
    category: "",
    price: "",
    unit: "kg",
    stock: "",
    minOrder: "",
    image: "",
    description: "",
    status: "active",
  });

  const [actionModal, setActionModal] = useState({
    visible: false,
    productId: null,
    action: null,
    message: "",
  });
  const [errorModal, setErrorModal] = useState({
    visible: false,
    message: "",
  });

  useEffect(() => {
    if (!is_catalog_manager(role)) {
      navigate("/SupplierDashboard");
      return;
    }
    fetchProducts();
  }, [role, navigate]);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const response = await fetch("http://127.0.0.1:8000/api/accounts/products/", {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error("Failed to fetch products");
      const data = await response.json();
      setProducts(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleAddClick = () => {
    setModalMode("add");
    setFormData({
      name: "",
      category: "",
      price: "",
      unit: "kg",
      stock: "",
      minOrder: "",
      image: "",
      description: "",
      status: "active",
    });
    setErrorModal({ visible: false, message: "" });
    setShowModal(true);
  };

  const handleEditClick = (product) => {
    setModalMode("edit");
    setCurrentProduct(product);
    setFormData({ ...product });
    setErrorModal({ visible: false, message: "" });
    setShowModal(true);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSave = async (e) => {
    e.preventDefault();
    
    try {
      const url =
        modalMode === "add"
          ? "http://127.0.0.1:8000/api/accounts/products/"
          : `http://127.0.0.1:8000/api/accounts/products/${currentProduct.id}/`;
      const method = modalMode === "add" ? "POST" : "PUT";

      const response = await fetch(url, {
        method,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        console.error("Server error:", errorData);
        
        let errorMessage = "Failed to save product";
        if (errorData.detail) {
          errorMessage = errorData.detail;
        } else if (errorData.message) {
          errorMessage = errorData.message;
        } else if (typeof errorData === "object") {
          const fieldErrors = Object.entries(errorData)
            .map(([field, errors]) => {
              const errorList = Array.isArray(errors) ? errors.join(", ") : errors;
              return `${field}: ${errorList}`;
            })
            .join("; ");
          if (fieldErrors) errorMessage = fieldErrors;
        }
        
        setErrorModal({ visible: true, message: errorMessage });
        return;
      }
      
      await fetchProducts();
      setShowModal(false);
      setErrorModal({ visible: false, message: "" });
    } catch (err) {
      console.error("Save error:", err);
      setErrorModal({ visible: true, message: err.message || "Failed to save product" });
    }
  };

  const openActionModal = (productId, action, message) => {
    setActionModal({ visible: true, productId, action, message });
  };

  const confirmAction = async () => {
    const { productId, action } = actionModal;

    if (action === "delete") {
      await handleDeleteConfirmed(productId);
    } else if (action === "toggleStatus") {
      const product = products.find((p) => p.id === productId);
      if (product) await toggleStatus(product);
    }

    setActionModal({ visible: false, productId: null, action: null, message: "" });
  };

  const handleDelete = (productId) => {
    openActionModal(productId, "delete", "Are you sure you want to delete this product?");
  };

  const handleDeleteConfirmed = async (productId) => {
    try {
      const response = await fetch(
        `http://127.0.0.1:8000/api/accounts/products/${productId}/`,
        {
          method: "DELETE",
          headers: { Authorization: `Bearer ${token}` },
        }
      );
      if (!response.ok) throw new Error("Failed to delete product");
      setProducts(products.filter((p) => p.id !== productId));
    } catch (err) {
      alert(err.message);
    }
  };

  const toggleStatus = async (product) => {
    try {
      const response = await fetch(
        `http://127.0.0.1:8000/api/accounts/products/${product.id}/status/`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (!response.ok) {
        const errorData = await response.json();
        console.error("Toggle status error:", errorData);
        throw new Error("Failed to update status");
      }

      await fetchProducts();
    } catch (err) {
      console.error("Toggle error:", err);
      alert(err.message);
    }
  };

  if (!is_catalog_manager(role)) {
    return (
      <div className="products-container">
        <div className="error-message" style={{ padding: "2rem", textAlign: "center" }}>
          <h2>Access Denied</h2>
          <p>Only Owners and Managers can manage products.</p>
          <button onClick={() => navigate("/SupplierDashboard")} style={{ marginTop: "1rem", padding: "0.5rem 1rem" }}>
            Go to Dashboard
          </button>
        </div>
      </div>
    );
  }

  if (loading) return <p>Loading products...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <div className="products-container">
      <div className="products-header">
        <h2>Product Catalog</h2>
        <button className="add-product-btn" onClick={handleAddClick}>
          + Add New Product
        </button>
      </div>

      <div className="products-grid">
        {products.map((product) => (
          <div key={product.id} className="product-card">
            <div className="product-image-wrapper">
              {product.image ? (
                <img src={product.image} alt={product.name} className="product-image" />
              ) : (
                <div
                  style={{
                    width: "100%",
                    height: "200px",
                    background: "#ddd",
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                    color: "#666",
                  }}
                >
                  No Image
                </div>
              )}
              <span className={`status-badge ${product.status}`}>{product.status}</span>
            </div>

            <div className="product-content">
              <h3 className="product-name">{product.name}</h3>
              <p className="product-category">{product.category}</p>
              <p className="product-price">
                {product.price} ₸ / {product.unit}
              </p>
              <p className="product-description">{product.description}</p>
              <div className="product-actions">
                <button className="action-btn edit-btn" onClick={() => handleEditClick(product)}>
                  Edit
                </button>
                <button
                  className="action-btn toggle-btn"
                  onClick={() =>
                    openActionModal(
                      product.id,
                      "toggleStatus",
                      `Are you sure you want to ${
                        product.status === "active" ? "deactivate" : "activate"
                      } this product?`
                    )
                  }
                >
                  {product.status === "active" ? "Deactivate" : "Activate"}
                </button>
                <button
                  className="action-btn delete-btn"
                  onClick={() => handleDelete(product.id)}
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <h2>{modalMode === "add" ? "Add Product" : "Edit Product"}</h2>
              <button className="close-btn" onClick={() => setShowModal(false)}>
                &times;
              </button>
            </div>
            <div className="product-form">
              <div className="form-group">
                <label>Name</label>
                <input name="name" value={formData.name} onChange={handleInputChange} required />
              </div>
              <div className="form-group">
                <label>Category</label>
                <input name="category" value={formData.category} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>Price</label>
                <input
                  type="number"
                  name="price"
                  value={formData.price}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label>Unit</label>
                <select name="unit" value={formData.unit} onChange={handleInputChange}>
                  <option value="kg">kg</option>
                  <option value="pcs">piece</option>
                  <option value="litre">litre</option>
                  <option value="pack">pack</option>
                </select>
              </div>
              <div className="form-group">
                <label>Stock</label>
                <input type="number" name="stock" value={formData.stock} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>Minimum Order</label>
                <input type="number" name="minOrder" value={formData.minOrder} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>Image URL</label>
                <input name="image" value={formData.image} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>Description</label>
                <textarea name="description" value={formData.description} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>Status</label>
                <select name="status" value={formData.status} onChange={handleInputChange}>
                  <option value="active">active</option>
                  <option value="inactive">inactive</option>
                </select>
              </div>
              <div className="modal-actions">
                <button type="button" className="cancel-btn" onClick={() => setShowModal(false)}>
                  Cancel
                </button>
                <button type="button" className="save-btn" onClick={handleSave}>
                  Save
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {actionModal.visible && (
        <div className="modal-overlay">
          <div className="modal-window">
            <h3>Confirm Action</h3>
            <p>{actionModal.message}</p>
            <div className="modal-buttons">
              <button
                className="modal-btn cancel"
                onClick={() => setActionModal({ ...actionModal, visible: false })}
              >
                Cancel
              </button>
              <button className="modal-btn confirm" onClick={confirmAction}>
                Confirm
              </button>
            </div>
          </div>
        </div>
      )}

      {errorModal.visible && (
        <div className="modal-overlay">
          <div className="modal-window error-modal">
            <h3>Error</h3>
            <p>{errorModal.message}</p>
            <div className="modal-buttons">
              <button
                className="modal-btn confirm"
                onClick={() => setErrorModal({ visible: false, message: "" })}
              >
                OK
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
