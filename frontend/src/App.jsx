import React, { Suspense, lazy } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider, useAuth } from "./context/Auth-Context";
import { is_supplier_side } from "./utils/roleUtils";
import './i18n';

import Navbar from "./components/common/Navbar";
import Login from "./pages/Shared/Login";
import SignUp from "./pages/Shared/SignUp";
const SupplierDashboard = lazy(() => import("./pages/Supplier/SupplierDashboard"));
const ConsumerDashboard = lazy(() => import("./pages/Consumer/ConsumerDashboard"));
const About = lazy(() => import("./pages/Shared/About"));
const ConsumerCatalog = lazy(() => import("./pages/Consumer/ConsumerCatalog"));
const SupplierCatalog = lazy(() => import("./pages/Supplier/SupplierCatalog"));
const ConsumerOrders = lazy(() => import("./pages/Consumer/ConsumerOrders"));
const SupplierOrders = lazy(() => import("./pages/Supplier/SupplierOrders"));
const SupplierProducts = lazy(() => import("./pages/Supplier/SupplierProducts"));
const Chat = lazy(() => import("./pages/Shared/Chat"));
const Search = lazy(() => import("./pages/Shared/Search"));
const ConsumerSupplierProducts = lazy(() => import("./pages/Consumer/ConsumerSupplierProducts"));
const CComplaints = lazy(() => import("./pages/Consumer/ConsumerComplaints"));
const SComplaints = lazy(() => import("./pages/Supplier/SupplierComplaints"));
const CompanyManagement = lazy(() => import("./pages/Supplier/CompanyManagement"));

const LoadingFallback = () => (
  <div style={{ 
    display: 'flex', 
    justifyContent: 'center', 
    alignItems: 'center', 
    height: '100vh',
    fontSize: '1.2rem'
  }}>
    Loading...
  </div>
);

function RoleRoute({ role, children }) {
  const { isLoggedIn, role: userRole, loading } = useAuth();

  if (loading) return <LoadingFallback />;

  if (!isLoggedIn) return <Navigate to="/login" replace />;
  
  if (role === "supplier") {
    if (!is_supplier_side(userRole)) return <Navigate to="/" replace />;
  } else if (role && userRole !== role) {
    return <Navigate to="/" replace />;
  }

  return children;
}

export default function App() {
  return (
    <AuthProvider>
      <Router>
        <Navbar />
        <Suspense fallback={<LoadingFallback />}>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/signup" element={<SignUp />} />
            <Route path="/about" element={<About />} />
            <Route path="/chat" element={<Chat />} />
            <Route path="/search" element={<Search />} />
            <Route path="/" element={<Navigate to="/about" replace />} />

          <Route
            path="/SupplierDashboard"
            element={
              <RoleRoute role="supplier">
                <SupplierDashboard />
              </RoleRoute>
            }
          />
          <Route
            path="/SupplierCatalog"
            element={
              <RoleRoute role="supplier">
                <SupplierCatalog />
              </RoleRoute>
            }
          />
          <Route
            path="/SupplierOrders"
            element={
              <RoleRoute role="supplier">
                <SupplierOrders />
              </RoleRoute>
            }
          />
          <Route
            path="/supplier/products"
            element={
              <RoleRoute role="supplier">
                <SupplierProducts />
              </RoleRoute>
            }
          />
          <Route
            path="/supplier/complaints"
            element={
              <RoleRoute role="supplier">
                <SComplaints />
              </RoleRoute>
            }
          />
          <Route
            path="/supplier/company"
            element={
              <RoleRoute role="supplier">
                <CompanyManagement />
              </RoleRoute>
            }
          />

          <Route
            path="/ConsumerDashboard"
            element={
              <RoleRoute role="consumer">
                <ConsumerDashboard />
              </RoleRoute>
            }
          />
          <Route
            path="/ConsumerCatalog"
            element={
              <RoleRoute role="consumer">
                <ConsumerCatalog />
              </RoleRoute>
            }
          />
          <Route
            path="/ConsumerOrders"
            element={
              <RoleRoute role="consumer">
                <ConsumerOrders />
              </RoleRoute>
            }
          />
          <Route
            path="/consumer/supplier/:supplierId/products"
            element={
              <RoleRoute role="consumer">
                <ConsumerSupplierProducts />
              </RoleRoute>
            }
          />
          <Route
            path="/consumer/complaints"
            element={
              <RoleRoute role="consumer">
                <CComplaints />
              </RoleRoute>
            }
          />

            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Suspense>
      </Router>
    </AuthProvider>
  );
}
