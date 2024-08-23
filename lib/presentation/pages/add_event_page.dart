import 'package:calendar_app/data/models/event_model.dart';
import 'package:calendar_app/presentation/blocs/event/event_bloc.dart';
import 'package:calendar_app/presentation/pages/map_screen.dart';
import 'package:calendar_app/presentation/widgets/add_event_widget/color_picker.dart';
import 'package:calendar_app/presentation/widgets/add_event_widget/custom_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

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
  Color _selectedColor = Colors.teal;

  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();

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
    _selectedStartTime = TimeOfDay.fromDateTime(event.startTime);
    _selectedEndTime = TimeOfDay.fromDateTime(event.endTime);
    _startTimeController.text = _formatTime(_selectedStartTime);
    _endTimeController.text = _formatTime(_selectedEndTime);
    _selectedColor = Color(event.color);
  }

  void _initializeDefaultValues() {
    _selectedStartTime = TimeOfDay.fromDateTime(widget.dateTime!);
    _startTimeController.text = _formatTime(_selectedStartTime);
    _selectedEndTime =
        _selectedStartTime.replacing(hour: _selectedStartTime.hour + 1);
    _endTimeController.text = _formatTime(_selectedEndTime);
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
    if (!_nameController.text.isNotEmpty ||
        !_descriptionController.text.isNotEmpty ||
        !_locationController.text.isNotEmpty ||
        !_startTimeController.text.isNotEmpty ||
        !_endTimeController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all the fields"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_selectedStartTime.hour > _selectedEndTime.hour ||
        (_selectedStartTime.hour == _selectedEndTime.hour &&
            _selectedStartTime.minute >= _selectedEndTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("End time must be after start time"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _addOrUpdateEvent() {
    if (_validateFields()) {
      final startTime = DateTime(
        widget.dateTime!.year,
        widget.dateTime!.month,
        widget.dateTime!.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      );

      final endTime = DateTime(
        widget.dateTime!.year,
        widget.dateTime!.month,
        widget.dateTime!.day,
        _selectedEndTime.hour,
        _selectedEndTime.minute,
      );

      final event = EventModel(
        id: widget.event?.id ?? '',
        title: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        startTime: startTime,
        endTime: endTime,
        color: _selectedColor.value,
        selectedDay: widget.dateTime!,
      );

      if (widget.event == null) {
        context.read<EventBloc>().add(AddEvent(event));
      } else {
        context.read<EventBloc>().add(UpdateEvent(event));
      }
      Navigator.of(context).pop(event);
    }
  }

  Future<void> _pickStartTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );

    if (selectedTime != null) {
      setState(() {
        _selectedStartTime = selectedTime;
        _startTimeController.text = _formatTime(selectedTime);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );

    if (selectedTime != null) {
      setState(() {
        _selectedEndTime = selectedTime;
        _endTimeController.text = _formatTime(selectedTime);
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  List<SuggestItem> _suggestionList = [];
  final YandexSearch yandexSearch = YandexSearch();
  double searchHeight = 225;

  Future<SuggestSessionResult> _suggest() async {
    final resultWithSession = await YandexSuggest.getSuggestions(
      text: _locationController.text,
      boundingBox: const BoundingBox(
        northEast: Point(latitude: 56.0421, longitude: 38.0284),
        southWest: Point(latitude: 55.5143, longitude: 37.24841),
      ),
      suggestOptions: const SuggestOptions(
        suggestType: SuggestType.geo,
        suggestWords: true,
        userPosition: Point(latitude: 56.0321, longitude: 38),
      ),
    );

    return await resultWithSession.$2;
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 75,
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        color: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addOrUpdateEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.event == null ? 'Add' : 'Update',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
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
              Column(
                children: [
                  CustomTextfield(
                    label: 'Event location',
                    controller: _locationController,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColor.primaryColor,
                    ),
                    suffixIcon: _suggestionList.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _locationController.text = "";
                                _suggestionList = [];
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.clear_fill,
                              color: Colors.grey,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => const MapScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.map_rounded,
                              color: AppColor.primaryColor,
                            ),
                          ),
                    onChanged: (value) async {
                      final res = await _suggest();
                      if (res.items != null) {
                        setState(() {
                          _suggestionList = res.items!.toSet().toList();
                        });
                      }
                      if (_suggestionList.isNotEmpty) {
                        searchHeight = 225;
                        setState(() {});
                      }
                    },
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _suggestionList.isNotEmpty ? searchHeight : 0,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      color: AppColor.textFieldFilledColor,
                    ),
                    child: ListView.builder(
                      itemCount: _suggestionList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            setState(() {
                              searchHeight = 0;
                              _locationController.text =
                                  _suggestionList[index].title;
                            });
                          },
                          title: Text(
                            _suggestionList[index].title,
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            _suggestionList[index].subtitle!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ColorPicker(
                selectedColor: _selectedColor,
                onTap: _showColorPicker,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickStartTime,
                child: CustomTextfield(
                  ignorePointers: true,
                  label: 'Event start time',
                  controller: _startTimeController,
                  suffixIcon: Icon(
                    Icons.access_time,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickEndTime,
                child: CustomTextfield(
                  ignorePointers: true,
                  label: 'Event end time',
                  controller: _endTimeController,
                  suffixIcon: Icon(
                    Icons.access_time,
                    color: AppColor.primaryColor,
                  ),
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


