import 'package:calendar_app/core/app.dart';
import 'package:calendar_app/core/dependency_injection.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await eventInit();
  runApp(const MyApp());
}
