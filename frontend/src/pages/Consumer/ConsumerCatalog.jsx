import "./ConsumerCatalog.css";
import React from 'react';

const dummySuppliers = [
  {
    id: 1,
    name: "Magnum",
    category: "Vegetables & Fruits",
    location: "Almaty Region",
    rating: 4.8,
    image: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Magnum_Cash_%26_Carry.svg/1024px-Magnum_Cash_%26_Carry.svg.png",
    products: ["Tomatoes", "Cucumbers", "Oil", "Lettuce"],
    minOrder: 500000,
    delivery: "Next day",
    verified: true
  },
  {
    id: 2,
    name: "Bogdan",
    category: "Meat",
    location: "Almaty city",
    rating: 4.9,
    image: "https://cdn.nba.com/headshots/nba/latest/1040x760/203992.png",
    products: ["Beef", "Chicken", "Horse"],
    minOrder: 1500000,
    delivery: "In a week",
    verified: true
  }
];

export default function ConsumerCatalog() {
  return (
    <div className="consumer-catalog-container">
      <div className="catalog-header">
        <h2>Find Suppliers</h2>
      </div>
      
      <div className="suppliers-grid">
        {dummySuppliers.map((supplier) => (
          <div key={supplier.id} className="supplier-card">
            <div className="supplier-image-wrapper">
              <img src={supplier.image} alt={supplier.name} className="supplier-image" />
              {supplier.verified && (
                <span className="verified-badge">✓ Verified</span>
              )}
            </div>
            
            <div className="supplier-content">
              <div className="supplier-header">
                <h3 className="supplier-name">{supplier.name}</h3>
                
              </div>
              
              <p className="supplier-category">{supplier.category}</p>
              <p className="supplier-location">📍 {supplier.location}</p>
              
              <div className="supplier-info">
                <div className="info-item">
                  <span className="info-label">Min. Order:</span>
                  <span className="info-value">{supplier.minOrder.toLocaleString()} ₸</span>
                </div>
                <div className="info-item">
                  <span className="info-label">Delivery:</span>
                  <span className="info-value">{supplier.delivery}</span>
                </div>
              </div>
              
              <div className="products-list">
                <p className="products-label">Available Products:</p>
                <div className="products-tags">
                  {supplier.products.map((product, index) => (
                    <span key={index} className="product-tag">{product}</span>
                  ))}
                </div>
              </div>
              
              <div className="supplier-actions">
                <button className="action-btn view-btn">View Details</button>
                <button className="action-btn contact-btn">Contact Supplier</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}