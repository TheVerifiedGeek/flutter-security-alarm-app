import 'package:another_telephony/telephony.dart';
import 'dart:developer' as developer;
import '../dao/log_dao.dart';
import '../models/log.dart';
import '../util/time_rules.dart';

class SMSIngestor {
  final Telephony _telephony = Telephony.instance;
  final _logDao = LogDao();

  Future<void> start() async {
    final bool? perms = await _telephony.requestPhoneAndSmsPermissions;
    if (perms != true) return;

    // 1️⃣ Ingest past SMS inbox messages
    await _ingestInbox();

    // 2️⃣ Listen for incoming SMS in real-time
    _telephony.listenIncomingSms(
      onNewMessage: (msg) {
        final body = msg.body ?? '';
        if (body.trim().isEmpty) return;
        _handle(body, DateTime.fromMillisecondsSinceEpoch(msg.date ?? DateTime.now().millisecondsSinceEpoch));
      },
      onBackgroundMessage: backgroundMessageHandler,
      listenInBackground: false,
    );
  }

  Future<void> _ingestInbox() async {
    try {
      List<SmsMessage> messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.ASC)],
      );

      for (final msg in messages) {
        final body = msg.body ?? '';
        if (body.trim().isEmpty) continue;
        final ts = DateTime.fromMillisecondsSinceEpoch(msg.date ?? DateTime.now().millisecondsSinceEpoch);
        await _handle(body, ts);
      }
    } catch (e) {
      developer.log('Error ingesting inbox SMS: $e', name: 'SMSIngestor');
    }
  }

  static backgroundMessageHandler(SmsMessage m) async {
    // Optional: implement background processing if needed
  }

  Future<void> _handle(String body, DateTime ts) async {
    final normalized = body.toUpperCase();
    String branch = _extractBranch(normalized);

    // Strong Room
    if (normalized.contains('STRONG ROOM ARMED')) {
      final comp = TimeRules.strongRoomCompliance(ts, 'armed');
      await _logDao.insert(LogEntry(
          branch: branch,
          type: LogType.strongRoom,
          status: 'armed',
          rawMessage: body,
          timestamp: ts,
          compliance: comp));
      return;
    }
    if (normalized.contains('STRONG ROOM DISARMED')) {
      await _logDao.insert(LogEntry(
          branch: branch,
          type: LogType.strongRoom,
          status: 'disarmed',
          rawMessage: body,
          timestamp: ts,
          compliance: 'Trouble'));
      return;
    }

    // System/Bank
    if (normalized.contains('SYSTEM ARMED') ||
        normalized.contains('BANK ARMED') ||
        normalized.contains('ALARM SYSTEM ARMED')) {
      final comp = TimeRules.systemCompliance(ts, 'armed');
      await _logDao.insert(LogEntry(
          branch: branch,
          type: LogType.system,
          status: 'armed',
          rawMessage: body,
          timestamp: ts,
          compliance: comp));
      return;
    }
    if (normalized.contains('SYSTEM DISARMED') ||
        normalized.contains('BANK DISARMED') ||
        normalized.contains('ALARM SYSTEM DISARMED')) {
      final early = TimeRules.isEarlyDisarm(ts);
      await _logDao.insert(LogEntry(
          branch: branch,
          type: LogType.system,
          status: 'disarmed',
          rawMessage: body,
          timestamp: ts,
          compliance: early ? 'Trouble' : 'OK'));
      return;
    }

    // Intruder / Tamper
    if (normalized.contains('INTRUDER ALARM')) {
      await _logDao.insert(LogEntry(
          branch: branch,
          type: LogType.alarm,
          status: 'intruder',
          rawMessage: body,
          timestamp: ts,
          compliance: 'Trouble'));
      return;
    }
    if (normalized.contains('BOX TAMPER') && normalized.contains('ON')) {
      await _logDao.insert(LogEntry(
          branch: branch,
          type: LogType.tamper,
          status: 'on',
          rawMessage: body,
          timestamp: ts,
          compliance: 'Trouble'));
      return;
    }
    if (normalized.contains('BOX TAMPER') && normalized.contains('RESET')) {
      await _logDao.insert(LogEntry(
          branch: branch,
          type: LogType.tamper,
          status: 'reset',
          rawMessage: body,
          timestamp: ts,
          compliance: 'OK'));
      return;
    }

    // Police / GSM periodic test
    if (normalized.contains('POLICE ACKNOWLEDGEMENT') ||
        normalized.contains('POLICE UNIT WORKING OK') ||
        normalized.contains('POLICE STATION WORKING OK') ||
        normalized.contains('SYSTEM WORKING "OK"') ||
        normalized.contains('WORKING OKAY') ||
        normalized.contains('GSM SYSTEM WORKING OK')) {
      final comp = TimeRules.gsmCompliance(ts);
      await _logDao.insert(LogEntry(
          branch: branch,
          type: LogType.gsm,
          status: 'ok',
          rawMessage: body,
          timestamp: ts,
          compliance: comp));
      return;
    }
  }

  String _extractBranch(String body) {
    final keys = [
      'OLLIN SACCO KANYAGA',
      'OLLIN SACCO KAJIADO',
      'TAIFA SACCO MWEIGA',
      'FORTUNE SACCO KIANGAI',
      'OLLIN  SACCO NAIROBI',
      'KUTUS POLICE STATION',
      'KAGUMO',
      'NAIRUTIA',
      'KILGORIS'
    ];
    for (final k in keys) {
      if (body.contains(k)) return k;
    }
    final saccoIdx = body.indexOf('SACCO');
    if (saccoIdx != -1) {
      return body.substring(saccoIdx, (saccoIdx + 40).clamp(0, body.length)).trim();
    }
    return 'UNKNOWN BRANCH';
  }
}
