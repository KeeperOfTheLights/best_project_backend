import React, { useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import reactLogo from "../../assets/Logo.png";
import "./Navbar.css";

export default function Navbar() {
  const { isLoggedIn, role, logout, token } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
  if (!token) {
    logout();
    navigate("/login");
  }
  }, [token]);

  const getDashboardRoute = () => {
    if (role === "supplier") return "/SupplierDashboard";
    if (role === "consumer") return "/ConsumerDashboard";
    return "/";
  };

  return (
    <nav className="navbar">
      <div className="navbar-left">
        <img src={reactLogo} alt="Project logo" className="navbar-logo" />
        <Link to={getDashboardRoute()} className="navbar-title">
          DV
        </Link>
      </div>

      <div className="navbar-right">
        {!isLoggedIn ? (
          <>
            <Link to="/about" className="inter-btn">About</Link>
            <Link to="/login" className="nav-btn login-btn">Login</Link>
            <Link to="/signup" className="nav-btn signup-btn">Sign Up</Link>
          </>
        ) : (
          <>
            {role === "consumer" && <Link to="/ConsumerCatalog" className="inter-btn">Catalog</Link>}
            {role === "supplier" && <Link to="/SupplierCatalog" className="inter-btn">My Catalog</Link>}

            {role === "supplier" && <Link to="/supplier/products" className="inter-btn">Products</Link>}
            {role === "supplier" && <Link to="/SupplierOrders" className="inter-btn">Orders</Link>}
            {role === "consumer" && <Link to="/ConsumerOrders" className="inter-btn">My Orders</Link>}

            <div className="dropdown">
              <button className="inter-btn dropdown-toggle">Communications ▾</button>
              <div className="dropdown-menu">
                <Link to="/notifications">Notifications</Link>
                <Link to="/chat">Chat</Link>
                {role === "supplier" && <Link to="/supplier/complaints" className="inter-btn">Complaints</Link>}
                {role === "consumer" && <Link to="/consumer/complaints" className="inter-btn">Complaints</Link>}
              </div>
            </div>

            <input type="text" placeholder="Companies, cafes, products..." className="search-input"/>
            <button className="nav-btn login-btn" onClick={() => { logout(); navigate("/login"); }}>Sign Out</button>
          </>
        )}
      </div>
    </nav>
  );
}
