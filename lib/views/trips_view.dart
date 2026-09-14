import 'package:flutter/material.dart';
import 'package:speedometer/core/speed_unit.dart';
import 'package:speedometer/widgets/drive_button.dart';
import 'package:speedometer/widgets/speedtrack_cards.dart';
import 'package:speedometer/views/tab_scaffold.dart';

class TripsView extends StatelessWidget {
  const TripsView({
    super.key,
    required this.selectedUnit,
    required this.distanceKm,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.driveSeconds,
    required this.safetyScore,
    required this.overLimitEvents,
    required this.distanceGoalKm,
    required this.goalProgress,
    required this.goalReached,
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
  final int overLimitEvents;
  final double distanceGoalKm;
  final double goalProgress;
  final bool goalReached;
  final String distanceUnit;
  final double Function(double speed) displaySpeed;
  final double Function(double valueKm) displayDistance;
  final String Function(num secondsValue) formatDuration;
  final VoidCallback onSaveTrip;
  final VoidCallback onResetTrip;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      title: 'Trips',
      subtitle: 'Current drive summary',
      child: Column(
        children: [
          WideInfoCard(
            icon: Icons.route,
            title: 'Current Trip',
            body:
                '${displayDistance(distanceKm).toStringAsFixed(2)} $distanceUnit  |  ${formatDuration(driveSeconds)}',
            accentColor: const Color(0xFF2DE2CF),
          ),
          const SizedBox(height: 12),
          GoalProgressCard(
            progress: goalProgress,
            current:
                '${displayDistance(distanceKm).toStringAsFixed(2)} $distanceUnit',
            target:
                '${displayDistance(distanceGoalKm).toStringAsFixed(1)} $distanceUnit',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MiniMetric(
                  label: 'Average',
                  value:
                      '${displaySpeed(averageSpeed).toStringAsFixed(1)} ${selectedUnit.label}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    MiniMetric(label: 'Safety Score', value: '$safetyScore%'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DriveButton(
                  label: 'Save Trip',
                  icon: Icons.bookmark_add_outlined,
                  colors: const [Color(0xFF43B3FF), Color(0xFF2F61FF)],
                  onPressed: onSaveTrip,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DriveButton(
                  label: 'Clear',
                  icon: Icons.restart_alt,
                  colors: const [Color(0xFF415879), Color(0xFF24344D)],
                  onPressed: onResetTrip,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WideInfoCard(
            icon: goalReached
                ? Icons.flag_circle_outlined
                : Icons.stacked_line_chart,
            title: goalReached ? 'Goal Completed' : 'Drive Insights',
            body:
                'Top speed ${displaySpeed(maxSpeed).toStringAsFixed(1)} ${selectedUnit.label}. Over limit events: $overLimitEvents.',
            accentColor: const Color(0xFFFFA72B),
          ),
        ],
      ),
    );
  }
}
