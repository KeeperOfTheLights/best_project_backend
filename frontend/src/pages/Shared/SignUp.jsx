import React, { useState } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import { is_supplier_side } from "../../utils/roleUtils";
import './AuthPossibilities.css'

export default function SignUp() {
  const { t } = useTranslation();
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
    if (pwd.length < 6) return t("auth.passwordTooShort");
    if (!/[A-Z]/.test(pwd)) return t("auth.passwordUppercase");
    if (!/[0-9]/.test(pwd)) return t("auth.passwordNumber");
    if (!/[^A-Za-z0-9]/.test(pwd)) return t("auth.passwordSpecial");
    return "";
  };

  const handlePasswordChange = (e) => setPassword(e.target.value);
  const handleRepeatPasswordChange = (e) => setRepeatPassword(e.target.value);

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (password !== repeatPassword) {
      setErrorMessage(t("auth.passwordsDontMatch"));
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
        login({ role: data.role, token: data.token, refreshToken: data.refresh, id: data.id });

        setTimeout(() => {
          navigate(is_supplier_side(data.role) ? "/SupplierDashboard" : "/ConsumerDashboard");
        }, 50);
      } else {
        setErrorMessage(data.detail || t("auth.registrationFailed"));
      }
    } catch (error) {
      setErrorMessage(t("auth.connectionError"));
    }
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        <h2>{t("auth.createAccount")}</h2>
        <p className="signup-subtext">{t("auth.signUpToContinue")}</p>

        <form className="signup-form" onSubmit={handleSubmit}>
          <input type="text" placeholder={t("auth.fullName")} value={fullName} onChange={(e) => setFullName(e.target.value)} required />
          <input type="text" placeholder={t("auth.username")} value={username} onChange={(e) => setUsername(e.target.value)} required />
          <input type="email" placeholder={t("auth.emailAddress")} value={email} onChange={(e) => setEmail(e.target.value)} required />
          <input type="password" placeholder={t("auth.password")} value={password} onChange={handlePasswordChange} required />
          <input type="password" placeholder={t("auth.confirmPassword")} value={repeatPassword} onChange={handleRepeatPasswordChange} required />

          <div className="role-toggle">
            <button type="button" className={`role-btn ${role === "consumer" ? "active" : ""}`} onClick={() => setRole("consumer")}>
              {t("auth.consumer")}
            </button>
            <button type="button" className={`role-btn ${role === "owner" ? "active" : ""}`} onClick={() => setRole("owner")}>
              {t("auth.owner")}
            </button>
            <button type="button" className={`role-btn ${role === "manager" ? "active" : ""}`} onClick={() => setRole("manager")}>
              {t("auth.manager")}
            </button>
            <button type="button" className={`role-btn ${role === "sales" ? "active" : ""}`} onClick={() => setRole("sales")}>
              {t("auth.sales")}
            </button>
          </div>

          {errorMessage && <p className="form-error">{errorMessage}</p>}

          <button type="submit">{t("common.signup")}</button>
          <p className="signup-subtext">
            {t("auth.haveAccount")} <Link to="/login">{t("common.login")}</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
