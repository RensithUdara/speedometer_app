import 'package:flutter/material.dart';
import 'package:speedometer/core/speed_unit.dart';
import 'package:speedometer/meter_painter.dart';
import 'package:speedometer/widgets/drive_button.dart';
import 'package:speedometer/widgets/speedtrack_cards.dart';
import 'package:speedometer/widgets/speedtrack_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.selectedUnit,
    required this.currentSpeed,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.distanceKm,
    required this.driveSeconds,
    required this.speedLimit,
    required this.distanceGoalKm,
    required this.safetyScore,
    required this.alertsEnabled,
    required this.isOverLimit,
    required this.isPressing,
    required this.cruiseMode,
    required this.overLimitEvents,
    required this.goalProgress,
    required this.distanceUnit,
    required this.displaySpeed,
    required this.displayDistance,
    required this.formatDuration,
    required this.onToggleUnit,
    required this.onResetTrip,
    required this.onBrake,
    required this.onToggleCruise,
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
  final double distanceGoalKm;
  final int safetyScore;
  final bool alertsEnabled;
  final bool isOverLimit;
  final bool isPressing;
  final bool cruiseMode;
  final int overLimitEvents;
  final double goalProgress;
  final String distanceUnit;
  final double Function(double speed) displaySpeed;
  final double Function(double valueKm) displayDistance;
  final String Function(num secondsValue) formatDuration;
  final ValueChanged<SpeedUnit> onToggleUnit;
  final VoidCallback onResetTrip;
  final VoidCallback onBrake;
  final VoidCallback onToggleCruise;
  final VoidCallback onStartAccelerating;
  final Future<void> Function() onReleaseAccelerator;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SpeedTrackHeader(
                  selectedUnit: selectedUnit,
                  onToggleUnit: onToggleUnit,
                  onResetTrip: onResetTrip,
                ),
                const SizedBox(height: 6),
                Center(
                  child: SizedBox(
                    height: 340,
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
                SafetyBanner(
                  alertsEnabled: alertsEnabled,
                  isOverLimit: isOverLimit,
                  safetyScore: safetyScore,
                  speedLimit:
                      '${displaySpeed(speedLimit).round()} ${selectedUnit.label}',
                ),
                const SizedBox(height: 10),
                GoalProgressCard(
                  progress: goalProgress,
                  current:
                      '${displayDistance(distanceKm).toStringAsFixed(2)} $distanceUnit',
                  target:
                      '${displayDistance(distanceGoalKm).toStringAsFixed(1)} $distanceUnit',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DriveButton(
                        label: 'Brake',
                        icon: Icons.stop_circle_outlined,
                        colors: const [
                          Color(0xFFFF6575),
                          Color(0xFFFF4053),
                        ],
                        onPressed: onBrake,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onLongPress: onStartAccelerating,
                        onLongPressEnd: (_) => onReleaseAccelerator(),
                        child: DriveButton(
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
                const SizedBox(height: 12),
                DriveButton(
                  label: cruiseMode ? 'Cruise On' : 'Cruise Control',
                  icon: cruiseMode
                      ? Icons.pause_circle_outline
                      : Icons.assistant_direction_outlined,
                  colors: cruiseMode
                      ? const [Color(0xFF43B3FF), Color(0xFF3159FF)]
                      : const [Color(0xFF304966), Color(0xFF142940)],
                  onPressed: onToggleCruise,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.35,
                  children: [
                    StatCard(
                      icon: Icons.speed,
                      iconColor: const Color(0xFFC05BFF),
                      label: 'Average Speed',
                      value:
                          '${displaySpeed(averageSpeed).toStringAsFixed(1)} ${selectedUnit.label}',
                    ),
                    StatCard(
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFF359DFF),
                      label: 'Max Speed',
                      value:
                          '${displaySpeed(maxSpeed).toStringAsFixed(1)} ${selectedUnit.label}',
                    ),
                    StatCard(
                      icon: Icons.route,
                      iconColor: const Color(0xFF2DE2CF),
                      label: 'Distance',
                      value:
                          '${displayDistance(distanceKm).toStringAsFixed(2)} $distanceUnit',
                    ),
                    StatCard(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFFFFA72B),
                      label: 'Trip Time',
                      value: formatDuration(driveSeconds),
                    ),
                    StatCard(
                      icon: Icons.verified_user_outlined,
                      iconColor: const Color(0xFF35E676),
                      label: 'Safety Score',
                      value: '$safetyScore%',
                    ),
                    StatCard(
                      icon: Icons.warning_amber_rounded,
                      iconColor: const Color(0xFFFF6575),
                      label: 'Over Limit',
                      value: '$overLimitEvents times',
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
