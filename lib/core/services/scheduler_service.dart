import 'package:workmanager/workmanager.dart';
import '../dao/log_dao.dart';
import '../services/notification_service.dart';

const _taskId = 'daily_trouble_summary';

class SchedulerService {
  static Future<void> init() async {
    // Removed deprecated isInDebugMode
    await Workmanager().initialize(_callbackDispatcher);
    await scheduleDaily0730();
  }

  static Future<void> scheduleDaily0730() async {
    await Workmanager().registerPeriodicTask(
      _taskId,
      _taskId,
      frequency: const Duration(hours: 24),
      initialDelay: _next0730Delay(),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }

  static Duration _next0730Delay() {
    final now = DateTime.now();
    DateTime target = DateTime(now.year, now.month, now.day, 7, 30);
    if (now.isAfter(target)) target = target.add(const Duration(days: 1));
    return target.difference(now);
  }
}

void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskId) {
      final logDao = LogDao();
      final today = DateTime.now();
      final troubles = await logDao.yesterdayTroubles(today);
      if (troubles.isEmpty) {
        await NotificationService.show(
          id: 730,
          title: 'Daily Summary',
          body: 'All OK yesterday.',
        );
      } else {
        final lines = troubles
            .map((e) =>
                '- ${e.branch}: ${e.status} (${e.compliance}) @ ${e.timestamp.toLocal()}')
            .join('\n');

        await NotificationService.show(
          id: 731,
          title: 'Daily Trouble Summary',
          body: lines,
        );
      }
    }
    return Future.value(true);
  });
}
