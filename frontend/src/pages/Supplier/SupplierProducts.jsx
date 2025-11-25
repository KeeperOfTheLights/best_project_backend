import React, { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import "./SupplierProducts.css";
import { useAuth } from "../../context/Auth-Context";
import { is_catalog_manager } from "../../utils/roleUtils";

export default function SupplierProducts() {
  const { t } = useTranslation();
  const { token, role, loading: authLoading } = useAuth();
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
    discount: "0",
    unit: "kg",
    stock: "",
    minOrder: "",
    image: "",
    description: "",
    status: "active",
    delivery_option: "both",
    lead_time_days: "0",
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
    if (authLoading) return;
    if (!is_catalog_manager(role)) {
      navigate("/SupplierDashboard");
      return;
    }
    fetchProducts();
  }, [role, navigate, authLoading]);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const response = await fetch("http://127.0.0.1:8000/api/accounts/products/", {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error(t("products.failedToFetch"));
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
      discount: "0",
      unit: "kg",
      stock: "",
      minOrder: "",
      image: "",
      description: "",
      status: "active",
      delivery_option: "both",
      lead_time_days: "0",
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
        
        let errorMessage = t("products.failedToSave");
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
      setErrorModal({ visible: true, message: err.message || t("products.failedToSave") });
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
    openActionModal(productId, "delete", t("products.areYouSureDelete"));
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
      if (!response.ok) throw new Error(t("products.failedToDelete"));
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
        throw new Error(t("products.failedToUpdateStatus"));
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
          <h2>{t("common.error")}</h2>
          <p>{t("products.accessDenied")}</p>
          <button onClick={() => navigate("/SupplierDashboard")} style={{ marginTop: "1rem", padding: "0.5rem 1rem" }}>
            {t("dashboard.viewOrders")}
          </button>
        </div>
      </div>
    );
  }

  if (loading) return <p>{t("products.loadingProducts")}</p>;
  if (error) return <p>{t("common.error")}: {error}</p>;

  return (
    <div className="products-container">
      <div className="products-header">
        <h2>{t("products.productCatalog")}</h2>
        <button className="add-product-btn" onClick={handleAddClick}>
          + {t("products.addProduct")}
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
                    background: "#ded6d6ff",
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                    color: "#6a6666ff",
                  }}
                >
                  {t("products.noImage")}
                </div>
              )}
              <span className={`status-badge ${product.status}`}>
                {product.status === "active" ? t("products.active") : t("products.inactive")}
              </span>
            </div>

            <div className="product-content">
              <h3 className="product-name">{product.name}</h3>
              <p className="product-category">{product.category}</p>
              <p className="product-price">
                {product.discounted_price && product.discount > 0 ? (
                  <>
                    <span style={{ textDecoration: "line-through", color: "#a09c9cff", marginRight: "8px" }}>
                      {product.price} ₸
                    </span>
                    <span style={{ color: "#e14938ff", fontWeight: "bold" }}>
                      {product.discounted_price} ₸
                    </span>
                    <span style={{ color: "#e24938ff", marginLeft: "8px" }}>
                      ({product.discount}% off)
                    </span>
                  </>
                ) : (
                  `${product.price} ₸`
                )} / {product.unit}
              </p>
              <p className="product-description">{product.description}</p>
              <div className="product-actions">
                <button className="action-btn edit-btn" onClick={() => handleEditClick(product)}>
                  {t("common.edit")}
                </button>
                <button
                  className="action-btn toggle-btn"
                  onClick={() =>
                    openActionModal(
                      product.id,
                      "toggleStatus",
                      product.status === "active" 
                        ? t("products.areYouSureDeactivate")
                        : t("products.areYouSureActivate")
                    )
                  }
                >
                  {product.status === "active" ? t("products.deactivate") : t("products.activate")}
                </button>
                <button
                  className="action-btn delete-btn"
                  onClick={() => handleDelete(product.id)}
                >
                  {t("common.delete")}
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
              <h2>{modalMode === "add" ? t("products.addProduct") : t("products.editProduct")}</h2>
              <button className="close-btn" onClick={() => setShowModal(false)}>
                &times;
              </button>
            </div>
            <div className="product-form">
              <div className="form-group">
                <label>{t("products.productName")}</label>
                <input name="name" value={formData.name} onChange={handleInputChange} required />
              </div>
              <div className="form-group">
                <label>{t("products.category")}</label>
                <input name="category" value={formData.category} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>{t("products.price")}</label>
                <input
                  type="number"
                  step="0.01"
                  name="price"
                  value={formData.price}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label>{t("products.discount")}</label>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  max="100"
                  name="discount"
                  value={formData.discount}
                  onChange={handleInputChange}
                  placeholder="0"
                />
                <small style={{ color: "#666", fontSize: "0.85rem" }}>
                  {t("products.enterDiscount")}
                </small>
              </div>
              <div className="form-group">
                <label>{t("products.unit")}</label>
                <select name="unit" value={formData.unit} onChange={handleInputChange}>
                  <option value="kg">{t("products.kg")}</option>
                  <option value="pcs">{t("products.pcs")}</option>
                  <option value="litre">{t("products.litre")}</option>
                  <option value="pack">{t("products.pack")}</option>
                </select>
              </div>
              <div className="form-group">
                <label>{t("products.stock")}</label>
                <input type="number" name="stock" value={formData.stock} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>{t("products.minOrder")}</label>
                <input type="number" name="minOrder" value={formData.minOrder} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>{t("products.imageUrl")}</label>
                <input name="image" value={formData.image} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>{t("products.description")}</label>
                <textarea name="description" value={formData.description} onChange={handleInputChange} />
              </div>
              <div className="form-group">
                <label>{t("products.deliveryOption")}</label>
                <select name="delivery_option" value={formData.delivery_option} onChange={handleInputChange}>
                  <option value="delivery">{t("products.deliveryOnly")}</option>
                  <option value="pickup">{t("products.pickupOnly")}</option>
                  <option value="both">{t("products.both")}</option>
                </select>
              </div>
              <div className="form-group">
                <label>{t("products.leadTimeDays")}</label>
                <input
                  type="number"
                  min="0"
                  name="lead_time_days"
                  value={formData.lead_time_days}
                  onChange={handleInputChange}
                  placeholder="0"
                />
              </div>
              <div className="form-group">
                <label>{t("products.status")}</label>
                <select name="status" value={formData.status} onChange={handleInputChange}>
                  <option value="active">{t("products.active")}</option>
                  <option value="inactive">{t("products.inactive")}</option>
                </select>
              </div>
              <div className="modal-actions">
                <button type="button" className="cancel-btn" onClick={() => setShowModal(false)}>
                  {t("common.cancel")}
                </button>
                <button type="button" className="save-btn" onClick={handleSave}>
                  {t("common.save")}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {actionModal.visible && (
        <div className="modal-overlay">
          <div className="modal-window">
            <h3>{t("common.confirm")}</h3>
            <p>{actionModal.message}</p>
            <div className="modal-buttons">
              <button
                className="modal-btn cancel"
                onClick={() => setActionModal({ ...actionModal, visible: false })}
              >
                {t("common.cancel")}
              </button>
              <button className="modal-btn confirm" onClick={confirmAction}>
                {t("common.confirm")}
              </button>
            </div>
          </div>
        </div>
      )}

      {errorModal.visible && (
        <div className="modal-overlay">
          <div className="modal-window error-modal">
            <h3>{t("common.error")}</h3>
            <p>{errorModal.message}</p>
            <div className="modal-buttons">
              <button
                className="modal-btn confirm"
                onClick={() => setErrorModal({ visible: false, message: "" })}
              >
                {t("common.close")}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
