import "./ConsumerCatalog.css";

const dummySuppliers = [
  {
    id: 1,
    name: "Fresh Farm Products",
    category: "Vegetables & Fruits",
    location: "Almaty Region",
    rating: 4.8,
    image: "https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400",
    products: ["Tomatoes", "Cucumbers", "Peppers", "Lettuce"],
    minOrder: 5000,
    delivery: "Next day",
    verified: true
  },
  {
    id: 2,
    name: "Premium Meat Supply",
    category: "Meat & Poultry",
    location: "Astana",
    rating: 4.9,
    image: "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400",
    products: ["Beef", "Chicken", "Lamb", "Pork"],
    minOrder: 15000,
    delivery: "Same day",
    verified: true
  },
  {
    id: 3,
    name: "Dairy Dreams Co.",
    category: "Dairy Products",
    location: "Shymkent",
    rating: 4.6,
    image: "https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400",
    products: ["Milk", "Cheese", "Butter", "Yogurt"],
    minOrder: 8000,
    delivery: "Next day",
    verified: false
  }
];

export default function ConsumerCatalog() {
  return (
    <div className="consumer-catalog-container">
      <div className="catalog-header">
        <h2>Find Suppliers</h2>
        <div className="header-actions">
          <input 
            type="text" 
            placeholder="Search suppliers..." 
            className="search-input"
          />
          <select className="filter-select">
            <option value="">All Categories</option>
            <option value="vegetables">Vegetables & Fruits</option>
            <option value="meat">Meat & Poultry</option>
            <option value="dairy">Dairy Products</option>
            <option value="bakery">Bakery</option>
            <option value="beverages">Beverages</option>
          </select>
        </div>
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
                <div className="supplier-rating">
                  ⭐ {supplier.rating}
                </div>
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