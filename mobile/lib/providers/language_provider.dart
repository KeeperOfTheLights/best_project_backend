import 'package:flutter/material.dart';

/// Manages the current app language (English / Russian).
class LanguageProvider extends ChangeNotifier {
  String _languageCode = 'en'; // 'en' or 'ru'

  String get languageCode => _languageCode;

  Locale get locale => Locale(_languageCode);

  bool get isEnglish => _languageCode == 'en';

  void setLanguage(String code) {
    if (code == _languageCode) return;
    _languageCode = code;
    notifyListeners();
  }

  void toggleLanguage() {
    _languageCode = _languageCode == 'en' ? 'ru' : 'en';
    notifyListeners();
  }
}


