import React, { useState } from 'react';
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import "./AuthPossibilities.css";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();
  const { login } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const response = await fetch("http://127.0.0.1:8000/api/accounts/login/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password })
      });

      if (!response.ok) {
        const errData = await response.json();
        throw new Error(errData.detail || "Login failed");
      }

      const data = await response.json();
      // предполагаем, что сервер возвращает { role, token }
      login({ role: data.role, token: data.token });
      navigate(data.role === "supplier" ? "/supplier" : "/consumer");

    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        <h2>Welcome Back</h2>
        <p className="signup-subtext">Log in to continue</p>

        <form className="signup-form" onSubmit={handleSubmit}>
          <input
            type="email"
            placeholder="Email Address"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />

          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />

          <button type="submit" disabled={loading}>
            {loading ? "Logging in..." : "Log In"}
          </button>

          {error && <p className="signup-error">{error}</p>}

          <p className="signup-subtext">
            Don't have an account yet? <Link to="/signup">Sign Up</Link>
          </p>
        </form>
      </div>
    </div>
  );
}