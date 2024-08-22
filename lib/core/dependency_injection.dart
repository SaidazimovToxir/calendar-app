import 'package:calendar_app/data/datasource/local/sqlite_database.dart';
import 'package:calendar_app/data/repositories/event_repository_impl.dart';
import 'package:calendar_app/domain/repositories/event_repository.dart';
import 'package:calendar_app/domain/usecases/add_event.dart';
import 'package:calendar_app/domain/usecases/delete_event.dart';
import 'package:calendar_app/domain/usecases/update_event.dart';
import 'package:calendar_app/presentation/blocs/event/event_bloc.dart';
import 'package:get_it/get_it.dart';

import '../domain/usecases/get_event.dart';

final getIt = GetIt.instance;

Future<void> eventInit() async {

  getIt.registerSingleton<SQLiteDatabase>(SQLiteDatabase());

  getIt.registerSingleton<EventRepository>(
    EventRepositoryImpl(
      getIt.get<SQLiteDatabase>(),
    ),
  );

  getIt.registerSingleton<GetEvent>(
    GetEvent(
      eventRepository: getIt.get<EventRepository>(),
    ),
  );

  getIt.registerSingleton<AddEventUse>(
    AddEventUse(
      eventRepository: getIt.get<EventRepository>(),
    ),
  );

  getIt.registerSingleton<UpdateEventUse>(
    UpdateEventUse(
      eventRepository: getIt.get<EventRepository>(),
    ),
  );

  getIt.registerSingleton<DeleteEventUse>(
    DeleteEventUse(
      eventRepository: getIt.get<EventRepository>(),
    ),
  );

  getIt.registerSingleton<EventBloc>(
    EventBloc(
      addEvent: getIt.get<AddEventUse>(),
      getEvent: getIt.get<GetEvent>(),
      updatedEvent: getIt.get<UpdateEventUse>(),
      deleteEvent: getIt.get<DeleteEventUse>(),
    ),
  );
}
