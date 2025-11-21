import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import { is_supplier_side } from "../../utils/roleUtils";
import "./AuthPossibilities.css";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errorMsg, setErrorMsg] = useState("");

  const navigate = useNavigate();
  const { login } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg("");

    try {
      const response = await fetch("http://127.0.0.1:8000/api/accounts/login/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });

      const data = await response.json();

      if (response.ok) {
        login({ token: data.access, refreshToken: data.refresh, role: data.role, id: data.id });
        navigate(is_supplier_side(data.role) ? "/SupplierDashboard" : "/ConsumerDashboard");
      } else {
        let message = data?.non_field_errors?.[0] || "Invalid email or password";
        setErrorMsg(message);
      }
    } catch (error) {
      console.error("Network error:", error);
      setErrorMsg("Could not connect to server");
    }
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        <h2>Welcome Back</h2>
        <p className="signup-subtext">Log in to continue</p>

        {errorMsg && <p className="error-message">{errorMsg}</p>}

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