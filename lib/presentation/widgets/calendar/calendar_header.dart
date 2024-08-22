import 'package:calendar_app/data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app/core/utils/theme.dart';

class CalendarBody extends StatelessWidget {
  final DateTime monthDate;
  final DateTime selectedDay;
  final Map<DateTime, List<EventModel>> events;
  final Function(DateTime) onDaySelected;

  const CalendarBody({
    super.key,
    required this.monthDate,
    required this.selectedDay,
    required this.events,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
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
        final isSelected = selectedDay.year == date.year &&
            selectedDay.month == date.month &&
            selectedDay.day == date.day;
        final dayEvents = events[date] ?? [];

        return GestureDetector(
          onTap: () => onDaySelected(date),
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
