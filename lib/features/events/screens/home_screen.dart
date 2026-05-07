import 'package:event_reminder_app/features/events/models/event_model.dart';
import 'package:event_reminder_app/features/events/screens/add_event_screen.dart';
import 'package:event_reminder_app/features/events/screens/event_details_screen.dart';
import 'package:event_reminder_app/features/events/services/database_service.dart';
import 'package:event_reminder_app/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<EventModel>> _events = {};
  bool _showCalendar = false;
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    DatabaseService().getEvents().listen((eventList) {
      final Map<DateTime, List<EventModel>> data = {};
      for (var event in eventList) {
        final day = DateTime(event.date.year, event.date.month, event.date.day);
        data.putIfAbsent(day, () => []);
        data[day]!.add(event);
      }
      setState(() => _events = data);
    });
  }

  List<EventModel> _getEvents(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFFFF6B6B);
      case 'personal':
        return const Color(0xFF4ECDC4);
      case 'social':
        return const Color(0xFFFFD93D);
      default:
        return const Color(0xFF6C5CE7);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.business;
      case 'personal':
        return Icons.person;
      case 'social':
        return Icons.group;
      default:
        return Icons.event;
    }
  }

  int _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference;
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    final User? user = FirebaseAuth.instance.currentUser;
    final displayDay = _selectedDay ?? _focusedDay;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddEventScreen());
        },
        backgroundColor: oceanBlueColor,
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER SECTION
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
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
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your Events",
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy')
                                  .format(DateTime.now()),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // CALENDAR TOGGLE BUTTON
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCalendar = !_showCalendar;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [skyBlueColor, lightCyanColor.withOpacity(0.5)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: lightCyanColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: oceanBlueColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _showCalendar ? "Hide Calendar" : "Show Calendar",
                              style: TextStyle(
                                color: oceanBlueColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _showCalendar
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: oceanBlueColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // CALENDAR SECTION (Expandable)
            if (_showCalendar)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: lightCyanColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: oceanBlueColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TableCalendar<EventModel>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2035, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        eventLoader: _getEvents,
                        calendarFormat: CalendarFormat.month,
                        onFormatChanged: (format) {},
                        onPageChanged: (focusedDay) {
                          setState(() => _focusedDay = focusedDay);
                        },
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: oceanBlueColor,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: oceanBlueColor,
                          ),
                          titleTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBlueColor,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: skyBlueColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: darkBlueColor,
                          ),
                          weekendStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF6B6B),
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: skyBlueColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: oceanBlueColor,
                              width: 2,
                            ),
                          ),
                          selectedDecoration: BoxDecoration(
                            color: oceanBlueColor,
                            shape: BoxShape.circle,
                          ),
                          defaultDecoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          weekendDecoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: cyanColor,
                            shape: BoxShape.circle,
                          ),
                          outsideDecoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          cellMargin: const EdgeInsets.all(8),
                          cellPadding: const EdgeInsets.all(6),
                          markersMaxCount: 3,
                          markersAlignment: Alignment.bottomCenter,
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

            // EVENTS LABEL
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDay != null
                          ? "Events for ${DateFormat('MMM d, yyyy').format(_selectedDay!)}"
                          : "Upcoming Events",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlueColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // EVENTS LIST SECTION
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: StreamBuilder<List<EventModel>>(
                stream: dbService.getEvents(),
                builder: (context, snapshot) {
                  // Loading State
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: Center(
                        child:
                            CircularProgressIndicator(color: oceanBlueColor),
                      ),
                    );
                  }

                  // Error State
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Error loading events",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Get filtered events based on selected day
                  List<EventModel> filteredEvents = snapshot.data ?? [];

                  if (_selectedDay != null) {
                    filteredEvents =
                        _getEvents(_selectedDay!); // Only events for selected day
                  } else {
                    // Show all upcoming events
                    filteredEvents.sort((a, b) => a.date.compareTo(b.date));
                  }

                  // Empty State
                  if (filteredEvents.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: skyBlueColor,
                                  ),
                                  child: Icon(
                                    Icons.event_busy,
                                    size: 60,
                                    color: oceanBlueColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _selectedDay != null
                                      ? "No events on this date"
                                      : "No events yet",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkBlueColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Create your first event to get started!",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: oceanBlueColor.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Get.to(() => const AddEventScreen());
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text("Create Event"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: oceanBlueColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // Data Loaded State
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final event = filteredEvents[index];
                      final daysUntil = _getDaysUntil(event.date);
                      final isToday = daysUntil == 0;
                      final isTomorrow = daysUntil == 1;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              () => EventDetailsScreen(event: event),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  skyBlueColor.withOpacity(0.3),
                                ],
                              ),
                              border: Border.all(
                                color: lightCyanColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: oceanBlueColor.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Category & Days Until
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Category Chip
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(
                                            event.category,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _getCategoryColor(
                                                event.category,
                                              ).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getCategoryIcon(
                                                event.category,
                                              ),
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              event.category,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Days Until Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? const Color(0xFFFF6B6B)
                                                  .withOpacity(0.2)
                                              : isTomorrow
                                                  ? const Color(0xFFFFD93D)
                                                      .withOpacity(0.2)
                                                  : skyBlueColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isToday
                                                ? const Color(0xFFFF6B6B)
                                                : isTomorrow
                                                    ? const Color(0xFFFFD93D)
                                                    : lightCyanColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          isToday
                                              ? "🔥 Today"
                                              : isTomorrow
                                                  ? "📅 Tomorrow"
                                                  : "$daysUntil days",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isToday
                                                ? const Color(0xFFFF6B6B)
                                                : isTomorrow
                                                    ? const Color(0xFFFFD93D)
                                                    : oceanBlueColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Event Title
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2024),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 10),

                                  // Date, Time & Notification Row
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: skyBlueColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: oceanBlueColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatDate(event.date),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              _formatTime(event.date),
                                              style: TextStyle(
                                                color: oceanBlueColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Notification Icon
                                      if (event.reminderSettings.values.any(
                                        (v) => v,
                                      ))
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFD93D)
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.notifications_active,
                                            size: 16,
                                            color: Color(0xFFFFD93D),
                                          ),
                                        ),
                                    ],
                                  ),

                                  // Description Preview (if exists)
                                  if (event.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        event.description,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: filteredEvents.length),
                  );
                },
              ),
            ),

            const SliverPadding(
              padding: EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
      ),
    );
  }
}