import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kff_results/home.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;
  AlignmentGeometry _alignment = Alignment.topLeft;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }

    callme();

    setState(() {
      _alignment = _alignment == Alignment.topLeft
          ? Alignment.bottomRight
          : _alignment = Alignment.topLeft;
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        Get.off(const HomeScreen(), transition: Transition.circularReveal);
      });
    });
  }

  void callme() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String? secid = (androidInfo.model + androidInfo.hardware + androidInfo.id);

    if (GetStorage().read('secid') == null) {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('kffdevice');
      collectionReference.add({
        'model': androidInfo.model,
        'hardware': androidInfo.hardware,
        'exid': androidInfo.id,
        'secid': (androidInfo.model + androidInfo.hardware + androidInfo.id)
      });
      GetStorage().write('secid', secid);
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SizedBox(
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


/*
// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:web_browser/auto.dart';
import 'package:web_browser/web_browser.dart';

import 'ad_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? timer;
  bool? adsView;
  BannerAd? _bannerAd1;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    adsView = GetStorage().read('shoAds');
    print('AdsView: $adsView');
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitIdA,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd1 = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
    _loadRewardedAd();
    Timer(const Duration(seconds: 10), () {
      setState(() {
        if (adsView == true)
          _rewardedAd?.show(
            onUserEarnedReward: (_, reward) {
              //
            },
          );
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _bannerAd1?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          child: Stack(fit: StackFit.loose, children: [
            Browser(
              topBar: const AutoBrowserTopBar(),
              onShare: (context, controller) {
                Share.share('Now get KFF Results https://kolkataff1.in/',
                    subject: 'Download today!');
              },
              initialUriString: 'https://kolkataff1.in/',
              controller: BrowserController(
                userAgent: 'Chrom',
                isZoomEnabled: false,
              ),
              bottomBar: const AutoBrowserBottomBar(),
            ),
            if (adsView == true)
              Positioned(
                left: 30,
                bottom: 62,
                child: SizedBox(
                  child: _showMyAds(),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _showMyAds() {
    return SizedBox(
      child: Column(children: [
        if (_bannerAd1 != null)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: _bannerAd1!.size.width.toDouble(),
              height: _bannerAd1!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd1!),
            ),
          ),
      ]),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }
}

*/