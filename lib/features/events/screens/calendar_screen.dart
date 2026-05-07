import 'package:event_reminder_app/features/events/screens/event_details_screen.dart';
import 'package:event_reminder_app/features/events/screens/home_screen.dart';
import 'package:event_reminder_app/style.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/event_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _currentIndex = 1;

  Map<DateTime, List<EventModel>> _events = {};
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 120,
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Calendar View",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_focusedDay),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Calendar
          SliverPadding(
            padding: const EdgeInsets.all(16),
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

          // Events Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Events for ${DateFormat('MMM d, yyyy').format(_selectedDay ?? _focusedDay)}",
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

          // Events List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _getEvents(_selectedDay ?? _focusedDay).isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: skyBlueColor,
                            ),
                            child: Icon(
                              Icons.event_busy,
                              size: 50,
                              color: oceanBlueColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No events scheduled",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event =
                            _getEvents(_selectedDay ?? _focusedDay)[index];

                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => EventDetailsScreen(event: event),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: lightCyanColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: oceanBlueColor.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Category Indicator
                                Container(
                                  width: 5,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(event.category),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Event Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              event.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: darkBlueColor,
                                                decoration: event.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (event.isCompleted)
                                            Icon(
                                              Icons.check_circle,
                                              size: 18,
                                              color: Colors.green,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getCategoryColor(
                                                      event.category)
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              event.category,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _getCategoryColor(
                                                  event.category,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: oceanBlueColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('hh:mm a')
                                                .format(event.date),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Right Arrow
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount:
                          _getEvents(_selectedDay ?? _focusedDay).length,
                    ),
                  ),
          ),

          const SliverPadding(
            padding: EdgeInsets.only(bottom: 20),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: oceanBlueColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);

          if (index == 0) Get.offAll(() => const HomeScreen());
          if (index == 1) {} // Stay on calendar
          if (index == 2) Get.offNamed('/settings');
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}