import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:namikibun/services/ad_service.dart';
import 'package:namikibun/services/feature_gate.dart';

class AdBanner extends ConsumerStatefulWidget {
  const AdBanner({super.key});

  @override
  ConsumerState<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends ConsumerState<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(featureGateProvider, (prev, next) {
      if (next.isAdFree && _bannerAd != null) {
        _disposeAd();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null && !_disposed) {
      _loadAd();
    }
  }

  void _loadAd() {
    final adService = AdService();
    final adUnitId = adService.bannerAdUnitId;
    if (adUnitId.isEmpty) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _disposed = true;
    if (mounted) setState(() => _isLoaded = false);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gate = ref.watch(featureGateProvider);

    if (gate.isAdFree || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
