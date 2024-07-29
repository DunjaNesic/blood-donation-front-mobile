class TransfusionAction {
  final int actionID;
  final String? actionName;
  final DateTime actionDate;
  final String? actionTimeFromTo;
  final String? exactLocation;
  final String? placeName;

  TransfusionAction({required this.actionID, required this.actionName, required this.actionDate,
  required this.actionTimeFromTo, required this.exactLocation, required this.placeName});

  factory TransfusionAction.fromJson(Map<String, dynamic> json) {
    return TransfusionAction(
      actionID: json['actionID'] ?? 0,
      actionName: json['actionName'],
        actionDate: json['actionDate'] != null
            ? DateTime.parse(json['actionDate'])
            : DateTime.now(),
      actionTimeFromTo: json['actionTimeFromTo'],
      exactLocation: json['exactLocation'],
      placeName: json['placeName']
    );
  }

}