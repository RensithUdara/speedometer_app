import 'package:flutter/material.dart';
import 'package:speedometer/core/speed_unit.dart';
import 'package:speedometer/models/trip_record.dart';
import 'package:speedometer/widgets/drive_button.dart';
import 'package:speedometer/widgets/speedtrack_cards.dart';
import 'package:speedometer/views/tab_scaffold.dart';

class RecordsView extends StatelessWidget {
  const RecordsView({
    super.key,
    required this.records,
    required this.selectedUnit,
    required this.distanceUnit,
    required this.displaySpeed,
    required this.displayDistance,
    required this.formatDuration,
    required this.bestTrip,
    required this.onDeleteTrip,
    required this.onClearRecords,
  });

  final List<TripRecord> records;
  final SpeedUnit selectedUnit;
  final String distanceUnit;
  final double Function(double speed) displaySpeed;
  final double Function(double valueKm) displayDistance;
  final String Function(num secondsValue) formatDuration;
  final TripRecord? bestTrip;
  final ValueChanged<TripRecord> onDeleteTrip;
  final VoidCallback onClearRecords;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      title: 'Records',
      subtitle: 'Saved driving history',
      child: records.isEmpty
          ? const EmptyState()
          : Column(
              children: [
                if (bestTrip != null) ...[
                  WideInfoCard(
                    icon: Icons.emoji_events_outlined,
                    title: 'Best Distance',
                    body:
                        '${displayDistance(bestTrip!.distanceKm).toStringAsFixed(2)} $distanceUnit on ${bestTrip!.title}',
                    accentColor: const Color(0xFFFFD35A),
                  ),
                  const SizedBox(height: 12),
                ],
                for (final trip in records)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecordCard(
                      trip: trip,
                      selectedUnit: selectedUnit,
                      distanceUnit: distanceUnit,
                      displaySpeed: displaySpeed,
                      displayDistance: displayDistance,
                      formatDuration: formatDuration,
                      onDelete: () => onDeleteTrip(trip),
                    ),
                  ),
                DriveButton(
                  label: 'Clear Records',
                  icon: Icons.delete_sweep_outlined,
                  colors: const [Color(0xFFFF6575), Color(0xFFB72E45)],
                  onPressed: onClearRecords,
                ),
              ],
            ),
    );
  }
}
