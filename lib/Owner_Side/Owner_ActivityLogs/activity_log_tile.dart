// ignore_for_file: sort_child_properties_last, must_be_immutable

import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ActivityLogs/activity_log_date.dart';

class HistoryTile extends StatelessWidget {
  final String dateName;
  final String dateYear;
  final String scbId;
  final List<Map<String, dynamic>>? eventData;

  HistoryTile({
    super.key,
    required this.dateName,
    required this.dateYear,
    this.scbId = '',
    this.eventData,
  });

  List<Map<String, dynamic>> eventEveryday = [
    {
      'date': '30',
      'day': 'SAT',
      'activities': [
        {
          'activity': 'Logged In',
          'person': 'John Wassowski',
          'time': '9:00 PM',
        },
        {
          'activity': 'Updated the Alarm',
          'person': 'Sarah Burn',
          'time': '7:30 PM',
        },
        {
          'activity': 'Updated Voltage Settings',
          'person': 'Mike Tyson',
          'time': '5:00 PM',
        },
        {'activity': 'Logged In', 'person': 'Emma Watson', 'time': '6:15 PM'},
        {
          'activity': 'Turned Off the CB',
          'person': 'Liam Bossings',
          'time': '3:45 PM',
        },
      ],
    },
    {
      'date': '21',
      'day': 'THU',
      'activities': [
        {'activity': 'Logged In', 'person': 'Emma Watson', 'time': '6:15 PM'},
        {
          'activity': 'Turned Off the CB',
          'person': 'Liam Bossings',
          'time': '3:45 PM',
        },
        {
          'activity': 'Logged In',
          'person': 'John Wassowski',
          'time': '9:00 PM',
        },
        {
          'activity': 'Updated the Alarm',
          'person': 'Sarah Burn',
          'time': '7:30 PM',
        },
        {
          'activity': 'Updated Voltage Settings',
          'person': 'Mike Tyson',
          'time': '5:00 PM',
        },
        {'activity': 'Logged In', 'person': 'Sophia Pablo', 'time': '2:00 PM'},
        {
          'activity': 'Turned On the CB',
          'person': 'Noah Sarks',
          'time': '10:30 AM',
        },
      ],
    },
    {
      'date': '02',
      'day': 'MON',
      'activities': [
        {'activity': 'Logged In', 'person': 'Sophia Pablo', 'time': '2:00 PM'},
        {
          'activity': 'Turned On the CB',
          'person': 'Noah Sarks',
          'time': '10:30 AM',
        },
        {
          'activity': 'Logged In',
          'person': 'John Wassowski',
          'time': '9:00 PM',
        },
        {
          'activity': 'Updated the Alarm',
          'person': 'Sarah Burn',
          'time': '7:30 PM',
        },
        {
          'activity': 'Updated Voltage Settings',
          'person': 'Mike Tyson',
          'time': '5:00 PM',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // DATE NAME (eg. December 2024)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$dateName $dateYear',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Days
                Column(
                  children: (eventData ?? eventEveryday).map((event) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 8.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryDate(
                                  dateMonth: dateName,
                                  dateDay: event['date'],
                                  dateYear: dateYear,
                                  day: event['day'],
                                  scbId: scbId,
                                  activities: event['activities'] != null
                                      ? List<Map<String, dynamic>>.from(
                                          event['activities'])
                                      : null,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Date and Day
                              Container(
                                width: 100,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['date'] ?? '',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0,
                                      ),
                                      child: Text(
                                        '|',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      event['day'] ?? '',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A4A4A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Activities
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    (event['activities'] as List)
                                        .map(
                                          (a) =>
                                              '${a['person']} ${a['activity']}',
                                        )
                                        .join(', '),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                  ),
                                ),
                              ),

                              // Arrow Icon
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 15,
                                color: Color(0xFF4A4A4A),
                              ),
                            ],
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.25,
                            ), // Shadow color
                            offset: Offset(0, 4), // Shadow position
                            blurRadius: 2, // Blur effect
                            spreadRadius: 0, // Spread effect
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          ),
        ),
      ),
    );
  }
}
