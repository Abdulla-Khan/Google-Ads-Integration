import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const int maxAttempts = 3;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BannerAd staticAd;
  bool staticAdLoaded = false;
  late BannerAd inlineAd;
  bool inlineAdLoaded = false;

  InterstitialAd? interstitialAd;
  int interstitialAttempts = 0;

  RewardedAd? rewardedAd;
  int rewardedAdAttempts = 0;

  static const AdRequest request = AdRequest();

  void loadStaticBannerAd() {
    staticAd = BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
        request: request,
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            staticAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }));

    staticAd.load();
  }

  ///function to load inline banner ad
  void loadInlineBannerAd() {
    inlineAd = BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
        request: request,
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            inlineAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }));

    inlineAd.load();
  }

  void createInterstialAd() {
    InterstitialAd.load(
        adUnitId: InterstitialAd.testAdUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          interstitialAd = ad;
          interstitialAttempts = 0;
        }, onAdFailedToLoad: (error) {
          interstitialAttempts++;
          interstitialAd = null;

          if (interstitialAttempts <= maxAttempts) {
            createInterstialAd();
          }
        }));
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      return;
    }

    interstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
      ad.dispose();
      createInterstialAd();
    }, onAdFailedToShowFullScreenContent: (ad, error) {
      ad.dispose();

      createInterstialAd();
    });

    interstitialAd!.show();
    interstitialAd = null;
  }

  @override
  void initState() {
    loadStaticBannerAd();
    loadInlineBannerAd();
    createInterstialAd();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    staticAd.dispose();
    inlineAd.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Ads'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (staticAdLoaded)
                  Container(
                    child: AdWidget(
                      ad: staticAd,
                    ),
                    width: staticAd.size.width.toDouble(),
                    height: staticAd.size.height.toDouble(),
                    alignment: Alignment.bottomCenter,
                  ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          showInterstitialAd();
                        },
                        child: const Text('Show Interstitial Ad')),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        if (inlineAdLoaded && index == 5) {
                          return Column(
                            children: [
                              SizedBox(
                                child: AdWidget(
                                  ad: inlineAd,
                                ),
                                width: inlineAd.size.width.toDouble(),
                                height: inlineAd.size.height.toDouble(),
                              ),
                              ListTile(
                                title: Text('Item ${index + 1}'),
                                leading: const Icon(Icons.star),
                              )
                            ],
                          );
                        } else {
                          return ListTile(
                            title: Text('Item ${index + 1}'),
                            leading: const Icon(Icons.star),
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
