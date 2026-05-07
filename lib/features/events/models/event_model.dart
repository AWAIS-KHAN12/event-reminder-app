import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String? id;
  final String title;
  final String description;
  final DateTime date;
  final String priority;
  final String category;
  final String location;
  final Map<String, bool> reminderSettings;
  final bool isCompleted;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    required this.category,
    required this.location,
    required this.reminderSettings,
    this.isCompleted = false,
  });

  // Map for Sending to Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'priority': priority,
      'category': category,
      'location': location,
      'reminderSettings': reminderSettings,
      'isCompleted': isCompleted,
    };
  }

  // reading from Firestore
  factory EventModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (doc.data()?['date'] as Timestamp).toDate(),
      priority: doc.data()?['priority'] ?? 'Low',
      category: doc.data()?['category'] ?? 'General',
      location: doc.data()?['location'] ?? 'No location',
      reminderSettings: Map<String, bool>.from(
        data['reminderSettings'] ??
            {'5min': false, '30min': false, '1day': false},
      ),
      isCompleted: doc.data()?['isCompleted'] ?? false,
    );
  }
}
