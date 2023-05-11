// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'ad_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? timer;
  bool? adsView;
  bool? runAds;
  BannerAd? _bannerAd1;
  RewardedAd? _rewardedAd;
  late final WebViewController _controller;

  void checkm() {
    var mid = GetStorage().read('secid');
    if (mid == 'RMX3085mt6785SP1A.210812.016' ||
        mid == '21091116Imt6877TP1A.220624.014') {
      setState(() {
        runAds = false;
      });
    } else {
      setState(() {
        runAds = true;
      });
    }
  }

  @override
  void initState() {
    adsView = GetStorage().read('shoAds');
    checkm();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitIdA,
      request: const AdRequest(),
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
    Timer(const Duration(minutes: 2), () {
      setState(() {
        if (adsView == true && runAds == true)
          _rewardedAd?.show(
            onUserEarnedReward: (_, reward) {
              //
            },
          );
      });
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            //
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://kolkataff1.in'));
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
        body: WillPopScope(
          onWillPop: () => _goBack(context),
          child: SizedBox(
            child: Stack(fit: StackFit.loose, children: [
              WebViewWidget(controller: _controller),
              if (adsView == true && runAds == true)
                Positioned(
                  left: 30,
                  bottom: 82,
                  child: SizedBox(
                    child: _showMyAds(),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54, // user must tap button!
        builder: (context) => AlertDialog(
          title: const Text('Do you want to exit'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return Future.value(true);
    }
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
