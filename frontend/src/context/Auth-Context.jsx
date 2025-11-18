import React, { createContext, useContext, useState, useEffect } from "react";

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [role, setRole] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);

  // Проверка localStorage при монтировании
  useEffect(() => {
    const savedToken = localStorage.getItem("token");
    const savedRole = localStorage.getItem("role");

    if (savedToken && savedRole) {
      setToken(savedToken);
      setRole(savedRole);
      setIsLoggedIn(true);
    }

    setLoading(false);
  }, []);

  const login = ({ token, role }) => {
    setToken(token);
    setRole(role);
    setIsLoggedIn(true);

    localStorage.setItem("token", token);
    localStorage.setItem("role", role);
  };

  const logout = () => {
    setToken(null);
    setRole(null);
    setIsLoggedIn(false);

    localStorage.removeItem("token");
    localStorage.removeItem("role");
  };

  return (
    <AuthContext.Provider value={{ isLoggedIn, role, token, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
