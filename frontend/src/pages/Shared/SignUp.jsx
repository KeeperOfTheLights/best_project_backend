import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import './AuthPossibilities.css'

export default function SignUp() {
  const [role, setRole] = useState("consumer");
  const [fullName, setFullName] = useState("");
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [repeatPassword, setRepeatPassword] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const { login } = useAuth();
  const navigate = useNavigate();

  const checkPasswordStrength = (pwd) => {
    if (pwd.length < 6) return "Password is too short";
    if (!/[A-Z]/.test(pwd)) return "Add at least one uppercase letter";
    if (!/[0-9]/.test(pwd)) return "Add at least one number";
    if (!/[^A-Za-z0-9]/.test(pwd)) return "Add at least one special character";
    return "";
  };

  const handlePasswordChange = (e) => setPassword(e.target.value);
  const handleRepeatPasswordChange = (e) => setRepeatPassword(e.target.value);

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (password !== repeatPassword) {
      setErrorMessage("Passwords do not match!");
      return;
    }

    const pwdError = checkPasswordStrength(password);
    if (pwdError) {
      setErrorMessage(pwdError);
      return;
    }

    setErrorMessage("");

    const formData = { full_name: fullName, username, email, password, role, password2: repeatPassword };

    try {
      const response = await fetch("http://127.0.0.1:8000/api/accounts/register/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      const data = await response.json();

      if (response.ok) {
        login({ role: data.role, token: data.token });

        setTimeout(() => {
          navigate(data.role === "supplier" ? "/supplier" : "/consumer");
        }, 50);
      } else {
        setErrorMessage(data.detail || "Registration failed");
      }
    } catch (error) {
      setErrorMessage("Could not connect to server");
    }
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        <h2>Create an Account</h2>
        <p className="signup-subtext">Join Daivinvhik today</p>

        <form className="signup-form" onSubmit={handleSubmit}>
          <input type="text" placeholder="Full Name" value={fullName} onChange={(e) => setFullName(e.target.value)} required />
          <input type="text" placeholder="Username" value={username} onChange={(e) => setUsername(e.target.value)} required />
          <input type="email" placeholder="Email Address" value={email} onChange={(e) => setEmail(e.target.value)} required />
          <input type="password" placeholder="Password" value={password} onChange={handlePasswordChange} required />
          <input type="password" placeholder="Repeat Password" value={repeatPassword} onChange={handleRepeatPasswordChange} required />

          <div className="role-toggle">
            <button type="button" className={`role-btn ${role === "consumer" ? "active" : ""}`} onClick={() => setRole("consumer")}>
              Consumer
            </button>
            <button type="button" className={`role-btn ${role === "supplier" ? "active" : ""}`} onClick={() => setRole("supplier")}>
              Supplier
            </button>
          </div>

          {errorMessage && <p className="form-error">{errorMessage}</p>}

          <button type="submit">Sign Up</button>
          <p className="signup-subtext">
            Do you have an account? <Link to="/login">Login</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
