import 'dart:async';
import 'package:flutter/material.dart';

/// Usage:
/// class _MyScreenState extends State<MyScreen> with WidgetsBindingObserver, DayRefreshMixin { ... }
mixin DayRefreshMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  late DateTime _lastKnownDate;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _lastKnownDate = DateTime.now();
    // 'this' is now valid because we constrained this mixin to be 'on WidgetsBindingObserver'
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }

  /// Override this method to define what happens when the day changes.
  void onDayChanged();

  void _scheduleMidnightUpdate() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now) + const Duration(seconds: 1);

    _midnightTimer = Timer(durationUntilMidnight, () {
      _checkAndNotify();
      _scheduleMidnightUpdate();
    });
  }

  void _checkAndNotify() {
    if (!mounted) return;

    final now = DateTime.now();
    if (!_isSameDay(now, _lastKnownDate)) {
      _lastKnownDate = now;
      onDayChanged();
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // We can safely call super because we are 'on WidgetsBindingObserver'
    // though typically WidgetsBindingObserver methods are empty.
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _checkAndNotify();
      _scheduleMidnightUpdate();
    }
  }
}
