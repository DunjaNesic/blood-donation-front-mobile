class DonorStatistics {
  final String jmbg;
  final int totalActions;
  final double acceptedAndAttendedPercentage;
  final double acceptedButDidNotAttendPercentage;
  final double declinedAndDidNotAttendPercentage;
  final double declinedButAttendedPercentage;

  DonorStatistics({
    required this.jmbg,
    required this.totalActions,
    required this.acceptedAndAttendedPercentage,
    required this.acceptedButDidNotAttendPercentage,
    required this.declinedAndDidNotAttendPercentage,
    required this.declinedButAttendedPercentage,
  });

  factory DonorStatistics.fromJson(Map<String, dynamic> json) {
    return DonorStatistics(
      jmbg: json['jmbg'],
      totalActions: json['totalActions'],
      acceptedAndAttendedPercentage: json['acceptedAndAttendedPercentage'],
      acceptedButDidNotAttendPercentage: json['acceptedButDidNotAttendPercentage'],
      declinedAndDidNotAttendPercentage: json['declinedAndDidNotAttendPercentage'],
      declinedButAttendedPercentage: json['declinedButAttendedPercentage'],
    );
  }
}
