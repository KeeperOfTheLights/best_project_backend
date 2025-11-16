import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import './AuthPossibilities.css'

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const navigate = useNavigate();
  const { login } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();

    const formData = { email, password };

    try {
      const response = await fetch("http://127.0.0.1:8000/api/accounts/login/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      const data = await response.json();

      if (response.ok) {
        // Предполагаем, что сервер возвращает токен и роль
        login({ token: data.token, role: data.role });
        navigate(data.role === "supplier" ? "/supplier" : "/consumer");
      } else {
        alert(JSON.stringify(data, null, 2));
      }
    } catch (error) {
      console.error("Network error:", error);
      alert("Could not connect to server");
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
          <button type="submit">Log In</button>
          <p className="signup-subtext">
            Don't have an account yet? <Link to="/signup">Sign Up</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
