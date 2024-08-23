// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:calendar_app/domain/usecases/add_event.dart';
import 'package:calendar_app/domain/usecases/delete_event.dart';

import 'package:calendar_app/domain/usecases/get_event.dart';
import 'package:calendar_app/domain/usecases/update_event.dart';

import '../../../data/models/event_model.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<CalendarEvent, EventState> {
  final AddEventUse _addEvent;
  final GetEvent _getEvent;
  final UpdateEventUse _updateEvent;
  final DeleteEventUse _deleteEvent;

  EventBloc({
    required AddEventUse addEvent,
    required GetEvent getEvent,
    required UpdateEventUse updatedEvent,
    required DeleteEventUse deleteEvent,
  })  : _addEvent = addEvent,
        _getEvent = getEvent,
        _updateEvent = updatedEvent,
        _deleteEvent = deleteEvent,
        super(CalendarInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<AddEvent>(_onAddEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    emit(CalendarLoading());
    try {
      // final events = await _eventRepository.getEvents(event.start, event.end);
      final events = await _getEvent.execute(event.start, event.end);
      emit(CalendarLoaded(events));
    } catch (e) {
      print(e);
      emit(CalendarError('Failed to load events: $e'));
    }
  }

  Future<void> _onAddEvent(AddEvent event, Emitter<EventState> emit) async {
    try {
      await _addEvent.execute(event.event);
      add(
        LoadEvents(
          event.event.selectedDay,
          DateTime(event.event.selectedDay.year, event.event.selectedDay.month,
              event.event.selectedDay.day, 23, 59, 59),
        ),
      );
    } catch (e) {
      emit(CalendarError('Failed to add event: $e'));
    }
  }

  Future<void> _onUpdateEvent(
      UpdateEvent event, Emitter<EventState> emit) async {
    try {
      // await _eventRepository.updateEvent(event.event);
      await _updateEvent.execute(event.event);
      add(LoadEvents(
        event.event.selectedDay,
        DateTime(event.event.selectedDay.year, event.event.selectedDay.month,
            event.event.selectedDay.day, 23, 59, 59),
      ));
    } catch (e) {
      emit(CalendarError('Failed to update event: $e'));
    }
  }

  Future<void> _onDeleteEvent(
      DeleteEvent event, Emitter<EventState> emit) async {
    try {
      // await _eventRepository.deleteEvent(event.id);
      await _deleteEvent.execute(event.id);
      add(
        LoadEvents(
          event.deleteTime,
          DateTime(event.deleteTime.year, event.deleteTime.month,
              event.deleteTime.day, 23, 59, 59),
        ),
      );
    } catch (e) {
      emit(CalendarError('Failed to delete event: $e'));
    }
  }
}
