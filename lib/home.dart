// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:flutter/material.dart';
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
  BannerAd? _bannerAd1;
  RewardedAd? _rewardedAd;
  late final WebViewController _controller;

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
    Timer(const Duration(minutes: 2), () {
      setState(() {
        if (adsView == true)
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
        body: SizedBox(
          child: Stack(fit: StackFit.loose, children: [
            WebViewWidget(controller: _controller),
            /* Browser(
              topBar: const AutoBrowserTopBar(),
              initialUriString: 'https://kolkataff1.in/',
              controller: BrowserController(
                userAgent: 'Chrom',
                isZoomEnabled: false,
              ),
              bottomBar: const AutoBrowserBottomBar(),
            ), */
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(onPressed: () {}),
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
