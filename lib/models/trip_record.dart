class TripRecord {
  const TripRecord({
    required this.title,
    required this.createdAt,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.distanceKm,
    required this.driveSeconds,
    required this.safetyScore,
    required this.overLimitEvents,
  });

  final String title;
  final DateTime createdAt;
  final double averageSpeed;
  final double maxSpeed;
  final double distanceKm;
  final int driveSeconds;
  final int safetyScore;
  final int overLimitEvents;
}
