import 'package:flutter/material.dart';
import 'package:speedometer/core/speed_unit.dart';
import 'package:speedometer/widgets/unit_switch.dart';

class SpeedTrackHeader extends StatelessWidget {
  const SpeedTrackHeader({
    super.key,
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
                    fontSize: 28,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 142,
          child: UnitSwitch(
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
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF254D86), Color(0xFF102846)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF456FA7)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
