import 'package:blood_donation/models/stats.dart';

class DonorStatistics implements Statistics {
  final String jmbg;
  final int totalActions;
  @override
  final double acceptedAndAttendedPercentage;
  @override
  final double acceptedButDidNotAttendPercentage;
  @override
  final double declinedAndDidNotAttendPercentage;
  @override
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
