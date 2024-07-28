class TransfusionAction {
  final int actionID;
  final String? actionName;
  final DateTime actionDate;
  final String? actionTimeFromTo;
  final String? exactLocation;

  TransfusionAction({required this.actionID, required this.actionName, required this.actionDate,
  required this.actionTimeFromTo, required this.exactLocation});

  factory TransfusionAction.fromJson(Map<String, dynamic> json) {
    return TransfusionAction(
      actionID: json['ActionID'] ?? 0,
      actionName: json['ActionName'],
      actionDate: DateTime.parse(json['ActionDate']),
      actionTimeFromTo: json['ActionTimeFromTo'],
      exactLocation: json['ExactLocation']
    );
  }

}