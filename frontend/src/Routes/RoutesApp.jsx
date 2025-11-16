import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { useAuth } from "./AuthContext";

import Login from "./pages/Login";
import SignUp from "./pages/SignUp";
import SupplierDashboard from "./pages/SupplierDashboard";
import ConsumerDashboard from "./pages/ConsumerDashboard";
import About from "./pages/About";
import Navbar from "./components/Navbar";

function RoleRoute({ role, children }) {
  const { isLoggedIn, role: userRole } = useAuth();
  if (!isLoggedIn) return <Navigate to="/login" />;
  if (role && userRole !== role) return <Navigate to="/" />;
  return children;
}

export default function AppRoutes() {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<SignUp />} />
        <Route path="/about" element={<About />} />

        <Route
          path="/supplier"
          element={
            <RoleRoute role="supplier">
              <SupplierDashboard />
            </RoleRoute>
          }
        />
        <Route
          path="/consumer"
          element={
            <RoleRoute role="consumer">
              <ConsumerDashboard />
            </RoleRoute>
          }
        />

        <Route path="*" element={<Navigate to="/about" />} />
      </Routes>
    </Router>
  );
}
