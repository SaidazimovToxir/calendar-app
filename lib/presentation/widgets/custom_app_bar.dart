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
              fontSize: 18,
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
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_rounded,
            size: 25,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
