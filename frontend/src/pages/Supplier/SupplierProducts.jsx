import React, { useState, useEffect } from "react";
import "./SupplierProducts.css";
import { useAuth } from "../../context/Auth-Context";

export default function SupplierProducts() {
  const { token } = useAuth(); // получаем токен из контекста
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

  // Загружаем продукты с бэкенда
  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const response = await fetch("http://127.0.0.1:8000/api/accounts/products/", {
        headers: { Authorization: `Token ${token}` },
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
          Authorization: `Token ${token}`,
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
          headers: { Authorization: `Token ${token}` },
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
            Authorization: `Token ${token}`,
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
      <h2>Product Catalog</h2>
      <button className="add-product-btn" onClick={handleAddClick}>
        + Add New Product
      </button>
      <div className="products-grid">
        {products.map((product) => (
          <div key={product.id} className="product-card">
            <h3>{product.name}</h3>
            <p>{product.category}</p>
            <p>{product.price} ₸/{product.unit}</p>
            <p>{product.status}</p>
            <button onClick={() => handleEditClick(product)}>Edit</button>
            <button onClick={() => toggleStatus(product)}>
              {product.status === "active" ? "Deactivate" : "Activate"}
            </button>
            <button onClick={() => handleDelete(product.id)}>Delete</button>
          </div>
        ))}
      </div>
      {/* Тут можно вставить модальное окно для добавления/редактирования */}
    </div>
  );
}