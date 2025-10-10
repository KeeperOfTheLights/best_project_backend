import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import { useState } from "react";
import reactLogo from "./assets/chert.jpg";
import About from "./pages/About";
import "./App.css";
import MainPage from "./pages/Daivinchik"
import SignUp from "./pages/SignUp";
import Login from "./pages/Login";

function App() {
  const [count, setCount] = useState(0);
  const [isLoggedIn, setIsLoggedIn] = useState(true);

  return (
    <Router>
      <nav className="navbar">
        <div className="navbar-left">
          <img src={reactLogo} alt="Project logo" className="navbar-logo" />
          <Link to="/" className="navbar-title">Daivinvhik</Link>
        </div>


        {!isLoggedIn ? ( 
          <div className="navbar-right">
          <Link to="/about" className="inter-btn">About</Link>
          <Link to="/login" className="nav-btn login-btn">Login</Link>
          <Link to="/signup" className="nav-btn signup-btn">Sign Up</Link>
        </div> ) : (

        <div className="navbar-right">
          <button className="inter-btn">Categories</button>

          <Link to="/about" className="inter-btn">About</Link>

          <button className="inter-btn">Dashboard</button>

          <div className="dropdown">
          <button className="inter-btn dropdown-toggle">Communications ▾</button>
            <div className="dropdown-menu">
              <a href="/notifications">Notifications</a>
              <a href="/chat">Chat</a>
              <a href="/complaints">Complaints</a>
            </div>
          </div>

          <input type="text" placeholder="Search..." className="search-input"/>
          <button className="nav-btn login-btn" onClick={() => setIsLoggedIn(false)}>Sign Out</button>
        </div>
        )}
      </nav>

      <div className="main-content">
        <Routes>
          <Route path="/about" element={<About />} />
          <Route path="/" element={<MainPage />} />
          <Route path="/signup" element={<SignUp />}/>
          <Route path="/login" element={<Login />}/>
        </Routes>
      </div>
    </Router>
  );
}

export default App;
