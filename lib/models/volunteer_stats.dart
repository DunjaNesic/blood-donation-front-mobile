import 'package:blood_donation/models/stats.dart';

class VolunteerStatistics implements Statistics{
  final int volunteerID;
  final String fullName;
  final int totalActions;
  @override
  final double acceptedAndAttendedPercentage;
  @override
  final double acceptedButDidNotAttendPercentage;
  @override
  final double declinedAndDidNotAttendPercentage;
  @override
  final double declinedButAttendedPercentage;

  VolunteerStatistics({
    required this.volunteerID,
    required this.fullName,
    required this.totalActions,
    required this.acceptedAndAttendedPercentage,
    required this.acceptedButDidNotAttendPercentage,
    required this.declinedAndDidNotAttendPercentage,
    required this.declinedButAttendedPercentage,
  });

  factory VolunteerStatistics.fromJson(Map<String, dynamic> json) {
    return VolunteerStatistics(
      volunteerID: json['volunteerID'],
      fullName: json['fullName'],
      totalActions: json['totalActions'],
      acceptedAndAttendedPercentage: json['acceptedAndAttendedPercentage'],
      acceptedButDidNotAttendPercentage: json['acceptedButDidNotAttendPercentage'],
      declinedAndDidNotAttendPercentage: json['declinedAndDidNotAttendPercentage'],
      declinedButAttendedPercentage: json['declinedButAttendedPercentage'],
    );
  }
}
