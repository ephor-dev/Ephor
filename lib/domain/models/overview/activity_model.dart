class ActivityModel {
  final String employeeName;
  final String status;
  final DateTime timestamp;

  ActivityModel({
    required this.employeeName,
    required this.status,
    required this.timestamp,
  });

  // Helper to determine if the status counts as "completed" for the UI red dot
  bool get isCompleted => status.toLowerCase() == 'completed';

  // Helper to format the time (e.g., "2 hours ago")
  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} mins ago';
    return 'Just now';
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      employeeName: json['employee_name'] ?? 'Unknown Employee',
      status: json['status'] ?? 'Pending',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
}