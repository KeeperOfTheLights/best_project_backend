import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider, useAuth } from "./context/Auth-Context";

import Navbar from "./components/common/Navbar";
import Login from "./pages/Shared/Login";
import SignUp from "./pages/Shared/SignUp";
import SupplierDashboard from "./pages/Supplier/SupplierDashboard";
import ConsumerDashboard from "./pages/Consumer/ConsumerDashboard";
import About from "./pages/Shared/About";
import ConsumerCatalog from "./pages/Consumer/ConsumerCatalog";
import SupplierCatalog from "./pages/Supplier/SupplierCatalog";
import ConsumerOrders from "./pages/Consumer/ConsumerOrders";
import SupplierOrders from "./pages/Supplier/SupplierOrders";
import SupplierProducts from "./pages/Supplier/SupplierProducts";
import Chat from "./pages/Shared/Chat";
import ConsumerSupplierProducts from "./pages/Consumer/ConsumerSupplierProducts";
import CComplaints from "./pages/Consumer/ConsumerComplaints";
import SComplaints from "./pages/Supplier/SupplierComplaints";


function RoleRoute({ role, children }) {
  const { isLoggedIn, role: userRole } = useAuth();

  if (!isLoggedIn) return <Navigate to="/login" />;
  if (role && userRole !== role) return <Navigate to="/about" />;

  return children;
}

export default function App() {
  return (
    <AuthProvider>
      <Router>
        <Navbar />
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<SignUp />} />
          <Route path="/about" element={<About />} />
          <Route path="/chat" element={<Chat />} />
          <Route path="/" element={<Navigate to="/about" />} />

          <Route
            path="/SupplierDashboard"
            element={
              <RoleRoute role="supplier">
                <SupplierDashboard />
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
            path="/SupplierCatalog"
            element={
              <RoleRoute role="supplier">
                <SupplierCatalog />
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
          <Route
            path="/supplier/complaints"
            element={
              <RoleRoute role="supplier">
                <SComplaints />
              </RoleRoute>
            }
          />
          
          

          <Route path="*" element={<Navigate to="/about" />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}