part of 'event_bloc.dart';


abstract class CalendarEvent {}

class LoadEvents extends CalendarEvent {
  final DateTime start;
  final DateTime end;

  LoadEvents(this.start, this.end);
}

class AddEvent extends CalendarEvent {
  final EventModel event;

  AddEvent(this.event);
}

class UpdateEvent extends CalendarEvent {
  final EventModel event;

  UpdateEvent(this.event);
}

class DeleteEvent extends CalendarEvent {
  final String id;

  DeleteEvent(this.id);
}
