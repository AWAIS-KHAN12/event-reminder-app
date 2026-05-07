import 'package:event_reminder_app/features/events/models/event_model.dart';
import 'package:event_reminder_app/features/events/screens/add_event_screen.dart';
import 'package:event_reminder_app/features/events/services/database_service.dart';
import 'package:event_reminder_app/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  void _deleteEvent() {
    Get.defaultDialog(
      title: "Delete Event",
      middleText: "Are you sure you want to delete '${event.title}'?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        if (event.id != null) {
          await DatabaseService().deleteEvent(event.id!);
          Get.back();
          Get.back();
          Get.snackbar("Deleted", "Event removed successfully");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
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
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              event.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {
                  Get.to(() => AddEventScreen(event: event));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: _deleteEvent,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Time Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [skyBlueColor, lightCyanColor.withOpacity(0.5)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: lightCyanColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: oceanBlueColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: oceanBlueColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMMEEEEd().format(event.date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: darkBlueColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.jm().format(event.date),
                                style: TextStyle(
                                  color: oceanBlueColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Description Section
                  _buildSectionTitle("Description", Icons.description_outlined),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: skyBlueColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      event.description.isEmpty
                          ? "No description provided."
                          : event.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Location Section
                  _buildSectionTitle("Location", Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          lightCyanColor.withOpacity(0.2),
                          cyanColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: lightCyanColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: oceanBlueColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            event.location.isEmpty
                                ? "No location specified"
                                : event.location,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: darkBlueColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Reminders Section
                  _buildSectionTitle("Reminders", Icons.notifications_outlined),
                  const SizedBox(height: 12),
                  _buildReminderTile(
                    "🔔 5 minutes before",
                    event.reminderSettings['5min'] ?? false,
                  ),
                  _buildReminderTile(
                    "⏰ 30 minutes before",
                    event.reminderSettings['30min'] ?? false,
                  ),
                  _buildReminderTile(
                    "📅 1 day before",
                    event.reminderSettings['1day'] ?? false,
                  ),

                  const SizedBox(height: 30),

                  // Mark as Completed Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: event.isCompleted
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.green.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: FilledButton(
                        onPressed: event.isCompleted
                            ? null
                            : () async {
                                if (event.id == null) return;

                                await DatabaseService()
                                    .markEventCompleted(event.id!);

                                Get.back();

                                Get.snackbar(
                                  "Completed 🎉",
                                  "Event marked as completed",
                                  backgroundColor: Colors.greenAccent,
                                  colorText: Colors.black,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: event.isCompleted
                              ? Colors.grey.shade300
                              : oceanBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          event.isCompleted
                              ? "✓ Completed"
                              : "Mark as Completed",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: event.isCompleted
                                ? Colors.grey.shade600
                                : Colors.white,
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: oceanBlueColor, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTile(String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [skyBlueColor, lightCyanColor.withOpacity(0.4)]
              : [Colors.white, Colors.white],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? lightCyanColor : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? oceanBlueColor.withOpacity(0.1)
                : Colors.transparent,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isActive ? darkBlueColor : Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? oceanBlueColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? "On" : "Off",
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}