import { useAuth } from "../context/Auth-Context";
import { useNavigate } from "react-router-dom";

export function useApi() {
  const { token, logout, refreshAccessToken } = useAuth();
  const navigate = useNavigate();

  const fetchWithAuth = async (url, options = {}) => {
    const headers = options.headers || {};
    let currentToken = token || localStorage.getItem("token");
    
    if (currentToken) {
      headers["Authorization"] = `Bearer ${currentToken}`;
    }

    try {
      let res = await fetch(url, { ...options, headers });
      
      if (res.status === 401 && refreshAccessToken) {
        const newToken = await refreshAccessToken();
        if (newToken) {
          headers["Authorization"] = `Bearer ${newToken}`;
          res = await fetch(url, { ...options, headers });
        } else {
          logout();
          navigate("/login");
          return null;
        }
      } else if (res.status === 401) {
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
