import React, { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import "./CompanyManagement.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function CompanyManagement() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { token, logout, role, loading: authLoading } = useAuth();
  const [unassignedUsers, setUnassignedUsers] = useState([]);
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [actionLoading, setActionLoading] = useState(null);

  useEffect(() => {
    if (authLoading) return;
    if (role !== "owner") {
      navigate("/SupplierDashboard");
      return;
    }
    fetchData();
  }, [token, role, navigate, authLoading]);

  const fetchData = async () => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const [unassignedRes, employeesRes] = await Promise.all([
        fetch(`${API_BASE}/company/unassigned/`, {
          headers: { Authorization: `Bearer ${token}` },
        }),
        fetch(`${API_BASE}/company/employees/`, {
          headers: { Authorization: `Bearer ${token}` },
        }),
      ]);

      if (unassignedRes.status === 401 || employeesRes.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!unassignedRes.ok) {
        const text = await unassignedRes.text();
        throw new Error(text || t("company.failedToLoadUnassigned"));
      }

      if (!employeesRes.ok) {
        const text = await employeesRes.text();
        throw new Error(text || t("company.failedToLoadEmployees"));
      }

      const unassignedData = await unassignedRes.json();
      const employeesData = await employeesRes.json();

      setUnassignedUsers(Array.isArray(unassignedData) ? unassignedData : []);
      setEmployees(Array.isArray(employeesData) ? employeesData : []);
    } catch (err) {
      setError(err.message || t("company.failedToLoad"));
    } finally {
      setLoading(false);
    }
  };

  const handleAssign = async (userId) => {
    if (authLoading) return;
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    setActionLoading(userId);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/company/assign/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ user_id: userId }),
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || t("company.failedToAssign"));
      }

      await fetchData();
    } catch (err) {
      setError(err.message || t("company.failedToAssign"));
    } finally {
      setActionLoading(null);
    }
  };

  const handleRemove = async (userId) => {
    if (authLoading) return;
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    if (!window.confirm(t("company.confirmRemoveEmployee"))) {
      return;
    }

    setActionLoading(userId);
    setError("");

    try {
      const res = await fetch(`${API_BASE}/company/remove/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ user_id: userId }),
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || t("company.failedToRemove"));
      }

      await fetchData();
    } catch (err) {
      setError(err.message || t("company.failedToRemove"));
    } finally {
      setActionLoading(null);
    }
  };

  const getRoleLabel = (role) => {
    const roleMap = {
      manager: t("auth.manager"),
      sales: t("auth.sales"),
      owner: t("auth.owner"),
    };
    return roleMap[role] || role;
  };

  if (loading) {
    return (
      <div className="company-management-container">
        <p>{t("common.loading")}</p>
      </div>
    );
  }

  return (
    <div className="company-management-container">
      <div className="company-header">
        <h2>{t("company.companyManagement")}</h2>
        <button className="refresh-button" onClick={fetchData} disabled={loading}>
          {loading ? t("common.processing") : t("common.refresh")}
        </button>
      </div>

      {error && (
        <div className="error-banner">
          {error}
          <button onClick={() => setError("")} style={{ marginLeft: "1rem" }}>
            ✕
          </button>
        </div>
      )}

      <div className="company-sections">
        <div className="section-card">
          <h3>{t("company.companyEmployees")} ({employees.length})</h3>
          {employees.length === 0 ? (
            <div className="empty-state">
              <p>{t("company.noEmployeesAssigned")}</p>
            </div>
          ) : (
            <div className="users-list">
              {employees.map((employee) => (
                <div key={employee.id} className="user-card">
                  <div className="user-info">
                    <h4>{employee.full_name}</h4>
                    <p className="user-email">{employee.email}</p>
                    <span className="role-badge">{getRoleLabel(employee.role)}</span>
                  </div>
                  <button
                    className="action-btn remove-btn"
                    onClick={() => handleRemove(employee.id)}
                    disabled={actionLoading === employee.id}
                  >
                    {actionLoading === employee.id ? t("common.processing") : t("company.removeEmployee")}
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="section-card">
          <h3>{t("company.unassignedUsers")} ({unassignedUsers.length})</h3>
          <p className="section-description">
            {t("company.unassignedDescription")}
          </p>
          {unassignedUsers.length === 0 ? (
            <div className="empty-state">
              <p>{t("company.noUnassignedUsers")}</p>
            </div>
          ) : (
            <div className="users-list">
              {unassignedUsers.map((user) => (
                <div key={user.id} className="user-card">
                  <div className="user-info">
                    <h4>{user.full_name}</h4>
                    <p className="user-email">{user.email}</p>
                    <span className="role-badge">{getRoleLabel(user.role)}</span>
                  </div>
                  <button
                    className="action-btn assign-btn"
                    onClick={() => handleAssign(user.id)}
                    disabled={actionLoading === user.id}
                  >
                    {actionLoading === user.id ? t("common.processing") : t("company.assignEmployee")}
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

