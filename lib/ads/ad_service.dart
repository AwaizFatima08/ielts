import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ads shown outside the exam: a banner on browsing screens and one
/// interstitial after a finished test report. Never used during a test.
abstract interface class AdService {
  /// Asks for consent where required, then starts the ad SDK.
  Future<void> start();

  /// A banner for the bottom of a browsing screen; empty when no ad is ready.
  Widget banner();

  /// Shows the full-screen ad after a report, if the frequency cap allows.
  Future<void> showReportInterstitial();
}

/// Used in tests and whenever ads are not wired in.
class NoAdService implements AdService {
  const NoAdService();

  @override
  Future<void> start() async {}

  @override
  Widget banner() => const SizedBox.shrink();

  @override
  Future<void> showReportInterstitial() async {}
}

final Provider<AdService> adServiceProvider = Provider<AdService>((ref) => const NoAdService());
