import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useAuth } from "../../context/Auth-Context";
import { is_supplier_side, is_catalog_manager, is_sales } from "../../utils/roleUtils";
import LanguageSwitcher from "./LanguageSwitcher";
import reactLogo from "../../assets/Logo.png";
import "./Navbar.css";

export default function Navbar() {
  const { t } = useTranslation();
  const { isLoggedIn, role, logout, token, loading } = useAuth();
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState("");

  const getDashboardRoute = () => {
    if (is_supplier_side(role)) return "/SupplierDashboard";
    if (role === "consumer") return "/ConsumerDashboard";
    return "/";
  };

  const isAuthenticated = isLoggedIn && token;

  return (
    <nav className="navbar" role="navigation" aria-label="Main navigation">
      <div className="navbar-left">
        <img src={reactLogo} alt="Project logo" className="navbar-logo" />
        <Link to={getDashboardRoute()} className="navbar-title" aria-label="Go to dashboard">
          DV
        </Link>
      </div>

      <div className="navbar-right">
        {loading ? null : !isAuthenticated ? (
          <>
            <Link to="/about" className="inter-btn">{t("common.about")}</Link>
            <Link to="/login" className="nav-btn login-btn">{t("common.login")}</Link>
            <Link to="/signup" className="nav-btn signup-btn">{t("common.signup")}</Link>
            <LanguageSwitcher />
          </>
        ) : (
          <>
            {role === "consumer" && <Link to="/ConsumerCatalog" className="inter-btn">{t("navbar.catalog")}</Link>}
            {is_catalog_manager(role) && <Link to="/SupplierCatalog" className="inter-btn">{t("navbar.myCatalog")}</Link>}

            {is_catalog_manager(role) && <Link to="/supplier/products" className="inter-btn">{t("navbar.products")}</Link>}
            {is_supplier_side(role) && <Link to="/SupplierOrders" className="inter-btn">{t("navbar.orders")}</Link>}
            {role === "owner" && <Link to="/supplier/company" className="inter-btn">{t("navbar.company")}</Link>}
            {role === "consumer" && <Link to="/ConsumerOrders" className="inter-btn">{t("navbar.myOrders")}</Link>}

            <div className="dropdown">
              <button className="inter-btn dropdown-toggle">{t("navbar.communications")} ▾</button>
              <div className="dropdown-menu">
                <Link to="/chat">{t("navbar.chat")}</Link>
                {is_supplier_side(role) && <Link to="/supplier/complaints" className="inter-btn">{t("navbar.complaints")}</Link>}
                {role === "consumer" && <Link to="/consumer/complaints" className="inter-btn">{t("navbar.complaints")}</Link>}
              </div>
            </div>

            {role === "consumer" && (
              <form
                onSubmit={(e) => {
                  e.preventDefault();
                  if (searchQuery.trim()) {
                    navigate(`/search?q=${encodeURIComponent(searchQuery.trim())}`);
                  }
                }}
                style={{ display: "flex", gap: "5px" }}
              >
                <input
                  type="text"
                  placeholder={t("navbar.searchPlaceholder")}
                  className="search-input"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </form>
            )}
            <LanguageSwitcher />
            <button className="nav-btn login-btn" onClick={() => { logout(); navigate("/login"); }}>{t("common.logout")}</button>
          </>
        )}
      </div>
    </nav>
  );
}
