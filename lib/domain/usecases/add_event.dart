import 'package:calendar_app/data/models/event_model.dart';
import 'package:calendar_app/domain/repositories/event_repository.dart';

class AddEventUse {
  final EventRepository eventRepository;

  AddEventUse({
    required this.eventRepository,
  });

  Future<void> execute(EventModel event) async {
    return await eventRepository.addEvent(event);
  }
}
