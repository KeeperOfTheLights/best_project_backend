import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";

export default function SignUp() {
  const [role, setRole] = useState("consumer");
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = (e) => {
    e.preventDefault();
    login({ role, token: "fake-jwt-token" });
    navigate(role === "supplier" ? "/supplier" : "/consumer");
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        <h2>Create an Account</h2>
        <p className="signup-subtext">Join Daivinvhik today 💏</p>

        <form className="signup-form" onSubmit={handleSubmit}>
          <input type="text" placeholder="Full Name" required />
          <input type="email" placeholder="Email Address" required />
          <input type="password" placeholder="Password" required />

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
