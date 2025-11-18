import { useAuth } from "../context/Auth-Context";
import { useNavigate } from "react-router-dom";

export function useApi() {
  const { token, logout } = useAuth();
  const navigate = useNavigate();

  const fetchWithAuth = async (url, options = {}) => {
    const headers = options.headers || {};
    if (token) headers["Authorization"] = `Bearer ${token}`;

    try {
      const res = await fetch(url, { ...options, headers });
      if (res.status === 401) {
        logout();
        navigate("/login");
        return null;
      }
      return res;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  return { fetchWithAuth };
}
