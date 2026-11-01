import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/ads/ad_service.dart';
import 'package:ielts_simulator/ads/google_ad_service.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/core/clock.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) debugPrint('Unhandled Flutter error: ${details.exception}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error\n$stack');
    return true;
  };
  final ads = GoogleAdService(const SystemClock());
  runApp(
    ProviderScope(
      overrides: [adServiceProvider.overrideWithValue(ads)],
      child: const IeltsApp(),
    ),
  );
  unawaited(ads.start());
}
