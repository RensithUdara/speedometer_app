import 'package:flutter/material.dart';
import 'package:speedometer/core/speed_formatters.dart';
import 'package:speedometer/core/speed_unit.dart';
import 'package:speedometer/models/trip_record.dart';
import 'package:speedometer/views/home_view.dart';
import 'package:speedometer/views/records_view.dart';
import 'package:speedometer/views/settings_view.dart';
import 'package:speedometer/views/trips_view.dart';
import 'package:speedometer/widgets/bottom_navigation.dart';

class Speedometer extends StatefulWidget {
  const Speedometer({super.key});

  @override
  State<Speedometer> createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  final List<TripRecord> savedTrips = [];

  bool isPressing = false;
  bool alertsEnabled = true;
  bool ecoMode = false;
  bool cruiseMode = false;
  int selectedTab = 0;
  SpeedUnit selectedUnit = SpeedUnit.kmh;
  double maxSpeed = 0;
  double totalSpeed = 0;
  double distanceKm = 0;
  double distanceGoalKm = 1;
  double speedLimit = 80;
  int speedCount = 0;
  double driveSeconds = 0;
  int overLimitSamples = 0;
  DateTime? _lastSampleAt;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    animation = Tween<double>(begin: 0, end: 100).animate(controller)
      ..addListener(_recordSpeedSample);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double get averageSpeed => speedCount > 0 ? totalSpeed / speedCount : 0;

  double get currentSpeed => animation.value;

  bool get isOverLimit => currentSpeed > speedLimit;

  int get overLimitEvents => overLimitSamples;

  double get goalProgress => (distanceKm / distanceGoalKm).clamp(0, 1);

  bool get goalReached => distanceKm >= distanceGoalKm;

  int get safetyScore {
    if (speedCount == 0) return 100;
    final penalty = (overLimitSamples / speedCount * 55).round();
    return (100 - penalty).clamp(0, 100);
  }

  double displaySpeed(double speed) => speed * selectedUnit.factor;

  double displayDistance(double valueKm) =>
      selectedUnit == SpeedUnit.kmh ? valueKm : valueKm * SpeedUnit.mph.factor;

  String get distanceUnit => selectedUnit == SpeedUnit.kmh ? 'KM' : 'MI';

  TripRecord? get bestTrip {
    if (savedTrips.isEmpty) return null;
    return savedTrips.reduce(
      (best, trip) => trip.distanceKm > best.distanceKm ? trip : best,
    );
  }

  void _recordSpeedSample() {
    if (!controller.isAnimating) return;

    final now = DateTime.now();
    final elapsedSeconds = _lastSampleAt == null
        ? 0.0
        : now.difference(_lastSampleAt!).inMilliseconds / 1000;
    final speed = currentSpeed;

    setState(() {
      totalSpeed += speed;
      speedCount++;
      distanceKm += speed * (elapsedSeconds / 3600);
      driveSeconds += elapsedSeconds;
      _lastSampleAt = now;
      if (speed > maxSpeed) maxSpeed = speed;
      if (speed > speedLimit) overLimitSamples++;
    });
  }

  void _toggleCruiseMode() {
    setState(() {
      cruiseMode = !cruiseMode;
      isPressing = cruiseMode;
      _lastSampleAt = DateTime.now();
    });

    if (cruiseMode) {
      controller.animateTo(
        (speedLimit / 100).clamp(0.25, ecoMode ? 0.72 : 0.9),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutCubic,
      );
    } else {
      controller.animateBack(0, duration: const Duration(seconds: 4));
    }
  }

  void _startAccelerating() {
    setState(() {
      isPressing = true;
      cruiseMode = false;
      _lastSampleAt = DateTime.now();
    });
    controller.animateTo(
      ecoMode ? 0.78 : 1,
      duration: const Duration(milliseconds: 2600),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _releaseAccelerator() async {
    setState(() {
      isPressing = false;
      cruiseMode = false;
      _lastSampleAt = DateTime.now();
    });
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    controller.animateBack(0, duration: const Duration(seconds: 9));
  }

  void _brake() {
    setState(() {
      isPressing = false;
      cruiseMode = false;
      _lastSampleAt = DateTime.now();
    });
    controller.animateBack(
      0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
    );
  }

  void _resetTrip() {
    controller.stop();
    controller.value = 0;
    setState(() {
      isPressing = false;
      cruiseMode = false;
      maxSpeed = 0;
      totalSpeed = 0;
      distanceKm = 0;
      speedCount = 0;
      driveSeconds = 0;
      overLimitSamples = 0;
      _lastSampleAt = null;
    });
  }

  void _saveTrip() {
    if (speedCount == 0) return;
    setState(() {
      savedTrips.insert(
        0,
        TripRecord(
          title: 'Trip ${savedTrips.length + 1}',
          createdAt: DateTime.now(),
          averageSpeed: averageSpeed,
          maxSpeed: maxSpeed,
          distanceKm: distanceKm,
          driveSeconds: driveSeconds.round(),
          safetyScore: safetyScore,
          overLimitEvents: overLimitEvents,
        ),
      );
    });
    _resetTrip();
  }

  void _deleteTrip(TripRecord trip) {
    setState(() {
      savedTrips.remove(trip);
    });
  }

  void _clearRecords() {
    setState(savedTrips.clear);
  }

  void _toggleUnit(SpeedUnit unit) {
    setState(() {
      selectedUnit = unit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04101F),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF05111F),
                Color(0xFF082747),
                Color(0xFF03101E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: selectedTab,
                  children: [
                    HomeView(
                      selectedUnit: selectedUnit,
                      currentSpeed: currentSpeed,
                      averageSpeed: averageSpeed,
                      maxSpeed: maxSpeed,
                      distanceKm: distanceKm,
                      driveSeconds: driveSeconds,
                      speedLimit: speedLimit,
                      distanceGoalKm: distanceGoalKm,
                      safetyScore: safetyScore,
                      alertsEnabled: alertsEnabled,
                      isOverLimit: isOverLimit,
                      isPressing: isPressing,
                      cruiseMode: cruiseMode,
                      overLimitEvents: overLimitEvents,
                      goalProgress: goalProgress,
                      distanceUnit: distanceUnit,
                      displaySpeed: displaySpeed,
                      displayDistance: displayDistance,
                      formatDuration: formatDriveDuration,
                      onToggleUnit: _toggleUnit,
                      onResetTrip: _resetTrip,
                      onBrake: _brake,
                      onToggleCruise: _toggleCruiseMode,
                      onStartAccelerating: _startAccelerating,
                      onReleaseAccelerator: _releaseAccelerator,
                    ),
                    TripsView(
                      selectedUnit: selectedUnit,
                      distanceKm: distanceKm,
                      averageSpeed: averageSpeed,
                      maxSpeed: maxSpeed,
                      driveSeconds: driveSeconds,
                      safetyScore: safetyScore,
                      overLimitEvents: overLimitEvents,
                      distanceGoalKm: distanceGoalKm,
                      goalProgress: goalProgress,
                      goalReached: goalReached,
                      distanceUnit: distanceUnit,
                      displaySpeed: displaySpeed,
                      displayDistance: displayDistance,
                      formatDuration: formatDriveDuration,
                      onSaveTrip: _saveTrip,
                      onResetTrip: _resetTrip,
                    ),
                    RecordsView(
                      records: savedTrips,
                      selectedUnit: selectedUnit,
                      distanceUnit: distanceUnit,
                      displaySpeed: displaySpeed,
                      displayDistance: displayDistance,
                      formatDuration: formatDriveDuration,
                      bestTrip: bestTrip,
                      onDeleteTrip: _deleteTrip,
                      onClearRecords: _clearRecords,
                    ),
                    SettingsView(
                      selectedUnit: selectedUnit,
                      speedLimit: speedLimit,
                      distanceGoalKm: distanceGoalKm,
                      alertsEnabled: alertsEnabled,
                      ecoMode: ecoMode,
                      cruiseMode: cruiseMode,
                      displaySpeed: displaySpeed,
                      onUnitChanged: _toggleUnit,
                      onSpeedLimitChanged: (value) {
                        setState(() {
                          speedLimit = value;
                        });
                      },
                      onDistanceGoalChanged: (value) {
                        setState(() {
                          distanceGoalKm = value;
                        });
                      },
                      onAlertsChanged: (value) {
                        setState(() {
                          alertsEnabled = value;
                        });
                      },
                      onEcoModeChanged: (value) {
                        setState(() {
                          ecoMode = value;
                        });
                      },
                      onCruiseModeChanged: (value) {
                        if (value != cruiseMode) _toggleCruiseMode();
                      },
                    ),
                  ],
                ),
              ),
              SpeedTrackBottomNavigation(
                selectedIndex: selectedTab,
                onSelected: (index) {
                  setState(() {
                    selectedTab = index;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
