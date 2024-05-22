class Income {
  final int id;
  final String title;
  final double amount;
  final DateTime date;

  Income({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount.toString(),
      'date': date.toIso8601String(),
    };
  }

  factory Income.fromString(Map<String, dynamic> data) {
    return Income(
      id: data['id'],
      title: data['title'],
      amount: double.parse(data['amount']),
      date: DateTime.parse(data['date']),
    );
  }
}
