class TaskModel {
  final int? id;
  final String title;
  final String description;
  final String deadline;
  final int status;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.status = 0,
  });

  bool get isCompleted => status == 1;

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      deadline: map['deadline'] as String,
      status: map['status'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'deadline': deadline,
      'status': status,
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? deadline,
    int? status,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
    );
  }
}
