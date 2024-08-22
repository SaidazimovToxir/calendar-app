import 'package:calendar_app/domain/repositories/event_repository.dart';

class DeleteEventUse {
  final EventRepository eventRepository;

  DeleteEventUse({
    required this.eventRepository,
  });

  Future<void> execute(String id) async {
    return await eventRepository.deleteEvent(id);
  }
}
