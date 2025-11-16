import React from 'react';
import "./AuthPossibilities.css";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const navigate = useNavigate();
  const { login } = useAuth();

  const handleSubmit = (e) => {
    e.preventDefault();
    const role = email.includes("supplier") ? "supplier" : "consumer";
    login({ role, token: "fake-jwt-token" });
    navigate(role === "supplier" ? "/supplier" : "/consumer");
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        <h2>Welcome Back</h2>
        <p className="signup-subtext">Log in to continue</p>
        <form className="signup-form" onSubmit={handleSubmit}>
          <input type="email" placeholder="Email Address" value={email} onChange={(e) => setEmail(e.target.value)} required />
          <input type="password" placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} required />
          <button type="submit">Log In</button>
          <p className="signup-subtext">Don't have an account yet? <Link to="/signup">Sign Up</Link></p>
        </form>
      </div>
    </div>
  );
}

