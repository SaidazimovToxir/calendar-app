import 'dart:async';
import 'package:calendar_app/data/models/event_model.dart';
import 'package:calendar_app/presentation/blocs/event/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/delete_button.dart';
import '../widgets/event_content.dart';
import '../widgets/event_header.dart';

class EventDetailsPage extends StatefulWidget {
  final EventModel event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsPage> {
  late EventModel _event;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = _formatRemainingTime(_remainingTime());

    return Scaffold(
      bottomNavigationBar:
          DeleteButton(onPressed: () => _onDeleteEvent(context)),
      body: CustomScrollView(
        slivers: [
          EventHeader(event: _event, onEdit: _onEditEvent),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: EventContent(
              event: _event,
              remainingTime: remainingTime,
            ),
          ),
        ],
      ),
    );
  }

  Duration _remainingTime() {
    final endTimeString = _event.endTime;
    final endTime = endTimeString;
    return endTime.difference(DateTime.now());
  }

  String _formatRemainingTime(Duration duration) {
    if (duration.isNegative) {
      return 'Event has ended';
    } else {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      final minutes = duration.inMinutes % 60;
      return '$days days, $hours hours, $minutes minutes';
    }
  }

  void _onDeleteEvent(BuildContext context) {
    context.read<EventBloc>().add(DeleteEvent(_event.id!, _event.selectedDay));
    Navigator.pop(context);
  }

  Future<void> _onEditEvent() async {
    // final updatedEvent = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AddEventScreen(
    //       event: _event,
    //       dateTime: _event.dateTime,
    //     ),
    //   ),
    // ) as Event?;

    // if (updatedEvent != null) {
    //   setState(() {
    //     _event = updatedEvent;
    //   });
    // }
  }
}
