import "./About.css";
import React from 'react';
import { useTranslation } from "react-i18next";

export default function About() {
  const { t } = useTranslation();
  return (
    <div className="about-bg">
      <div className="about-container">
        <h2>{t("about.title")}</h2>
        <p>
          {t("about.description1")}
        </p>
        <p>
          {t("about.description2")}
        </p>
      </div>
    </div>
  );
}
