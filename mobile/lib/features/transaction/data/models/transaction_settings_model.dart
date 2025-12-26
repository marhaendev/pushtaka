class TransactionSettingsModel {
  final int borrowDuration;
  final String borrowDurationUnit; // minute, hour, day
  final int fineAmount;
  final String fineUnit; // minute, hour, day
  final int fineDuration;
  final int maxBorrowLimit;

  TransactionSettingsModel({
    required this.borrowDuration,
    required this.borrowDurationUnit,
    required this.fineAmount,
    required this.fineUnit,
    required this.fineDuration,
    required this.maxBorrowLimit,
  });

  factory TransactionSettingsModel.fromJson(Map<String, dynamic> json) {
    return TransactionSettingsModel(
      borrowDuration:
          json['borrow_duration'] ??
          json['borrow_duration_days'] ??
          json['duration'] ??
          json['borrowDuration'] ??
          7,
      borrowDurationUnit:
          json['borrow_duration_unit'] ?? json['borrowDurationUnit'] ?? 'day',
      fineAmount:
          json['fine_amount'] ??
          json['fine_per_day'] ??
          json['finePerDay'] ??
          1000,
      fineUnit: json['fine_unit'] ?? json['fineUnit'] ?? 'day',
      fineDuration: json['fine_duration'] ?? json['fineDuration'] ?? 1,
      maxBorrowLimit: json['max_borrow_limit'] ?? json['maxBorrowLimit'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borrow_duration': borrowDuration,
      'borrow_duration_unit': borrowDurationUnit,
      // Legacy support fields
      'borrow_duration_days': borrowDuration,
      'duration': borrowDuration,
      'borrowDuration': borrowDuration,
      'borrowDurationUnit': borrowDurationUnit,

      'fine_amount': fineAmount,
      'fine_unit': fineUnit,
      'fine_duration': fineDuration,
      // Legacy support for older APIs expecting fine_per_day
      'fine_per_day': fineAmount,
      'finePerDay': fineAmount,

      'max_borrow_limit': maxBorrowLimit,
    };
  }
}
