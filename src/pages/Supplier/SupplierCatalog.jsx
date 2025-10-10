import "./SupplierCatalog.css";

const dummyPlaces = [
  {
    id: 1,
    name: "Cozy Mountain Cabin",
    location: "Almaty Region, Kazakhstan",
    price: 15000,
    capacity: 4,
    image: "https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=400",
    amenities: ["WiFi", "Kitchen", "Heating", "Parking"],
    status: "available"
  },
  {
    id: 2,
    name: "Lakeside Villa",
    location: "Borovoe, Kazakhstan",
    price: 25000,
    capacity: 8,
    image: "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400",
    amenities: ["WiFi", "Pool", "BBQ Area", "Lake Access"],
    status: "available"
  },
  {
    id: 3,
    name: "City Apartment",
    location: "Astana, Kazakhstan",
    price: 12000,
    capacity: 2,
    image: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400",
    amenities: ["WiFi", "Kitchen", "City View", "Gym"],
    status: "booked"
  }
];

export default function SupplierCatalog() {
  return (
    <div className="catalog-container">
      <div className="catalog-header">
        <h2>My Properties</h2>
        <button className="add-place-btn">+ Add New Place</button>
      </div>
      
      <div className="catalog-grid">
        {dummyPlaces.map((place) => (
          <div key={place.id} className="place-card">
            <div className="place-image-wrapper">
              <img src={place.image} alt={place.name} className="place-image" />
              <span className={`status-badge ${place.status}`}>
                {place.status === "available" ? "Available" : "Booked"}
              </span>
            </div>
            
            <div className="place-content">
              <h3 className="place-name">{place.name}</h3>
              <p className="place-location">📍 {place.location}</p>
              
              <div className="place-details">
                <span className="place-capacity">👥 Up to {place.capacity} guests</span>
                <span className="place-price">{place.price.toLocaleString()} ₸/night</span>
              </div>
              
              <div className="place-amenities">
                {place.amenities.map((amenity, index) => (
                  <span key={index} className="amenity-tag">{amenity}</span>
                ))}
              </div>
              
              <div className="place-actions">
                <button className="action-btn edit-btn">Edit</button>
                <button className="action-btn delete-btn">Delete</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}