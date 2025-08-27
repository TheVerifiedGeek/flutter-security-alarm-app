import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/dao/log_dao.dart';
import '../../core/models/log.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final _dao = LogDao();
  final df = DateFormat('y-MM-dd HH:mm');
  List<LogEntry> logs = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async { logs = await _dao.list(); setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Logs')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (_, i) {
            final e = logs[i];
            return ListTile(
              leading: const Icon(Icons.event_note),
              title: Text('${e.branch} — ${e.type.name} • ${e.status}'),
              subtitle: Text('${df.format(e.timestamp)} • ${e.compliance}'),
            );
          },
        ),
      ),
    );
  }
}