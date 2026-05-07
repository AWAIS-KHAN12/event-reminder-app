import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> get _eventsRef {
    if (_user == null) {
      throw Exception("User is not logged-in!");
    }
    return _db.collection('users').doc(_user!.uid).collection('events');
  }

  Future<void> addEvent(EventModel event) async {
    await _eventsRef.add(event.toMap());
  }

  // get stream of events
  Stream<List<EventModel>> getEvents() {
    return _eventsRef
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshots) => snapshots.docs
              .map((doc) => EventModel.fromSnapshot(doc))
              .toList(),
        );
  }

  Future<void> updateEvent(EventModel event) async {
    if (event.id == null) return;
    await _eventsRef.doc(event.id).update(event.toMap());
  }

  Future<void> markEventCompleted(String eventId) async {
    await _eventsRef.doc(eventId).update({'isCompleted': true});
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsRef.doc(eventId).delete();
  }
}
