class Research {
  final int id;
  final String title;
  final String studentName;

  Research({required this.id, required this.title, required this.studentName});

  factory Research.fromJson(Map<String, dynamic> json) {
    return Research(
      id: json['id'],
      title: json['research_title'], // Corrected key
      studentName: json['student_name'],
    );
  }
}
