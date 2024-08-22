import 'package:calendar_app/data/models/event_model.dart';
import 'package:calendar_app/domain/repositories/event_repository.dart';

class GetEvent {
  final EventRepository eventRepository;

  GetEvent({
    required this.eventRepository,
  });

  Future<List<EventModel>> execute(DateTime start, DateTime end) async {
    return await eventRepository.getEvents(start, end);
  }
}
