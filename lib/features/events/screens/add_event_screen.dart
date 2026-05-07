import 'package:event_reminder_app/features/events/models/event_model.dart';
import 'package:event_reminder_app/features/events/services/database_service.dart';
import 'package:event_reminder_app/features/events/services/ai_service.dart';
import 'package:event_reminder_app/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? event;

  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedCategory;
  late String _selectedPriority;
  late Map<String, bool> _reminders;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController = TextEditingController(text: widget.event!.title);
      _descController = TextEditingController(text: widget.event!.description);
      _locationController = TextEditingController(text: widget.event!.location);
      _selectedDate = widget.event!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.date);
      _selectedCategory = widget.event!.category;
      _selectedPriority = widget.event!.priority;
      _reminders = Map.from(widget.event!.reminderSettings);
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _locationController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedCategory = 'Work';
      _selectedPriority = 'Medium';
      _reminders = {'5min': false, '30min': false, '1day': false};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: oceanBlueColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: oceanBlueColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _openSmartInput() {
    final TextEditingController promptController = TextEditingController();
    void addText(String text) {
      promptController.text = "${promptController.text} $text".trim();
      promptController.selection = TextSelection.fromPosition(
        TextPosition(offset: promptController.text.length),
      );
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, skyBlueColor.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [oceanBlueColor, cyanColor],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "AI Assistant",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "Describe your event naturally. AI will extract details for you.",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: promptController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "e.g., Team meeting tomorrow at 2 PM in Conference room...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: lightCyanColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: oceanBlueColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text("📅 Meeting"),
                    backgroundColor: skyBlueColor,
                    labelStyle: TextStyle(
                      color: darkBlueColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () => addText("Meeting with "),
                  ),
                  ActionChip(
                    label: const Text("🎓 Assignment"),
                    backgroundColor: lightCyanColor,
                    labelStyle: TextStyle(
                      color: darkBlueColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () => addText("Submit assignment "),
                  ),
                  ActionChip(
                    label: const Text("💼 Deadline"),
                    backgroundColor: cyanColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: oceanBlueColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () => addText("Deadline for "),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.stars, size: 18),
                    label: const Text("Generate"),
                    style: FilledButton.styleFrom(
                      backgroundColor: oceanBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (promptController.text.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please describe your event",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      Get.back();
                      Get.dialog(
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        barrierDismissible: false,
                      );

                      try {
                        final aiService = AIService();
                        final data = await aiService.generateEventFromText(
                          promptController.text,
                        );

                        Get.back();

                        if (data != null) {
                          setState(() {
                            _titleController.text = data['title'] ?? "";
                            _descController.text = data['description'] ?? "";
                            _selectedCategory = data['category'] ?? "Personal";

                            if (data['date'] != null) {
                              try {
                                _selectedDate =
                                    DateTime.parse(data['date'].toString());
                              } catch (e) {
                                print("Date parse error: $e");
                              }
                            }

                            if (data['time'] != null) {
                              try {
                                final timeString = data['time'].toString();
                                final parts = timeString.split(':');
                                if (parts.length == 2) {
                                  _selectedTime = TimeOfDay(
                                    hour: int.parse(parts[0]),
                                    minute: int.parse(parts[1]),
                                  );
                                }
                              } catch (e) {
                                print("Time parse error: $e");
                              }
                            }
                          });

                          Get.snackbar(
                            "Magic!",
                            "Form autofilled by AI ✨",
                            backgroundColor: Colors.greenAccent,
                            colorText: Colors.black,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } else {
                          Get.snackbar(
                            "Error",
                            "Could not understand input",
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        Get.back();
                        Get.snackbar(
                          "Error",
                          "AI Service Error: $e",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final DateTime finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final eventData = EventModel(
      id: widget.event?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      location: _locationController.text.trim(),
      date: finalDateTime,
      category: _selectedCategory,
      priority: _selectedPriority,
      reminderSettings: _reminders,
      isCompleted: widget.event?.isCompleted ?? false,
    );

    try {
      if (widget.event == null) {
        await DatabaseService().addEvent(eventData);
        Get.back();
        Get.snackbar(
          "Success",
          "Event created! 🎉",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await DatabaseService().updateEvent(eventData);
        Get.back();
        Get.back();
        Get.snackbar(
          "Updated",
          "Event updated successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Action failed: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: oceanBlueColor),
      filled: true,
      fillColor: skyBlueColor.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: lightCyanColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: lightCyanColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: oceanBlueColor, width: 2),
      ),
      labelStyle: TextStyle(color: oceanBlueColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [darkBlueColor, oceanBlueColor, cyanColor],
                  ),
                ),
                child: Center(
                  child: Text(
                    isEditing ? "Edit Event" : "Create Event",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (!isEditing)
                IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  tooltip: "AI Smart Fill",
                  onPressed: _openSmartInput,
                ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Event Title",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (val) =>
                          val!.isEmpty ? "Please enter a title" : null,
                    ),

                    const SizedBox(height: 20),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [lightCyanColor, cyanColor, lightCyanColor],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    const Text(
                      "Category",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: ['Work', 'Personal', 'Social'].map((category) {
                        final isSelected = _selectedCategory == category;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? oceanBlueColor.withOpacity(0.3)
                                    : Colors.transparent,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: oceanBlueColor,
                            backgroundColor: skyBlueColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : darkBlueColor,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (selected) =>
                                setState(() => _selectedCategory = category),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Date & Time",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    skyBlueColor,
                                    lightCyanColor.withOpacity(0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: lightCyanColor, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      color: oceanBlueColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 18, color: oceanBlueColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat.yMMMd().format(_selectedDate),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    lightCyanColor.withOpacity(0.6),
                                    cyanColor.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: cyanColor, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Time",
                                    style: TextStyle(
                                      color: oceanBlueColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 18, color: oceanBlueColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime.format(context),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Location & Details",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration(
                        "Location",
                        Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        "Description",
                        Icons.description_outlined,
                      ).copyWith(alignLabelWithHint: true),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Reminders",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _buildReminderSwitch("🔔 5 minutes before", '5min'),
                    _buildReminderSwitch("⏰ 30 minutes before", '30min'),
                    _buildReminderSwitch("📅 1 day before", '1day'),

                    const SizedBox(height: 35),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: oceanBlueColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _saveEvent,
                          style: FilledButton.styleFrom(
                            backgroundColor: oceanBlueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  isEditing
                                      ? "Update Event"
                                      : "Create Event",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSwitch(String label, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _reminders[key]! ? skyBlueColor : Colors.white,
            _reminders[key]! ? lightCyanColor.withOpacity(0.3) : Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _reminders[key]! ? lightCyanColor : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          label,
          style: TextStyle(
            color: _reminders[key]! ? darkBlueColor : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        value: _reminders[key]!,
        activeColor: oceanBlueColor,
        onChanged: (val) => setState(() => _reminders[key] = val),
      ),
    );
  }
}