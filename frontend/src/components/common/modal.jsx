import React from "react";
import "./modal.css";

export default function Modal({ show, title, text, onConfirm, onCancel, children }) {
  if (!show) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-box">
        <div className="modal-header">
          <h2 className="modal-title">{title}</h2>
          <button className="modal-close-btn" onClick={onCancel}>
            ×
          </button>
        </div>

        {text && <p className="modal-message">{text}</p>}

        {/* Children renders directly, not inside modal-content */}
        {children}

        <div className="modal-buttons">
          <button className="modal-btn cancel" onClick={onCancel}>
            {onConfirm ? "Cancel" : "Close"}
          </button>
          {onConfirm && (
            <button className="modal-btn confirm" onClick={onConfirm}>
              Confirm
            </button>
          )}
        </div>
      </div>
    </div>
  );
}