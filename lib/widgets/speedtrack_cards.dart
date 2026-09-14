import 'package:flutter/material.dart';
import 'package:speedometer/core/speed_unit.dart';
import 'package:speedometer/models/trip_record.dart';
import 'package:speedometer/widgets/glass_panel.dart';

class SafetyBanner extends StatelessWidget {
  const SafetyBanner({
    super.key,
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

    return GlassPanel(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: color, size: 29),
          ),
          const SizedBox(width: 13),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
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
          Text(
            '$safetyScore%',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    super.key,
    required this.progress,
    required this.current,
    required this.target,
  });

  final double progress;
  final String current;
  final String target;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined,
                  color: Color(0xFF43B3FF), size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Distance Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Color(0xFF43B3FF),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              backgroundColor: const Color(0xFF173A62),
              color: const Color(0xFF35E676),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$current of $target',
            style: const TextStyle(
              color: Color(0xFFA8BCE1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
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
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 10),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

class WideInfoCard extends StatelessWidget {
  const WideInfoCard({
    super.key,
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
    return GlassPanel(
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFFA8BCE1),
                    fontSize: 12,
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

class MiniMetric extends StatelessWidget {
  const MiniMetric({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA8BCE1),
              fontSize: 12,
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
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
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
    return GlassPanel(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF43B3FF), size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFA8BCE1),
                    fontSize: 11,
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

class RecordCard extends StatelessWidget {
  const RecordCard({
    super.key,
    required this.trip,
    required this.selectedUnit,
    required this.distanceUnit,
    required this.displaySpeed,
    required this.displayDistance,
    required this.formatDuration,
    required this.onDelete,
  });

  final TripRecord trip;
  final SpeedUnit selectedUnit;
  final String distanceUnit;
  final double Function(double speed) displaySpeed;
  final double Function(double valueKm) displayDistance;
  final String Function(num secondsValue) formatDuration;
  final VoidCallback onDelete;

  String get dateLabel {
    final month = trip.createdAt.month.toString().padLeft(2, '0');
    final day = trip.createdAt.day.toString().padLeft(2, '0');
    return '${trip.createdAt.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Color(0xFF43B3FF), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.title}  |  $dateLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${displayDistance(trip.distanceKm).toStringAsFixed(2)} $distanceUnit  |  Avg ${displaySpeed(trip.averageSpeed).toStringAsFixed(1)} ${selectedUnit.label}  |  Max ${displaySpeed(trip.maxSpeed).toStringAsFixed(1)} ${selectedUnit.label}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFA8BCE1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatDuration(trip.driveSeconds)}  |  Safety ${trip.safetyScore}%  |  Over limit ${trip.overLimitEvents}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7F94B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete record',
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFFF6575),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassPanel(
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: Color(0xFF43B3FF), size: 42),
          SizedBox(height: 10),
          Text(
            'No saved trips yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Save a trip from the Trips tab after driving.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFA8BCE1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
