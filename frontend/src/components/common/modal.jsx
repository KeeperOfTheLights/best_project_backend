import React from "react";
import { useTranslation } from "react-i18next";
import "./modal.css";

export default function Modal({ show, title, text, onConfirm, onCancel, children }) {
  const { t } = useTranslation();
  if (!show) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-box">
        <div className="modal-header">
          <h2 className="modal-title">{title}</h2>
          <button className="modal-close-btn" onClick={onCancel}>
            x
          </button>
        </div>

        {text && <p className="modal-message">{text}</p>}

        {children}

        {onConfirm && (
          <div className="modal-buttons">
            <button className="modal-btn cancel" onClick={onCancel}>
              {t("common.cancel")}
            </button>
            <button className="modal-btn confirm" onClick={onConfirm}>
              {t("common.confirm")}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}