import 'package:flutter/material.dart';
import 'package:inmax/generated/l10n.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) return; 
    _locale = locale;
    notifyListeners();
  }
}
