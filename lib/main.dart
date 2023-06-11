// ignore_for_file: unused_catch_clause

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kff_results/splash.dart';

import 'color_schemes.g.dart';
import 'firebase_options.dart';

bool? shoAds;
final remoteConfig = FirebaseRemoteConfig.instance;
Future<InitializationStatus> _initGoogleMobileAds() {
  return MobileAds.instance.initialize();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize();
  await GetStorage.init();
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));

  await remoteConfig.setDefaults(const {
    "shoAds": false,
  });
  await remoteConfig.fetchAndActivate();
  try {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(hours: 4),
      minimumFetchInterval: Duration.zero,
    ));
    await remoteConfig.fetchAndActivate();
  } on PlatformException catch (exception) {
    //print(exception);
  }
  var shoAds = remoteConfig.getBool("shoAds");
  GetStorage().write('shoAds', shoAds);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
