import 'package:calendar_app/presentation/pages/add_event_page.dart';
import 'package:calendar_app/presentation/widgets/custom_app_bar.dart';
import 'package:calendar_app/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/utils/theme.dart';
import '../../data/models/event_model.dart';
import '../blocs/event/event_bloc.dart';
import '../widgets/custom_calendar_widget.dart';

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
          SizedBox(
            height: MediaQuery.of(context).size.width - 15,
            child: BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                List<EventModel> events = [];

                if (state is CalendarLoaded) {
                  events = state.events;
                }

                return CustomCalendarWidget(
                  // isAddPage: false,
                  onMonthChanged: _updateAppBar,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Schedule",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
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
                  child: Container(
                    // width: 100,
                    // height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.primaryColor,
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 7,
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
            return const SizedBox.shrink();
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
