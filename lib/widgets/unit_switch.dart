import 'package:flutter/material.dart';
import 'package:speedometer/core/speed_unit.dart';

class UnitSwitch extends StatelessWidget {
  const UnitSwitch({
    super.key,
    required this.selectedUnit,
    required this.onChanged,
  });

  final SpeedUnit selectedUnit;
  final ValueChanged<SpeedUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
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
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
