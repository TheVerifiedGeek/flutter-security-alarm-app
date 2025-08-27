import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/dao/log_dao.dart';
import '../../core/models/log.dart';
import '../../core/services/sms_parser.dart';
import '../../core/services/notification_service.dart';
import '../widgets/alert_banner.dart';
import 'logs_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dao = LogDao();
  final _sms = SMSIngestor();
  final df = DateFormat('y-MM-dd HH:mm');
  List<LogEntry> latest = [];

  @override
  void initState() {
    super.initState();
    _sms.start();
    _refresh();
  }

  Future<void> _refresh() async {
    // For demo, just pull last 20 logs
    final logs = await _dao.list();
    setState(() => latest = logs.take(20).toList());
    // Trigger UI notifications for critical events
    for (final e in latest.where((e) => e.type == LogType.alarm || e.type == LogType.tamper)) {
      await NotificationService.show(id: e.id ?? e.timestamp.millisecondsSinceEpoch, title: 'Critical: ${e.type.name.toUpperCase()}', body: '${e.branch} • ${e.status} @ ${df.format(e.timestamp)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SaccoSecure Dashboard'), actions: [
        IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: const Icon(Icons.settings))
      ]),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AlertBanner(text: 'Designed by – GeekPoint Tech Solutions', color: Colors.indigo),
            const SizedBox(height: 16),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _statCard('Latest Logs', latest.length.toString(), Icons.list_alt),
              _statCard('Critical Today', latest.where((e) => e.compliance == 'Trouble').length.toString(), Icons.warning_amber),
              _statCard('Late Today', latest.where((e) => e.compliance == 'Late').length.toString(), Icons.schedule),
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogsScreen())), child: const Text('View all')),
            ]),
            const SizedBox(height: 8),
            ...latest.map((e) => Card(
              child: ListTile(
                leading: Icon(_iconFor(e.type), color: _colorFor(e.compliance)),
                title: Text('${e.branch} • ${e.type.name} • ${e.status}'),
                subtitle: Text('${df.format(e.timestamp)} • ${e.compliance}'),
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refresh,
        label: const Text('Sync'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  IconData _iconFor(LogType t) {
    switch (t) {
      case LogType.system: return Icons.lock_outline;
 case LogType.strongRoom: return Icons.safety_check;
      case LogType.alarm: return Icons.notifications_active_rounded;
      case LogType.tamper: return Icons.build_circle_outlined;
      case LogType.police:
      case LogType.gsm: return Icons.policy_outlined;
    }
  }

  Color _colorFor(String compliance) {
    switch (compliance) {
      case 'OK': return Colors.green;
      case 'Late': return Colors.orange;
      case 'Trouble': return Colors.red;
      default: return Colors.blueGrey; // GSM Tested OK @ HH:mm, etc.
    }
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon), const SizedBox(height: 8),
 Text(title, style: Theme.of(context).textTheme.titleMedium),
 Text(value, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}