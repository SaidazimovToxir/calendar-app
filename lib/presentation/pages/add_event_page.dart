import 'package:calendar_app/data/models/event_model.dart';
import 'package:calendar_app/presentation/blocs/event/event_bloc.dart';
import 'package:calendar_app/presentation/widgets/add_event_widget/color_picker.dart';
import 'package:calendar_app/presentation/widgets/add_event_widget/custom_color_picker.dart';
import 'package:calendar_app/presentation/widgets/custom_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/theme.dart';
import '../../domain/entities/event.dart';
import '../widgets/add_event_widget/custom_textfield.dart';

class AddEventPage extends StatefulWidget {
  final Event? event;
  final DateTime? dateTime;

  const AddEventPage({super.key, this.event, this.dateTime});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  Color _selectedColor = Colors.red;
  DateTime _selectedDate = DateTime.now();

  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _populateFields(widget.event!);
    } else {
      _initializeDefaultValues();
    }
  }

  void _populateFields(Event event) {
    _nameController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    _selectedStartTime = event.startTime;
    _selectedEndTime = event.endTime;
    _startTimeController.text = _formatDateTime(_selectedStartTime!);
    _endTimeController.text = _formatDateTime(_selectedEndTime!);
    _selectedColor = Color(event.color);
  }

  void _initializeDefaultValues() {
    _selectedStartTime = DateTime.now();
    _startTimeController.text = _formatDateTime(_selectedStartTime!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (_) => CustomColorPicker(
        initialColor: _selectedColor,
        onColorSelected: (color) {
          setState(() {
            _selectedColor = color;
          });
        },
      ),
    );
  }

  bool _validateFields() {
    return _nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _startTimeController.text.isNotEmpty &&
        _endTimeController.text.isNotEmpty;
  }

  void _addOrUpdateEvent() {
    if (_validateFields() &&
        _selectedStartTime != null &&
        _selectedEndTime != null) {
      final event = EventModel(
        id: widget.event?.id ?? '',
        title: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        startTime: _selectedStartTime!,
        endTime: _selectedEndTime!,
        color: _selectedColor.value,
      );

      if (widget.event == null) {
        context.read<EventBloc>().add(AddEvent(event));
      } else {
        context.read<EventBloc>().add(UpdateEvent(event));
      }
      Navigator.of(context).pop(event);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all the fields"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDateTime(TextEditingController controller,
      {required bool isStartTime}) async {
    final selectedDate = await _selectDate();
    if (selectedDate != null) {
      setState(() {
        isStartTime
            ? _selectedStartTime = selectedDate
            : _selectedEndTime = selectedDate;
      });

      await _pickTime(controller, isStartTime: isStartTime);
    }
  }

  Future<DateTime?> _selectDate() async {
    return await showDialog<DateTime>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date'),
        content: SizedBox(
          width: double.maxFinite,
          child: CustomCalendarWidget(
              onMonthChanged: (date) => _selectedDate = date),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, _selectedDate),
              child: const Text('Select')),
        ],
      ),
    );
  }

  Future<void> _pickTime(TextEditingController controller,
      {required bool isStartTime}) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        isStartTime
            ? (_selectedStartTime ?? DateTime.now())
            : (_selectedEndTime ?? DateTime.now()),
      ),
    );

    if (selectedTime != null) {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      setState(() {
        if (isStartTime) {
          _selectedStartTime = dateTime;
          _startTimeController.text = _formatDateTime(dateTime);
        } else {
          _selectedEndTime = dateTime;
          _endTimeController.text = _formatDateTime(dateTime);
        }
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 80,
        color: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addOrUpdateEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.event == null ? 'Add' : 'Update',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextfield(label: 'Event name', controller: _nameController),
              const SizedBox(height: 16),
              CustomTextfield(
                label: 'Event description',
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              CustomTextfield(
                label: 'Event location',
                controller: _locationController,
                suffixIcon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              ColorPicker(
                selectedColor: _selectedColor,
                onTap: _showColorPicker,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    _pickDateTime(_startTimeController, isStartTime: true),
                child: CustomTextfield(
                  ignorePointers: true,
                  label: 'Event start date & time',
                  controller: _startTimeController,
                  suffixIcon: Icons.access_time,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    _pickDateTime(_endTimeController, isStartTime: false),
                child: CustomTextfield(
                  ignorePointers: true,
                  label: 'Event end date & time',
                  controller: _endTimeController,
                  suffixIcon: Icons.access_time,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
