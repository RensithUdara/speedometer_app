import 'package:flutter/material.dart';
import 'package:speedometer/meter_painter.dart';

enum SpeedUnit {
  kmh('KM/H', 1),
  mph('MPH', 0.621371);

  const SpeedUnit(this.label, this.factor);

  final String label;
  final double factor;
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

  bool isPressing = false;
  SpeedUnit selectedUnit = SpeedUnit.kmh;
  double maxSpeed = 0;
  double totalSpeed = 0;
  double distanceKm = 0;
  double speedLimit = 80;
  int speedCount = 0;
  int driveSeconds = 0;
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

  double displaySpeed(double speed) => speed * selectedUnit.factor;

  double get displayDistance => selectedUnit == SpeedUnit.kmh
      ? distanceKm
      : distanceKm * SpeedUnit.mph.factor;

  String get distanceUnit => selectedUnit == SpeedUnit.kmh ? 'KM' : 'MI';

  String get formattedDriveTime {
    final minutes = driveSeconds ~/ 60;
    final seconds = driveSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
      driveSeconds += elapsedSeconds.round();
      _lastSampleAt = now;
      if (speed > maxSpeed) {
        maxSpeed = speed;
      }
    });
  }

  void _startAccelerating() {
    setState(() {
      isPressing = true;
      _lastSampleAt = DateTime.now();
    });
    controller.forward();
  }

  Future<void> _releaseAccelerator() async {
    setState(() {
      isPressing = false;
      _lastSampleAt = DateTime.now();
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    controller.animateBack(0, duration: const Duration(seconds: 12));
  }

  void _brake() {
    setState(() {
      isPressing = false;
      _lastSampleAt = DateTime.now();
    });
    controller.animateBack(0, duration: const Duration(milliseconds: 900));
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
      _lastSampleAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.blueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: SegmentedButton<SpeedUnit>(
                                  segments: const [
                                    ButtonSegment(
                                      value: SpeedUnit.kmh,
                                      label: Text('KM/H'),
                                    ),
                                    ButtonSegment(
                                      value: SpeedUnit.mph,
                                      label: Text('MPH'),
                                    ),
                                  ],
                                  selected: {selectedUnit},
                                  onSelectionChanged: (value) {
                                    setState(() {
                                      selectedUnit = value.first;
                                    });
                                  },
                                  style: SegmentedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    selectedForegroundColor: Colors.black,
                                    selectedBackgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton.filledTonal(
                                tooltip: 'Reset trip',
                                onPressed: _resetTrip,
                                icon: const Icon(Icons.restart_alt),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 330,
                          width: MediaQuery.sizeOf(context).width,
                          child: AnimatedBuilder(
                            animation: controller,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: MeterPainter(
                                  percentage: animation.value,
                                ),
                              );
                            },
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isOverLimit
                              ? const Padding(
                                  key: ValueKey('speed-warning'),
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Speed Limit Exceeded!',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  key: ValueKey('speed-safe'),
                                  height: 43,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Icon(Icons.traffic, color: Colors.white70),
                              Expanded(
                                child: Slider(
                                  min: 30,
                                  max: 120,
                                  divisions: 18,
                                  value: speedLimit,
                                  label:
                                      '${displaySpeed(speedLimit).round()} ${selectedUnit.label}',
                                  onChanged: (value) {
                                    setState(() {
                                      speedLimit = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 92,
                                child: Text(
                                  '${displaySpeed(speedLimit).round()} ${selectedUnit.label}',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ActionButton(
                              label: 'Brake',
                              icon: Icons.stop_circle_outlined,
                              color: Colors.redAccent,
                              onPressed: _brake,
                            ),
                            const SizedBox(width: 14),
                            GestureDetector(
                              onLongPress: _startAccelerating,
                              onLongPressEnd: (details) =>
                                  _releaseAccelerator(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 55,
                                width: 170,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isPressing
                                      ? Colors.green[200]
                                      : Colors.green,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.speed, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Accelerator',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _StatTile(
                                icon: Icons.av_timer,
                                label: 'Average',
                                value:
                                    '${displaySpeed(averageSpeed).toStringAsFixed(1)} ${selectedUnit.label}',
                              ),
                              _StatTile(
                                icon: Icons.trending_up,
                                label: 'Max',
                                value:
                                    '${displaySpeed(maxSpeed).toStringAsFixed(1)} ${selectedUnit.label}',
                              ),
                              _StatTile(
                                icon: Icons.route,
                                label: 'Distance',
                                value:
                                    '${displayDistance.toStringAsFixed(2)} $distanceUnit',
                              ),
                              _StatTile(
                                icon: Icons.timer_outlined,
                                label: 'Trip Time',
                                value: formattedDriveTime,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
