import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kff_results/home.dart';

import 'ad_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;
  bool? adsView;
  InterstitialAd? _interstitialAd;
  AlignmentGeometry _alignment = Alignment.topLeft;

  @override
  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }
    setState(() {
      _alignment = _alignment == Alignment.topLeft
          ? Alignment.bottomRight
          : _alignment = Alignment.topLeft;
    });
    Timer(const Duration(seconds: 5), () {
      setState(() {
        Get.to(const HomeScreen(),
            //binding: ControllerBinding(),
            transition: Transition.circularReveal);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 60),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: const DecorationImage(
                  image: AssetImage('assets/icon/icon.png'),
                  fit: BoxFit.fitWidth),
            ),
          ),
        ),
      ),
    );
  }
}
