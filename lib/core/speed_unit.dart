enum SpeedUnit {
  kmh('KM/H', 1),
  mph('MPH', 0.621371);

  const SpeedUnit(this.label, this.factor);

  final String label;
  final double factor;
}
