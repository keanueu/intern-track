class TeamStats {
  final int totalInterns;
  final int activeToday;
  final int clockedInNow;
  final double avgCompletion;

  const TeamStats({
    required this.totalInterns,
    required this.activeToday,
    required this.clockedInNow,
    required this.avgCompletion,
  });

  factory TeamStats.empty() => const TeamStats(
        totalInterns: 0,
        activeToday: 0,
        clockedInNow: 0,
        avgCompletion: 0.0,
      );
}
