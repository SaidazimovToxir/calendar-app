import 'package:calendar_app/data/models/event_model.dart';
import 'package:calendar_app/domain/repositories/event_repository.dart';

class UpdateEventUse {
  final EventRepository eventRepository;

  UpdateEventUse({
    required this.eventRepository,
  });

  Future<void> execute(EventModel event) async {
    return await eventRepository.updateEvent(event);
  }
}
