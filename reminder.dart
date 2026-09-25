class ReminderModel {
  final int? id;
  final String title;
  final DateTime dueDate;
  final String type; // GST, TDS, ITR, MCA, Other
  final bool completed;

  ReminderModel({
    this.id,
    required this.title,
    required this.dueDate,
    required this.type,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'type': type,
      'completed': completed ? 1 : 0,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      title: map['title'],
      dueDate: DateTime.parse(map['dueDate']),
      type: map['type'],
      completed: map['completed'] == 1,
    );
  }
}
