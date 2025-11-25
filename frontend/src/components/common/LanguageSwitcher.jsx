import React, { useState, useRef, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import './LanguageSwitcher.css';

export default function LanguageSwitcher() {
  const { i18n } = useTranslation();
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);

  const languages = [
    { code: 'en', name: 'English', flag: '🇬🇧', displayCode: 'ENG' },
    { code: 'ru', name: 'Русский', flag: '🇷🇺', displayCode: 'RU' },
  ];

  const changeLanguage = (lng) => {
    i18n.changeLanguage(lng);
    localStorage.setItem('i18nextLng', lng);
    setIsOpen(false);
  };

  const currentLanguage = languages.find(lang => lang.code === i18n.language) || languages[0];

  // Close menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  return (
    <div className="language-switcher" ref={dropdownRef}>
      <div className="language-switcher-dropdown">
        <button 
          className="language-switcher-button" 
          type="button"
          onClick={() => setIsOpen(!isOpen)}
          onMouseEnter={() => setIsOpen(true)}
        >
          <span className="language-flag">{currentLanguage.flag}</span>
          <span className="language-code">{currentLanguage.displayCode}</span>
          <span className="language-arrow">▾</span>
        </button>
        {isOpen && (
          <div 
            className="language-switcher-menu"
            onMouseEnter={() => setIsOpen(true)}
            onMouseLeave={() => setIsOpen(false)}
          >
            {languages.map((lang) => (
              <button
                key={lang.code}
                className={`language-option ${i18n.language === lang.code ? 'active' : ''}`}
                onClick={() => changeLanguage(lang.code)}
                type="button"
              >
                <span className="language-flag">{lang.flag}</span>
                <span className="language-code-small">{lang.displayCode}</span>
                <span className="language-name">{lang.name}</span>
                {i18n.language === lang.code && <span className="language-check">✓</span>}
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

