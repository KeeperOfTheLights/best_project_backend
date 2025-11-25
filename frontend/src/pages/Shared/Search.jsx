import React, { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import "./Search.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function Search() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const { token, logout, role, loading: authLoading } = useAuth();

  const [query, setQuery] = useState(searchParams.get("q") || "");
  const [results, setResults] = useState({
    suppliers: [],
    categories: [],
    products: [],
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (authLoading) return;
    
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    if (role !== "consumer") {
      navigate("/");
      return;
    }

    const searchQuery = searchParams.get("q") || "";
    setQuery(searchQuery);
    
    if (searchQuery.trim()) {
      performSearch(searchQuery);
    } else {
      setResults({ suppliers: [], categories: [], products: [] });
    }
  }, [searchParams, token, role, authLoading]);

  const performSearch = async (searchQuery) => {
    if (!searchQuery.trim()) {
      setResults({ suppliers: [], categories: [], products: [] });
      return;
    }

    setLoading(true);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/search/?q=${encodeURIComponent(searchQuery)}`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const text = await res.text();
        throw new Error(text || t("search.failedToSearch"));
      }

      const data = await res.json();
      setResults({
        suppliers: Array.isArray(data.suppliers) ? data.suppliers : [],
        categories: Array.isArray(data.categories) ? data.categories : [],
        products: Array.isArray(data.products) ? data.products : [],
      });
    } catch (err) {
      setError(err.message || t("search.failedToSearch"));
      setResults({ suppliers: [], categories: [], products: [] });
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (e) => {
    e.preventDefault();
    const trimmedQuery = query.trim();
    if (trimmedQuery) {
      setSearchParams({ q: trimmedQuery });
    }
  };

  const handleSupplierClick = (supplierId) => {
    navigate(`/consumer/supplier/${supplierId}/products`);
  };

  const handleCategoryClick = (category) => {
    navigate(`/ConsumerCatalog`, { state: { filterCategory: category } });
  };

  const handleProductClick = (product) => {
    if (product.supplier) {
      navigate(`/consumer/supplier/${product.supplier}/products`);
    } else if (product.supplier_name) {
      const supplier = results.suppliers.find(
        (s) => s.full_name === product.supplier_name
      );
      if (supplier) {
        navigate(`/consumer/supplier/${supplier.id}/products`);
      }
    }
  };

  const hasResults =
    results.suppliers.length > 0 ||
    results.categories.length > 0 ||
    results.products.length > 0;

  return (
    <div className="search-page-container">
      <div className="search-header">
        <h1>{t("search.search")}</h1>
        <form onSubmit={handleSearch} className="search-form">
          <input
            type="text"
            placeholder={t("search.searchPlaceholder")}
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="search-input-large"
          />
          <button type="submit" className="search-btn">
            {t("search.search")}
          </button>
        </form>
      </div>

      {loading && (
        <div className="search-loading">
          <p>{t("search.searching")}</p>
        </div>
      )}

      {error && (
        <div className="search-error">
          <p>{error}</p>
        </div>
      )}

      {!loading && !error && query.trim() && !hasResults && (
        <div className="search-empty">
          <p>{t("search.noResults")} "{query}"</p>
        </div>
      )}

      {!loading && !error && hasResults && (
        <div className="search-results">
          {results.suppliers.length > 0 && (
            <div className="search-section">
              <h2>{t("search.suppliers")} ({results.suppliers.length})</h2>
              <div className="suppliers-grid">
                {results.suppliers.map((supplier) => (
                  <div
                    key={supplier.id}
                    className="supplier-card"
                    onClick={() => handleSupplierClick(supplier.id)}
                  >
                    <div className="supplier-avatar">
                      {supplier.supplier_company?.[0] ||
                        supplier.full_name?.[0] ||
                        "S"}
                    </div>
                    <div className="supplier-info">
                      <h3>{supplier.full_name}</h3>
                      {supplier.supplier_company && (
                        <p className="supplier-company">
                          {supplier.supplier_company}
                        </p>
                      )}
                      <p className="supplier-email">{supplier.email}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {results.categories.length > 0 && (
            <div className="search-section">
              <h2>{t("search.categories")} ({results.categories.length})</h2>
              <div className="categories-list">
                {results.categories.map((category, index) => (
                  <button
                    key={index}
                    className="category-chip"
                    onClick={() => handleCategoryClick(category)}
                  >
                    {category}
                  </button>
                ))}
              </div>
            </div>
          )}

          {results.products.length > 0 && (
            <div className="search-section">
              <h2>{t("search.products")} ({results.products.length})</h2>
              <div className="products-grid">
                {results.products.map((product) => (
                  <div
                    key={product.id}
                    className="product-card"
                    onClick={() => handleProductClick(product)}
                  >
                    {product.image ? (
                      <img
                        src={product.image}
                        alt={product.name}
                        className="product-image"
                      />
                    ) : (
                      <div className="product-image-placeholder">
                        {product.name?.[0] || "P"}
                      </div>
                    )}
                    <div className="product-info">
                      <h3>{product.name}</h3>
                      <p className="product-category">{product.category}</p>
                      <p className="product-supplier">
                        by {product.supplier_name}
                      </p>
                      <p className="product-price">
                        ₸{product.price} / {product.unit}
                      </p>
                      {product.description && (
                        <p className="product-description">
                          {product.description.length > 100
                            ? `${product.description.substring(0, 100)}...`
                            : product.description}
                        </p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

