import React, { useState } from "react";
import "./SupplierCatalog.css";

const suppliersData = [
  {
    id: 1,
    name: "Bahandi",
    category: "Burger & Steaks",
    location: "Almaty, Kazakhstan",
    verified: true,
    rating: 4.9,
    image: "https://imageproxy.wolt.com/assets/673717b3d224a4218283f4ba",
    supplies: ["Chicken 1 burger", "Beef 2 burger", "nuggets"],
    contact: "baha@bahandi.kz",
  },
  {
    id: 2,
    name: "Popeyes",
    category: "Burgers & Chicken",
    location: "Astana, Kazakhstan",
    verified: false,
    rating: 4.4,
    image: "https://popeyes.kz/icons/logo2.png",
    supplies: ["Chicken", "Nuggets", "Fries"],
    contact: "info@poopeyes.kz",
  }
];

const SupplierCatalog = () => {
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("all");

  const filtered = suppliersData.filter((s) => {
    const matchesSearch = s.name.toLowerCase().includes(search.toLowerCase());
    const matchesCategory = category === "all" || s.category.toLowerCase() === category.toLowerCase();
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="supplier-catalog-container">
      <div className="catalog-header">
        <h2>Suppliers for Hotels & Cafes</h2>
      </div>

      <div className="suppliers-grid">
        {filtered.map((s) => (
          <div className="supplier-card" key={s.id}>
            <div className="supplier-image-wrapper">
              <img src={s.image} alt={s.name} className="supplier-image" />
              {s.verified && <div className="verified-badge">Verified</div>}
            </div>

            <div className="supplier-content">
              <div className="supplier-header">
                <h3 className="supplier-name">{s.name}</h3>
              </div>
              
              <p className="supplier-category">{s.category}</p>
              <p className="supplier-location">{s.location}</p>

              <div className="supplier-info">
                <div className="info-item">
                  <span className="info-label">Email:</span>
                  <span className="info-value">{s.contact}</span>
                </div>
                <div className="info-item">
                  <span className="info-label">Products:</span>
                  <span className="info-value">{s.supplies.length}</span>
                </div>
              </div>

              <div className="supplies-list">
                <p className="supplies-label">Main Products:</p>
                <div className="supplies-tags">
                  {s.supplies.map((p, i) => (
                    <span key={i} className="supply-tag">
                      {p}
                    </span>
                  ))}
                </div>
              </div>

              <div className="supplier-actions">
                <button className="view-btn">View Details</button>
                <button className="contact-btn">Contact</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default SupplierCatalog;
