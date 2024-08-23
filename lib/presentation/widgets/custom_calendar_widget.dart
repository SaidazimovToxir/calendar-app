import 'package:calendar_app/core/utils/theme.dart';
import 'package:calendar_app/presentation/widgets/calendar/week_day_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/event.dart';
import '../blocs/event/event_bloc.dart';

class CustomCalendarWidget extends StatefulWidget {
  final Function(DateTime) onMonthChanged;

  const CustomCalendarWidget({
    super.key,
    required this.onMonthChanged,
  });

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<Event>> _events = {};

  late final PageController _pageController;
  int _currentMonthIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    _currentMonthIndex = _calculateMonthPageIndex(_focusedDay);
    _pageController = PageController(initialPage: _currentMonthIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventsForMonth(_focusedDay);
    });
  }

  void _loadEventsForMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    context.read<EventBloc>().add(LoadEvents(
          firstDayOfMonth,
          lastDayOfMonth,
        ));

    setState(() {
      _events.clear();
    });
    widget.onMonthChanged(month);
  }

  int _calculateMonthPageIndex(DateTime date) {
    return (date.year * 12 + date.month) - (DateTime(2020).year * 12 + 1);
  }

  DateTime _calculateMonthFromPageIndex(int pageIndex) {
    final year = (pageIndex ~/ 12) + 2020;
    final month = (pageIndex % 12) + 1;
    return DateTime(year, month);
  }

  void _onPageChanged(int pageIndex) {
    final newMonth = _calculateMonthFromPageIndex(pageIndex);
    setState(() {
      _focusedDay = newMonth;
    });
    _loadEventsForMonth(newMonth);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventBloc, EventState>(
      listener: (context, state) {
        if (state is CalendarLoaded) {
          setState(() {
            final firstDay =
                state.events.isNotEmpty ? state.events.first.startTime : null;
            final lastDay =
                state.events.isNotEmpty ? state.events.last.startTime : null;
            if (firstDay != null && lastDay != null) {
              for (var date = firstDay;
                  date.isBefore(lastDay) || date.isAtSameMomentAs(lastDay);
                  date = date.add(const Duration(days: 1))) {
                _events.remove(DateTime(date.year, date.month, date.day));
              }
            }

            for (var event in state.events) {
              final eventDate = DateTime(
                event.startTime.year,
                event.startTime.month,
                event.startTime.day,
              );
              _events.update(
                eventDate,
                (list) => list..add(event),
                ifAbsent: () => [event],
              );
            }
          });
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildCalendarHeader(),
            const Gap(10.0),
            const WeekdayLabels(),
            const Gap(10.0),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final monthDate = _calculateMonthFromPageIndex(index);
                  return _buildCalendarBody(monthDate);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarHeader() {
    String formattedDate = DateFormat('MMMM').format(_focusedDay);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xffEFEFEF),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
              const Gap(10.0),
              CircleAvatar(
                backgroundColor: const Color(0xffEFEFEF),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarBody(
    DateTime monthDate,
  ) {
    final daysInMonth = _daysInMonth(monthDate);
    final firstDayOfWeek = _firstDayOfWeek(monthDate);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth + firstDayOfWeek,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < firstDayOfWeek) {
          return Container();
        }
        final day = index - firstDayOfWeek + 1;
        final date = DateTime(monthDate.year, monthDate.month, day);
        final isSelected = _selectedDay.year == date.year &&
            _selectedDay.month == date.month &&
            _selectedDay.day == date.day;
        final dayEvents = _events[date] ?? [];

        return GestureDetector(
          onTap: () {
            // print(date);
            setState(() {
              _selectedDay = date;
            });
            print(_selectedDay);
            context.read<EventBloc>().add(
                  LoadEvents(
                    date,
                    // date.add(const Duration(days: 1)).subtract(
                    //       const Duration(seconds: 1),
                    //     ),
                    DateTime(date.year, date.month, date.day, 23, 59, 59),
                  ),
                );
            widget.onMonthChanged(date);
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColor.primaryColor : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: isSelected ? 16 : 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
                if (dayEvents.isNotEmpty)
                  Positioned(
                    bottom: -15,
                    left: dayEvents.length == 1
                        ? 4
                        : dayEvents.length == 2
                            ? -1
                            : -6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(
                          dayEvents.length > 3 ? 3 : dayEvents.length,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(dayEvents[index].color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstDayOfWeek(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }
}


/* import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../core/utils/theme.dart';
import '../blocs/calendar_cubit/calendar_cubit.dart';
import '../blocs/event/event_bloc.dart';
import '../widgets/calendar/week_day_label.dart';

class CustomCalendarWidget extends StatelessWidget {
  final bool isAddPage;
  final Function(DateTime) onMonthChanged;

  const CustomCalendarWidget({
    super.key,
    required this.onMonthChanged,
    required this.isAddPage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarCubit(
        eventBloc: context.read<EventBloc>(),
      ),
      child: _CalendarContent(
        onMonthChanged: onMonthChanged,
        isAddPage: isAddPage,
      ),
    );
  }
}

class _CalendarContent extends StatelessWidget {
  final bool isAddPage;
  final Function(DateTime) onMonthChanged;

  const _CalendarContent({
    required this.onMonthChanged,
    required this.isAddPage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildCalendarHeader(context, state),
            const Gap(10.0),
            const WeekdayLabels(),
            const Gap(10.0),
            Expanded(
              child: PageView.builder(
                controller:
                    PageController(initialPage: state.currentMonthIndex),
                onPageChanged: (index) {
                  final newMonth = _calculateMonthFromPageIndex(index);
                  context.read<CalendarCubit>().changeMonth(newMonth);
                  onMonthChanged(newMonth);
                },
                itemBuilder: (context, index) {
                  final monthDate = _calculateMonthFromPageIndex(index);
                  return _buildCalendarBody(context, monthDate, state);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarHeader(BuildContext context, CalendarState state) {
    String formattedDate = DateFormat('MMMM yyyy').format(state.focusedDay);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xffEFEFEF),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final newMonth = DateTime(
                      state.focusedDay.year,
                      state.focusedDay.month - 1,
                    );
                    context.read<CalendarCubit>().changeMonth(newMonth);
                    onMonthChanged(newMonth);
                  },
                ),
              ),
              const Gap(10.0),
              CircleAvatar(
                backgroundColor: const Color(0xffEFEFEF),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final newMonth = DateTime(
                        state.focusedDay.year, state.focusedDay.month + 1);
                    context.read<CalendarCubit>().changeMonth(newMonth);
                    onMonthChanged(newMonth);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarBody(
      BuildContext context, DateTime monthDate, CalendarState state) {
    final daysInMonth = _daysInMonth(monthDate);
    final firstDayOfWeek = _firstDayOfWeek(monthDate);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth + firstDayOfWeek,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < firstDayOfWeek) {
          return Container();
        }
        final day = index - firstDayOfWeek + 1;
        final date = DateTime(monthDate.year, monthDate.month, day);
        final isSelected = state.selectedDay.year == date.year &&
            state.selectedDay.month == date.month &&
            state.selectedDay.day == date.day;
        final dayEvents = state.events[date] ?? [];

        return GestureDetector(
          onTap: () {
            context.read<CalendarCubit>().selectDay(date);
            onMonthChanged(date);
          },
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(isAddPage ? 0 : 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColor.primaryColor : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: isSelected ? 16 : 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
                if (dayEvents.isNotEmpty)
                  Positioned(
                    bottom: -15,
                    left: dayEvents.length == 1
                        ? 4
                        : dayEvents.length == 2
                            ? -1
                            : -6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(
                          dayEvents.length > 3 ? 3 : dayEvents.length,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(dayEvents[index].color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime _calculateMonthFromPageIndex(int pageIndex) {
    final year = (pageIndex ~/ 12) + 2020;
    final month = (pageIndex % 12) + 1;
    return DateTime(year, month);
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstDayOfWeek(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }
}
 */