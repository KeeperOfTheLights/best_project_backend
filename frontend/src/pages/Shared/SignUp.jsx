import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import "./AuthPossibilities.css";

export default function SignUp() {
  const [role, setRole] = useState("consumer");
  const [fullName, setFullName] = useState("");
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [repeatPassword, setRepeatPassword] = useState("");
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (password !== repeatPassword) {
      alert("Passwords do not match!");
      return;
    }

    const formData = {
      full_name: fullName,
      username: username,
      email: email,
      password: password,
      role: role,
      password2: repeatPassword
    };

    try {
      const response = await fetch("http://127.0.0.1:8000/api/accounts/register/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(formData),
      });

      const data = await response.json();

      if (response.ok) {
        login({ role: data.role, token: data.token });
        navigate(role === "supplier" ? "/supplier" : "/consumer");
      } else {
        alert(JSON.stringify);
      }
    } catch (error) {
      console.error("Network error:", error);
      alert("Could not connect to server");
    }
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        <h2>Create an Account</h2>
        <p className="signup-subtext">Join Daivinvhik today 💏</p>

        <form className="signup-form" onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="Full Name"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            required
          />
          <input
            type="text"
            placeholder="Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            required
          />
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
          <input
            type="password"
            placeholder="Repeat Password"
            value={repeatPassword}
            onChange={(e) => setRepeatPassword(e.target.value)}
            required
          />

          <div className="role-toggle">
            <button
              type="button"
              className={`role-btn ${role === "consumer" ? "active" : ""}`}
              onClick={() => setRole("consumer")}
            >
              Consumer
            </button>
            <button
              type="button"
              className={`role-btn ${role === "supplier" ? "active" : ""}`}
              onClick={() => setRole("supplier")}
            >
              Supplier
            </button>
          </div>

          <button type="submit">Sign Up</button>
          <p className="signup-subtext">
            Do you have an account? <Link to="/login">Login</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
