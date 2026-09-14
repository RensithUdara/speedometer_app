import 'package:flutter/material.dart';
import 'package:speedometer/meter_painter.dart';

enum SpeedUnit {
  kmh('KM/H', 1),
  mph('MPH', 0.621371);

  const SpeedUnit(this.label, this.factor);

  final String label;
  final double factor;
}

class TripRecord {
  const TripRecord({
    required this.title,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.distanceKm,
    required this.driveSeconds,
    required this.safetyScore,
  });

  final String title;
  final double averageSpeed;
  final double maxSpeed;
  final double distanceKm;
  final int driveSeconds;
  final int safetyScore;
}

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
  int selectedTab = 0;
  SpeedUnit selectedUnit = SpeedUnit.kmh;
  double maxSpeed = 0;
  double totalSpeed = 0;
  double distanceKm = 0;
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

  int get safetyScore {
    if (speedCount == 0) return 100;
    final penalty = (overLimitSamples / speedCount * 55).round();
    return (100 - penalty).clamp(0, 100);
  }

  double displaySpeed(double speed) => speed * selectedUnit.factor;

  double displayDistance(double valueKm) =>
      selectedUnit == SpeedUnit.kmh ? valueKm : valueKm * SpeedUnit.mph.factor;

  String get distanceUnit => selectedUnit == SpeedUnit.kmh ? 'KM' : 'MI';

  String formatDuration(num secondsValue) {
    final totalSeconds = secondsValue.round();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
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

  void _startAccelerating() {
    setState(() {
      isPressing = true;
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
      _lastSampleAt = DateTime.now();
    });
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    controller.animateBack(0, duration: const Duration(seconds: 9));
  }

  void _brake() {
    setState(() {
      isPressing = false;
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
          averageSpeed: averageSpeed,
          maxSpeed: maxSpeed,
          distanceKm: distanceKm,
          driveSeconds: driveSeconds.round(),
          safetyScore: safetyScore,
        ),
      );
    });
    _resetTrip();
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
                    _HomeView(
                      selectedUnit: selectedUnit,
                      currentSpeed: currentSpeed,
                      averageSpeed: averageSpeed,
                      maxSpeed: maxSpeed,
                      distanceKm: distanceKm,
                      driveSeconds: driveSeconds,
                      speedLimit: speedLimit,
                      safetyScore: safetyScore,
                      alertsEnabled: alertsEnabled,
                      isOverLimit: isOverLimit,
                      isPressing: isPressing,
                      distanceUnit: distanceUnit,
                      displaySpeed: displaySpeed,
                      displayDistance: displayDistance,
                      formatDuration: formatDuration,
                      onToggleUnit: _toggleUnit,
                      onResetTrip: _resetTrip,
                      onBrake: _brake,
                      onStartAccelerating: _startAccelerating,
                      onReleaseAccelerator: _releaseAccelerator,
                    ),
                    _TripsView(
                      selectedUnit: selectedUnit,
                      distanceKm: distanceKm,
                      averageSpeed: averageSpeed,
                      maxSpeed: maxSpeed,
                      driveSeconds: driveSeconds,
                      safetyScore: safetyScore,
                      distanceUnit: distanceUnit,
                      displaySpeed: displaySpeed,
                      displayDistance: displayDistance,
                      formatDuration: formatDuration,
                      onSaveTrip: _saveTrip,
                      onResetTrip: _resetTrip,
                    ),
                    _RecordsView(
                      records: savedTrips,
                      selectedUnit: selectedUnit,
                      distanceUnit: distanceUnit,
                      displaySpeed: displaySpeed,
                      displayDistance: displayDistance,
                      formatDuration: formatDuration,
                    ),
                    _SettingsView(
                      selectedUnit: selectedUnit,
                      speedLimit: speedLimit,
                      alertsEnabled: alertsEnabled,
                      ecoMode: ecoMode,
                      displaySpeed: displaySpeed,
                      onUnitChanged: _toggleUnit,
                      onSpeedLimitChanged: (value) {
                        setState(() {
                          speedLimit = value;
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
                    ),
                  ],
                ),
              ),
              _BottomNavigation(
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

class _HomeView extends StatelessWidget {
  const _HomeView({
    required this.selectedUnit,
    required this.currentSpeed,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.distanceKm,
    required this.driveSeconds,
    required this.speedLimit,
    required this.safetyScore,
    required this.alertsEnabled,
    required this.isOverLimit,
    required this.isPressing,
    required this.distanceUnit,
    required this.displaySpeed,
    required this.displayDistance,
    required this.formatDuration,
    required this.onToggleUnit,
    required this.onResetTrip,
    required this.onBrake,
    required this.onStartAccelerating,
    required this.onReleaseAccelerator,
  });

  final SpeedUnit selectedUnit;
  final double currentSpeed;
  final double averageSpeed;
  final double maxSpeed;
  final double distanceKm;
  final double driveSeconds;
  final double speedLimit;
  final int safetyScore;
  final bool alertsEnabled;
  final bool isOverLimit;
  final bool isPressing;
  final String distanceUnit;
  final double Function(double speed) displaySpeed;
  final double Function(double valueKm) displayDistance;
  final String Function(num secondsValue) formatDuration;
  final ValueChanged<SpeedUnit> onToggleUnit;
  final VoidCallback onResetTrip;
  final VoidCallback onBrake;
  final VoidCallback onStartAccelerating;
  final Future<void> Function() onReleaseAccelerator;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  selectedUnit: selectedUnit,
                  onToggleUnit: onToggleUnit,
                  onResetTrip: onResetTrip,
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    height: 390,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: MeterPainter(
                          percentage: displaySpeed(currentSpeed),
                          unitLabel: selectedUnit.label,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                _SafetyBanner(
                  alertsEnabled: alertsEnabled,
                  isOverLimit: isOverLimit,
                  safetyScore: safetyScore,
                  speedLimit:
                      '${displaySpeed(speedLimit).round()} ${selectedUnit.label}',
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _DriveButton(
                        label: 'Brake',
                        icon: Icons.stop_circle_outlined,
                        colors: const [
                          Color(0xFFFF6575),
                          Color(0xFFFF4053),
                        ],
                        onPressed: onBrake,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onLongPress: onStartAccelerating,
                        onLongPressEnd: (_) => onReleaseAccelerator(),
                        child: _DriveButton(
                          label: 'Accelerator',
                          icon: Icons.speed,
                          colors: isPressing
                              ? const [
                                  Color(0xFF8AF7A5),
                                  Color(0xFF23C45E),
                                ]
                              : const [
                                  Color(0xFF35DE73),
                                  Color(0xFF0CB956),
                                ],
                          onPressed: onStartAccelerating,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.05,
                  children: [
                    _StatCard(
                      icon: Icons.speed,
                      iconColor: const Color(0xFFC05BFF),
                      label: 'Average Speed',
                      value:
                          '${displaySpeed(averageSpeed).toStringAsFixed(1)} ${selectedUnit.label}',
                    ),
                    _StatCard(
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFF359DFF),
                      label: 'Max Speed',
                      value:
                          '${displaySpeed(maxSpeed).toStringAsFixed(1)} ${selectedUnit.label}',
                    ),
                    _StatCard(
                      icon: Icons.route,
                      iconColor: const Color(0xFF2DE2CF),
                      label: 'Distance',
                      value:
                          '${displayDistance(distanceKm).toStringAsFixed(2)} $distanceUnit',
                    ),
                    _StatCard(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFFFFA72B),
                      label: 'Trip Time',
                      value: formatDuration(driveSeconds),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TripsView extends StatelessWidget {
  const _TripsView({
    required this.selectedUnit,
    required this.distanceKm,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.driveSeconds,
    required this.safetyScore,
    required this.distanceUnit,
    required this.displaySpeed,
    required this.displayDistance,
    required this.formatDuration,
    required this.onSaveTrip,
    required this.onResetTrip,
  });

  final SpeedUnit selectedUnit;
  final double distanceKm;
  final double averageSpeed;
  final double maxSpeed;
  final double driveSeconds;
  final int safetyScore;
  final String distanceUnit;
  final double Function(double speed) displaySpeed;
  final double Function(double valueKm) displayDistance;
  final String Function(num secondsValue) formatDuration;
  final VoidCallback onSaveTrip;
  final VoidCallback onResetTrip;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Trips',
      subtitle: 'Current drive summary',
      child: Column(
        children: [
          _WideInfoCard(
            icon: Icons.route,
            title: 'Current Trip',
            body:
                '${displayDistance(distanceKm).toStringAsFixed(2)} $distanceUnit  |  ${formatDuration(driveSeconds)}',
            accentColor: const Color(0xFF2DE2CF),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Average',
                  value:
                      '${displaySpeed(averageSpeed).toStringAsFixed(1)} ${selectedUnit.label}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniMetric(
                  label: 'Safety Score',
                  value: '$safetyScore%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DriveButton(
                  label: 'Save Trip',
                  icon: Icons.bookmark_add_outlined,
                  colors: const [Color(0xFF43B3FF), Color(0xFF2F61FF)],
                  onPressed: onSaveTrip,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DriveButton(
                  label: 'Clear',
                  icon: Icons.restart_alt,
                  colors: const [Color(0xFF415879), Color(0xFF24344D)],
                  onPressed: onResetTrip,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _WideInfoCard(
            icon: Icons.stacked_line_chart,
            title: 'Drive Insights',
            body:
                'Top speed ${displaySpeed(maxSpeed).toStringAsFixed(1)} ${selectedUnit.label}. Keep steady acceleration for a better score.',
            accentColor: const Color(0xFFFFA72B),
          ),
        ],
      ),
    );
  }
}

class _RecordsView extends StatelessWidget {
  const _RecordsView({
    required this.records,
    required this.selectedUnit,
    required this.distanceUnit,
    required this.displaySpeed,
    required this.displayDistance,
    required this.formatDuration,
  });

  final List<TripRecord> records;
  final SpeedUnit selectedUnit;
  final String distanceUnit;
  final double Function(double speed) displaySpeed;
  final double Function(double valueKm) displayDistance;
  final String Function(num secondsValue) formatDuration;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Records',
      subtitle: 'Saved driving history',
      child: records.isEmpty
          ? const _EmptyState()
          : Column(
              children: [
                for (final trip in records)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _WideInfoCard(
                      icon: Icons.receipt_long,
                      title: trip.title,
                      body:
                          '${displayDistance(trip.distanceKm).toStringAsFixed(2)} $distanceUnit  |  Max ${displaySpeed(trip.maxSpeed).toStringAsFixed(1)} ${selectedUnit.label}  |  ${formatDuration(trip.driveSeconds)}  |  ${trip.safetyScore}%',
                      accentColor: const Color(0xFF43B3FF),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({
    required this.selectedUnit,
    required this.speedLimit,
    required this.alertsEnabled,
    required this.ecoMode,
    required this.displaySpeed,
    required this.onUnitChanged,
    required this.onSpeedLimitChanged,
    required this.onAlertsChanged,
    required this.onEcoModeChanged,
  });

  final SpeedUnit selectedUnit;
  final double speedLimit;
  final bool alertsEnabled;
  final bool ecoMode;
  final double Function(double speed) displaySpeed;
  final ValueChanged<SpeedUnit> onUnitChanged;
  final ValueChanged<double> onSpeedLimitChanged;
  final ValueChanged<bool> onAlertsChanged;
  final ValueChanged<bool> onEcoModeChanged;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Settings',
      subtitle: 'Driving preferences',
      child: Column(
        children: [
          _GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Units',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _UnitSwitch(
                  selectedUnit: selectedUnit,
                  onChanged: onUnitChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speed Limit: ${displaySpeed(speedLimit).round()} ${selectedUnit.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  min: 30,
                  max: 120,
                  divisions: 18,
                  value: speedLimit,
                  onChanged: onSpeedLimitChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.notifications_active_outlined,
            title: 'Safety Alerts',
            subtitle: 'Warn when speed goes above the limit',
            value: alertsEnabled,
            onChanged: onAlertsChanged,
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.energy_savings_leaf_outlined,
            title: 'Eco Mode',
            subtitle: 'Soft-limits acceleration for smoother driving',
            value: ecoMode,
            onChanged: onEcoModeChanged,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedUnit,
    required this.onToggleUnit,
    required this.onResetTrip,
  });

  final SpeedUnit selectedUnit;
  final ValueChanged<SpeedUnit> onToggleUnit;
  final VoidCallback onResetTrip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Speed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                  children: [
                    TextSpan(
                      text: 'Track',
                      style: TextStyle(color: Color(0xFF43B3FF)),
                    ),
                  ],
                ),
              ),
              Text(
                'Drive Safe, Go Further',
                style: TextStyle(
                  color: Color(0xFFA8BCE1),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 164,
          child: _UnitSwitch(
            selectedUnit: selectedUnit,
            onChanged: onToggleUnit,
          ),
        ),
        const SizedBox(width: 10),
        _RoundIconButton(
          tooltip: 'Reset trip',
          icon: Icons.restart_alt,
          onPressed: onResetTrip,
        ),
      ],
    );
  }
}

class _UnitSwitch extends StatelessWidget {
  const _UnitSwitch({
    required this.selectedUnit,
    required this.onChanged,
  });

  final SpeedUnit selectedUnit;
  final ValueChanged<SpeedUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF071629).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2A5C94)),
      ),
      child: Row(
        children: [
          for (final unit in SpeedUnit.values)
            Expanded(
              child: _UnitOption(
                unit: unit,
                selected: unit == selectedUnit,
                onTap: () => onChanged(unit),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  const _UnitOption({
    required this.unit,
    required this.selected,
    required this.onTap,
  });

  final SpeedUnit unit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF47BAFF), Color(0xFF3159FF)],
                )
              : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          unit.label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF91A4C6),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onPressed,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF254D86), Color(0xFF102846)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF456FA7)),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner({
    required this.alertsEnabled,
    required this.isOverLimit,
    required this.safetyScore,
    required this.speedLimit,
  });

  final bool alertsEnabled;
  final bool isOverLimit;
  final int safetyScore;
  final String speedLimit;

  @override
  Widget build(BuildContext context) {
    final warning = alertsEnabled && isOverLimit;
    final title = warning ? 'Slow Down Safely' : 'You are Driving Safely';
    final subtitle = warning ? 'Limit is $speedLimit' : 'Keep it up!';
    final color = warning ? const Color(0xFFFF4053) : const Color(0xFF35E676);
    final icon = warning ? Icons.warning_amber_rounded : Icons.verified_user;

    return _GlassPanel(
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFA8BCE1),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$safetyScore%',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriveButton extends StatelessWidget {
  const _DriveButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Ink(
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFA8BCE1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.bar_chart_rounded, 'Trips'),
      (Icons.receipt_long_outlined, 'Records'),
      (Icons.settings_outlined, 'Settings'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF020B15).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF173A62)),
        ),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: _BottomNavItem(
                  icon: items[index].$1,
                  label: items[index].$2,
                  selected: index == selectedIndex,
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0E4B8D).withValues(alpha: 0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: selected
              ? Border.all(
                  color: const Color(0xFF1C91FF).withValues(alpha: 0.6))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  selected ? const Color(0xFF43B3FF) : const Color(0xFF93A5C5),
              size: 25,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF43B3FF)
                    : const Color(0xFFA8BCE1),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFA8BCE1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF071B31).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: const Color(0xFF245E9C).withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _WideInfoCard extends StatelessWidget {
  const _WideInfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFFA8BCE1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA8BCE1),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF43B3FF), size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFA8BCE1),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const _GlassPanel(
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: Color(0xFF43B3FF), size: 52),
          SizedBox(height: 12),
          Text(
            'No saved trips yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Save a trip from the Trips tab after driving.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFA8BCE1),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
