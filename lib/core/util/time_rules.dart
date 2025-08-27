import 'package:intl/intl.dart';

class TimeRules {
  static final _fmtHm = DateFormat('HH:mm');

  // Strong Room: must be armed by 16:00 sharp, else Trouble
  static String strongRoomCompliance(DateTime ts, String status) {
    if (status.toLowerCase() != 'armed') return 'Trouble';
    final limit = DateTime(ts.year, ts.month, ts.day, 16, 0);
    return (ts.isAfter(limit)) ? 'Trouble' : 'OK';
  }

  // System/Bank: <=19:00 OK; 19:01..22:00 Late; >22:00 Trouble
  static String systemCompliance(DateTime ts, String status) {
    if (status.toLowerCase() != 'armed') return 'Trouble';
    final d = DateTime(ts.year, ts.month, ts.day);
    final okLimit = DateTime(d.year, d.month, d.day, 19, 0);
    final lateLimit = DateTime(d.year, d.month, d.day, 22, 0);
    if (!ts.isAfter(okLimit)) return 'OK';
    if (ts.isAfter(okLimit) && !ts.isAfter(lateLimit)) return 'Late';
    return 'Trouble';
  }

  // GSM Test: received -> "GSM Tested OK @ HH:mm"; missing -> "GSM Not Tested Today"
  static String gsmCompliance(DateTime? receivedAt) {
    if (receivedAt == null) return 'GSM Not Tested Today';
    return 'GSM Tested OK @ ${_fmtHm.format(receivedAt)}';
  }

  static bool isEarlyDisarm(DateTime ts) {
    final d = DateTime(ts.year, ts.month, ts.day, 6, 0);
    return ts.isBefore(d);
  }
}