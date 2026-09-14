import 'package:flutter/material.dart';
import 'package:speedometer/core/speed_unit.dart';
import 'package:speedometer/widgets/glass_panel.dart';
import 'package:speedometer/widgets/speedtrack_cards.dart';
import 'package:speedometer/widgets/unit_switch.dart';
import 'package:speedometer/views/tab_scaffold.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.selectedUnit,
    required this.speedLimit,
    required this.distanceGoalKm,
    required this.alertsEnabled,
    required this.ecoMode,
    required this.cruiseMode,
    required this.displaySpeed,
    required this.onUnitChanged,
    required this.onSpeedLimitChanged,
    required this.onDistanceGoalChanged,
    required this.onAlertsChanged,
    required this.onEcoModeChanged,
    required this.onCruiseModeChanged,
  });

  final SpeedUnit selectedUnit;
  final double speedLimit;
  final double distanceGoalKm;
  final bool alertsEnabled;
  final bool ecoMode;
  final bool cruiseMode;
  final double Function(double speed) displaySpeed;
  final ValueChanged<SpeedUnit> onUnitChanged;
  final ValueChanged<double> onSpeedLimitChanged;
  final ValueChanged<double> onDistanceGoalChanged;
  final ValueChanged<bool> onAlertsChanged;
  final ValueChanged<bool> onEcoModeChanged;
  final ValueChanged<bool> onCruiseModeChanged;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      title: 'Settings',
      subtitle: 'Driving preferences',
      child: Column(
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Units',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                UnitSwitch(
                    selectedUnit: selectedUnit, onChanged: onUnitChanged),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speed Limit: ${displaySpeed(speedLimit).round()} ${selectedUnit.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distance Goal: ${distanceGoalKm.toStringAsFixed(1)} KM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  min: 0.5,
                  max: 10,
                  divisions: 19,
                  value: distanceGoalKm,
                  onChanged: onDistanceGoalChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SettingsTile(
            icon: Icons.notifications_active_outlined,
            title: 'Safety Alerts',
            subtitle: 'Warn when speed goes above the limit',
            value: alertsEnabled,
            onChanged: onAlertsChanged,
          ),
          const SizedBox(height: 12),
          SettingsTile(
            icon: Icons.energy_savings_leaf_outlined,
            title: 'Eco Mode',
            subtitle: 'Soft-limits acceleration for smoother driving',
            value: ecoMode,
            onChanged: onEcoModeChanged,
          ),
          const SizedBox(height: 12),
          SettingsTile(
            icon: Icons.assistant_direction_outlined,
            title: 'Cruise Control',
            subtitle: 'Hold speed near the active limit',
            value: cruiseMode,
            onChanged: onCruiseModeChanged,
          ),
        ],
      ),
    );
  }
}
