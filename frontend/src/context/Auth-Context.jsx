import React, { createContext, useContext, useState, useEffect } from "react";

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [role, setRole] = useState(null);
  const [token, setToken] = useState(null);
  const [userId, setUserId] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedToken = localStorage.getItem("token");
    const savedRefreshToken = localStorage.getItem("refreshToken");
    const savedRole = localStorage.getItem("role");
    const savedUserId = localStorage.getItem("userId");

    if (savedToken && savedRole) {
      setToken(savedToken);
      setRole(savedRole);
      setUserId(savedUserId ? Number(savedUserId) : null);
      setIsLoggedIn(true);
      
      if (savedRefreshToken) {
        localStorage.setItem("refreshToken", savedRefreshToken);
      }
    }

    setLoading(false);
  }, []);

  const refreshAccessToken = async () => {
    const refreshToken = localStorage.getItem("refreshToken");
    if (!refreshToken) {
      logout();
      return null;
    }

    try {
      const response = await fetch("http://127.0.0.1:8000/api/accounts/token/refresh/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ refresh: refreshToken }),
      });

      if (response.ok) {
        const data = await response.json();
        const newAccessToken = data.access;
        setToken(newAccessToken);
        localStorage.setItem("token", newAccessToken);
        return newAccessToken;
      } else {
        logout();
        return null;
      }
    } catch (error) {
      console.error("Token refresh failed:", error);
      logout();
      return null;
    }
  };

  const login = ({ token, refreshToken, role, id }) => {
    setToken(token);
    setRole(role);
    setUserId(id ? Number(id) : null);
    setIsLoggedIn(true);

    localStorage.setItem("token", token);
    localStorage.setItem("role", role);
    if (refreshToken) localStorage.setItem("refreshToken", refreshToken);
    if (id) localStorage.setItem("userId", id.toString());
  };

  const logout = () => {
    setToken(null);
    setRole(null);
    setUserId(null);
    setIsLoggedIn(false);

    localStorage.removeItem("token");
    localStorage.removeItem("refreshToken");
    localStorage.removeItem("role");
    localStorage.removeItem("userId");
  };

  return (
    <AuthContext.Provider value={{ isLoggedIn, role, token, userId, login, logout, loading, refreshAccessToken }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
