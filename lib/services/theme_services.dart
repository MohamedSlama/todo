import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices {
  //TODO theme services
  final GetStorage _box = GetStorage();
  final _key = 'isDarkMode';

  //? Loading the theme from storage
  bool _loadThemeFromBox() => _box.read<bool>(_key) ?? false;

  //? Save the theme to storage
  _saveThemeFromBox(_isDarkMode) => _box.write(_key, _isDarkMode);

  //? return app theme
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  /*
  ? Do changes to:
    + changes current the State of theme
    + changes theme in storage
   */
  void changeThemeMode() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeFromBox(!_loadThemeFromBox());
  }
}
