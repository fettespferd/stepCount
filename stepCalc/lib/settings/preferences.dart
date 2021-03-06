import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class Preferences {
  Preferences._(StreamingSharedPreferences sharedPreferences)
      : assert(sharedPreferences != null),
        themeMode = sharedPreferences.getCustomValue(
          'themeMode',
          defaultValue: ThemeMode.system,
          adapter: _ThemeModeAdapter(),
        );
  static Future<Preferences> create() async =>
      Preferences._(await StreamingSharedPreferences.instance);

  final Preference<ThemeMode> themeMode;
}

extension PreferencesGetIt on GetIt {
  Preferences get preferences => get<Preferences>();
}

class _ThemeModeAdapter extends PreferenceAdapter<ThemeMode> {
  @override
  ThemeMode getValue(SharedPreferences preferences, String key) {
    return {
      'system': ThemeMode.system,
      'light': ThemeMode.light,
      'dark': ThemeMode.dark,
    }[preferences.getString(key)];
  }

  @override
  Future<bool> setValue(
    SharedPreferences preferences,
    String key,
    ThemeMode value,
  ) {
    final string = {
      ThemeMode.system: 'system',
      ThemeMode.light: 'light',
      ThemeMode.dark: 'dark',
    }[value];
    return preferences.setString(key, string);
  }
}

class UserPreferences {
  factory UserPreferences() {
    return _instance;
  }
  UserPreferences._ctor();
  static final UserPreferences _instance = UserPreferences._ctor();

  SharedPreferences _prefs;

  // ignore: avoid_void_async
  void init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get targetSteps {
    return _prefs.getInt('TargetSteps') ?? 8000;
  }

  set targetSteps(int value) {
    _prefs.setInt('TargetSteps', value);
  }

  double get userWeight {
    return _prefs.getDouble('userWeight') ?? 140;
  }

  set userWeight(double value) {
    _prefs.setDouble('userWeight', value);
  }

  int get userHeight {
    return _prefs.getInt('userHeight') ?? 210;
  }

  set userHeight(int value) {
    _prefs.setInt('userHeight', value);
  }

  bool get allowNotification {
    return _prefs.getBool('allowNotification') ?? true;
  }

  set allowNotification(bool value) {
    _prefs.setBool('allowNotification', value);
  }
}
