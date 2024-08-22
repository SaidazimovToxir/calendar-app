import 'package:calendar_app/data/models/event_model.dart';


abstract class EventRepository {
  Future<List<EventModel>> getEvents(DateTime start, DateTime end);
  Future<void> addEvent(EventModel event);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
}
