import React from 'react';
import { createContext, useContext, useState } from "react";

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [isLoggedIn, setIsLoggedIn] = useState(!!localStorage.getItem("token"));
  const [role, setRole] = useState(localStorage.getItem("role") || null);

  const login = (userData) => {
    setIsLoggedIn(true);
    setRole(userData.role);
    localStorage.setItem("token", userData.token);
    localStorage.setItem("role", userData.role);
  };

  const logout = () => {
    setIsLoggedIn(false);
    setRole(null);
    localStorage.removeItem("token");
    localStorage.removeItem("role");
  };

  return (
    <AuthContext.Provider value={{ isLoggedIn, role, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}


export const useAuth = () => useContext(AuthContext);
