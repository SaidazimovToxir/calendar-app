import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/blocs/calendar/calendar_bloc.dart';
import '../presentation/blocs/event/event_bloc.dart';
import '../presentation/pages/add_event_page.dart';
import '../presentation/pages/calendar_page.dart';
import 'dependency_injection.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt.get<EventBloc>(),
        ),
        BlocProvider(
          create: (context) => CalendarBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Calendar App',
        initialRoute: '/',
        routes: {
          '/': (context) => const CalendarPage(),
          '/add_event': (context) => const AddEventPage(),
        },
      ),
    );
  }
}
