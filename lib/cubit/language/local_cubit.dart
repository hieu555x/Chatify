import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(Locale('en')) {
    _loadLocale();
  }

  void setLocale(String langCode) async {
    emit(Locale(langCode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', langCode);
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('lang') ?? 'en';
    emit(Locale(lang));
  }
}
