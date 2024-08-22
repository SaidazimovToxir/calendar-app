import 'package:calendar_app/presentation/pages/add_event_page.dart';
import 'package:calendar_app/presentation/widgets/custom_app_bar.dart';
import 'package:calendar_app/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/utils/theme.dart';
import '../blocs/event/event_bloc.dart';
import '../widgets/custom_calendar_widget.dart';
import '../widgets/shimmer/shimmer_event_cart.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  void _updateAppBar(DateTime newFocusedDay) {
    setState(() {
      _focusedDay = newFocusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(dateTime: _focusedDay),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                // List<EventModel> events = [];

                if (state is CalendarLoaded) {
                  // events = state.events;
                }

                return CustomCalendarWidget(
                  onMonthChanged: _updateAppBar,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Schedule",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  // width: 100,
                  // height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColor.primaryColor,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEventPage(
                            dateTime: _focusedDay,
                          ),
                        ),
                      );
                    },
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8,
                        ),
                        child: Text(
                          "+ Add Event",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16.0),
          _buildEventList(),
        ],
      ),
      //
    );
  }

  Widget _buildEventList() {
    return Expanded(
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const Center(child: ShimmerEventCard());
          } else if (state is CalendarLoaded) {
            if (state.events.isEmpty) {
              return const Center(
                child: Text("Malumotlar yoq"),
              );
            }
            return EventList(events: state.events);
          } else if (state is CalendarError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No events available'));
        },
      ),
    );
  }
}
