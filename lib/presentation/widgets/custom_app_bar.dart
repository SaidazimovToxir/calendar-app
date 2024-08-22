import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime dateTime;

  const CustomAppBar({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    String formattedWeek = DateFormat('EEEE').format(dateTime);
    String formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);

    return AppBar(
      forceMaterialTransparency: true,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            formattedWeek,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
