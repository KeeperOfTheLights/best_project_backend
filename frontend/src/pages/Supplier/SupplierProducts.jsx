import React, { useState, useEffect } from "react";
import "./SupplierProducts.css";
import { useAuth } from "../../context/Auth-Context";

export default function SupplierProducts() {
  const { token } = useAuth();
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

  useEffect(() => {
    fetchProducts();
  }, []);

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
    setShowModal(true);
  };

  const handleEditClick = (product) => {
    setModalMode("edit");
    setCurrentProduct(product);
    setFormData({ ...product });
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

      if (!response.ok) throw new Error("Failed to save product");
      await fetchProducts();
      setShowModal(false);
    } catch (err) {
      alert(err.message);
    }
  };

  const handleDelete = async (productId) => {
    if (!window.confirm("Are you sure?")) return;
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
        `http://127.0.0.1:8000/api/accounts/products/${product.id}/`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            status: product.status === "active" ? "inactive" : "active",
          }),
        }
      );
      if (!response.ok) throw new Error("Failed to update status");
      fetchProducts();
    } catch (err) {
      alert(err.message);
    }
  };

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
              <span className={`status-badge ${product.status}`}>
                {product.status}
              </span>
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
                <button className="action-btn toggle-btn" onClick={() => toggleStatus(product)}>
                  {product.status === "active" ? "Deactivate" : "Activate"}
                </button>
                <button className="action-btn delete-btn" onClick={() => handleDelete(product.id)}>
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
            <form className="product-form" onSubmit={handleSave}>
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
                  <option value="piece">piece</option>
                  <option value="litre">litre</option>
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
                <button type="submit" className="save-btn">
                  Save
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
