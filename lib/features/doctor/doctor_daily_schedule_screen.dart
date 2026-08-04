import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/routes.dart';

class DoctorDailyScheduleScreen extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> rawData;

  const DoctorDailyScheduleScreen({
    super.key,
    required this.date,
    required this.rawData,
  });

  String _formatTime(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour > 12) return '${hour - 12} PM';
    return '$hour AM';
  }

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('E').format(date).toUpperCase();
    final dayNumber = DateFormat('d').format(date);

    // Pre-calculate overlapping events
    final List<Map<String, dynamic>> processedEvents = rawData.map((e) {
      final timeStr = e['time'] as String;
      final parts = timeStr.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final top = (hour * 60) + minute.toDouble();
      return {
        'data': e,
        'top': top,
        'bottom': top + 50.0,
        'colIndex': 0,
        'maxCols': 1,
      };
    }).toList();

    processedEvents.sort((a, b) => (a['top'] as double).compareTo(b['top'] as double));

    List<List<Map<String, dynamic>>> columns = [];
    double lastEventEnding = 0;

    for (var event in processedEvents) {
      final top = event['top'] as double;
      if (top >= lastEventEnding) {
        for (var col in columns) {
          for (var e in col) {
            e['maxCols'] = columns.length;
          }
        }
        columns = [];
        lastEventEnding = 0;
      }

      bool placed = false;
      for (int i = 0; i < columns.length; i++) {
        final col = columns[i];
        final lastInCol = col.last;
        if ((lastInCol['bottom'] as double) <= top) {
          col.add(event);
          event['colIndex'] = i;
          placed = true;
          break;
        }
      }

      if (!placed) {
        event['colIndex'] = columns.length;
        columns.add([event]);
      }

      if ((event['bottom'] as double) > lastEventEnding) {
        lastEventEnding = event['bottom'] as double;
      }
    }

    for (var col in columns) {
      for (var e in col) {
        e['maxCols'] = columns.length;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
        title: const Text('Jadwal Harian', style: TextStyle(color: Color(0xFF0F2646))),
      ),
      body: Column(
        children: [
          // Header showing Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE0E5EC))),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Text('GMT+07', style: TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(dayName, style: const TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
                    const SizedBox(height: 4),
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0F2646), width: 1.5),
                      ),
                      child: Text(
                        dayNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Timeline
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double timelineWidth = constraints.maxWidth - 80 - 16;
                return SingleChildScrollView(
                  child: Stack(
                children: [
                  // Background grid
                  Column(
                    children: List.generate(24, (index) {
                      return SizedBox(
                        height: 60,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                _formatTime(index),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0F2646),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFFE0E5EC)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  // Events
                  ...processedEvents.map((eventData) {
                    final event = eventData['data'] as Map<String, dynamic>;
                    final top = eventData['top'] as double;
                    final colIndex = eventData['colIndex'] as int;
                    final maxCols = eventData['maxCols'] as int;

                    final double eventWidth = timelineWidth / maxCols;
                    final double left = 80.0 + (colIndex * eventWidth);
                    
                    final isBooked = event['pet'] != 'Tersedia';
                    final st = (event['status'] as String?)?.toLowerCase() ?? '';
                    final isCompleted = isBooked && (st == 'selesai' || st == 'finished' || st == 'completed');

                    final baseColor = (event['type'] as String).contains('Konsultasi') ? Colors.blue : Colors.orange;
                    final color = isBooked ? Colors.green : baseColor;
                    final textColor = isBooked ? const Color(0xFF1B5E20) : color.shade800;

                    return Positioned(
                      top: top,
                      left: left,
                      width: eventWidth,
                      height: 50, // default event block height (50 mins)
                      child: InkWell(
                        onTap: () {
                          if ((event['status'] as String).toLowerCase() == 'berlangsung') {
                            Navigator.pushNamed(context, AppRoutes.consultationRoom, arguments: {
                              'consultation_id': 1,
                              'chat_title': event['pet'] as String,
                              'chat_subtitle': event['breed'] as String,
                            });
                          } else {
                            final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                            Navigator.pushNamed(context, AppRoutes.doctorAppointmentDetail, arguments: {
                              'date': dateString,
                              'event': event,
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(left: BorderSide(color: color, width: 4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${event['time']} - ${event['pet']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCompleted)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(Icons.check_circle, size: 14, color: textColor),
                                    ),
                                ],
                              ),
                              Text(
                                event['type'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  // Extra padding at bottom
                  const SizedBox(height: 60 * 24),
                ],
              ),
            );
          }),
          ),
        ],
      ),
    );
  }
}
