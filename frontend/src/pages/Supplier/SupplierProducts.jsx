import React from 'react';
import { useState } from "react";
import "./SupplierProducts.css";

const dummyProducts = [
  {
    id: 1,
    name: "Fresh Tomatoes",
    category: "Vegetables",
    price: 750,
    unit: "kg",
    stock: 500,
    minOrder: 10,
    image: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/2022_Zeekr_001_%28front%29.jpg/1200px-2022_Zeekr_001_%28front%29.jpg",
    description: "Fresh red tomatoes, locally grown",
    status: "active"
  },
  {
    id: 2,
    name: "Organic Cucumbers",
    category: "Vegetables",
    price: 600,
    unit: "kg",
    stock: 300,
    minOrder: 5,
    image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3YrwrSXHo_BMRvfM9g_OAmRTTnHmeqbY-Sw&s",
    description: "Organic cucumbers from local farms",
    status: "active"
  },
  {
    id: 3,
    name: "Premium Beef",
    category: "Meat",
    price: 2000,
    unit: "kg",
    stock: 150,
    minOrder: 3,
    image: "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400",
    description: "Premium quality beef, grain-fed",
    status: "inactive"
  }
];

export default function SupplierProducts() {
  const [products, setProducts] = useState(dummyProducts);
  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState("add"); // "add" or "edit"
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
    status: "active"
  });

  // Open modal for adding new product
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
      status: "active"
    });
    setShowModal(true);
  };

  // Open modal for editing existing product
  const handleEditClick = (product) => {
    setModalMode("edit");
    setCurrentProduct(product);
    setFormData({
      name: product.name,
      category: product.category,
      price: product.price,
      unit: product.unit,
      stock: product.stock,
      minOrder: product.minOrder,
      image: product.image,
      description: product.description,
      status: product.status
    });
    setShowModal(true);
  };

  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  // Save product (add or update)
  const handleSave = (e) => {
    e.preventDefault();

    if (modalMode === "add") {
      // Add new product
      const newProduct = {
        id: products.length + 1,
        ...formData,
        price: parseFloat(formData.price),
        stock: parseInt(formData.stock),
        minOrder: parseInt(formData.minOrder)
      };
      setProducts([...products, newProduct]);
    } else {
      // Update existing product
      setProducts(products.map(p => 
        p.id === currentProduct.id 
          ? { 
              ...p, 
              ...formData,
              price: parseFloat(formData.price),
              stock: parseInt(formData.stock),
              minOrder: parseInt(formData.minOrder)
            }
          : p
      ));
    }

    setShowModal(false);
  };

  // Delete product
  const handleDelete = (productId) => {
    if (window.confirm("Are you sure you want to delete this product?")) {
      setProducts(products.filter(p => p.id !== productId));
    }
  };

  // Toggle product status
  const toggleStatus = (productId) => {
    setProducts(products.map(p => 
      p.id === productId 
        ? { ...p, status: p.status === "active" ? "inactive" : "active" }
        : p
    ));
  };

  return (
    <div className="products-container">
      <div className="products-header">
        <h2>Product Catalog</h2>
        
      </div>
      <button className="add-product-btn" onClick={handleAddClick}>
          + Add New Product
        </button>

      <div className="products-stats">
        <div className="stat-box">
          <h3>{products.length}</h3>
          <p>Total Products</p>
        </div>
        <div className="stat-box">
          <h3>{products.filter(p => p.status === "active").length}</h3>
          <p>Active</p>
        </div>
        <div className="stat-box">
          <h3>{products.filter(p => p.status === "inactive").length}</h3>
          <p>Inactive</p>
        </div>
      </div>

      <div className="products-grid">
        {products.map((product) => (
          <div key={product.id} className="product-card">
            <div className="product-image-wrapper">
              <img src={product.image} alt={product.name} className="product-image" />
              <span className={`status-badge ${product.status}`}>
                {product.status === "active" ? "Active" : "Inactive"}
              </span>
            </div>

            <div className="product-content">
              <h3 className="product-name">{product.name}</h3>
              <p className="product-category">{product.category}</p>
              <p className="product-description">{product.description}</p>

              <div className="product-details-grid">
                <div className="detail-item">
                  <span className="detail-label">Price:</span>
                  <span className="detail-value">{product.price} ₸/{product.unit}</span>
                </div>
                <div className="detail-item">
                  <span className="detail-label">Stock:</span>
                  <span className="detail-value">{product.stock} {product.unit}</span>
                </div>
                <div className="detail-item">
                  <span className="detail-label">Min Order:</span>
                  <span className="detail-value">{product.minOrder} {product.unit}</span>
                </div>
              </div>

              <div className="product-actions">
                <button 
                  className="action-btn edit-btn" 
                  onClick={() => handleEditClick(product)}
                >
                  Edit
                </button>
                <button 
                  className="action-btn toggle-btn"
                  onClick={() => toggleStatus(product.id)}
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

      {/* Modal for Add/Edit */}
      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>{modalMode === "add" ? "Add New Product" : "Edit Product"}</h2>
              <button className="close-btn" onClick={() => setShowModal(false)}>
                ✕
              </button>
            </div>

            <form className="product-form" onSubmit={handleSave}>
              <div className="form-row">
                <div className="form-group">
                  <label>Product Name *</label>
                  <input
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    required
                    placeholder="e.g., Fresh Tomatoes"
                  />
                </div>

                <div className="form-group">
                  <label>Category *</label>
                  <select
                    name="category"
                    value={formData.category}
                    onChange={handleInputChange}
                    required
                  >
                    <option value="">Select Category</option>
                    <option value="Vegetables">Vegetables</option>
                    <option value="Fruits">Fruits</option>
                    <option value="Meat">Meat</option>
                    <option value="Dairy">Dairy</option>
                    <option value="Bakery">Bakery</option>
                    <option value="Beverages">Beverages</option>
                  </select>
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Price (₸) *</label>
                  <input
                    type="number"
                    name="price"
                    value={formData.price}
                    onChange={handleInputChange}
                    required
                    min="0"
                    step="0.01"
                    placeholder="750"
                  />
                </div>

                <div className="form-group">
                  <label>Unit *</label>
                  <select
                    name="unit"
                    value={formData.unit}
                    onChange={handleInputChange}
                    required
                  >
                    <option value="kg">kg</option>
                    <option value="pcs">pcs</option>
                    <option value="L">L</option>
                    <option value="box">box</option>
                  </select>
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Stock Quantity *</label>
                  <input
                    type="number"
                    name="stock"
                    value={formData.stock}
                    onChange={handleInputChange}
                    required
                    min="0"
                    placeholder="500"
                  />
                </div>

                <div className="form-group">
                  <label>Minimum Order *</label>
                  <input
                    type="number"
                    name="minOrder"
                    value={formData.minOrder}
                    onChange={handleInputChange}
                    required
                    min="1"
                    placeholder="10"
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Image URL</label>
                <input
                  type="url"
                  name="image"
                  value={formData.image}
                  onChange={handleInputChange}
                  placeholder="https://example.com/image.jpg"
                />
              </div>

              <div className="form-group">
                <label>Description</label>
                <textarea
                  name="description"
                  value={formData.description}
                  onChange={handleInputChange}
                  rows="3"
                  placeholder="Product description..."
                />
              </div>

              <div className="form-group">
                <label>Status</label>
                <select
                  name="status"
                  value={formData.status}
                  onChange={handleInputChange}
                >
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                </select>
              </div>

              <div className="modal-actions">
                <button 
                  type="button" 
                  className="cancel-btn"
                  onClick={() => setShowModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="save-btn">
                  {modalMode === "add" ? "Add Product" : "Save Changes"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}