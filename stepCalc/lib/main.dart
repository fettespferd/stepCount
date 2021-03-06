import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stepCalc/app/module.dart';
import 'package:stepCalc/auth/module.dart';
import 'package:stepCalc/settings/module.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

//Initalize Notification
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  _showLoadingPage();
  await initApp();
  initAuth();
  await initSettings();
  await services.allReady();

  final isSignedIn = services.auth.isSignedIn;

  await _initFlutterLocalNotification();

  UserPreferences().init();
  runApp(StepCalcApp(isSignedInInitially: isSignedIn));
}

void _showLoadingPage() {
  runApp(Container(
    color: Colors.white,
    alignment: Alignment.center,
    child: CircularProgressIndicator(),
  ));
}

Future<void> _initFlutterLocalNotification() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Berlin'));

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  // final IOSInitializationSettings initializationSettingsIOS =
  //     IOSInitializationSettings(
  //         onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final initializationSettingsMacOS = MacOSInitializationSettings();
  final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
