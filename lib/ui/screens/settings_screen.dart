import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/auth_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _pdf = PDFService();
  final _df = DateFormat('y-MM-dd');
  String branch = 'OLLIN SACCO KANYAGA';
  DateTimeRange? range;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Reports')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Theme'),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: {auth.themeMode},
          onSelectionChanged: (s) => auth.setThemeMode(s.first),
        ),
        const Divider(height: 32),
        const Text('Generate PDF Report'),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Branch'),
          controller: TextEditingController(text: branch),
          onChanged: (v) => branch = v,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final r = await showDateRangePicker(context: context, firstDate: DateTime(2023), lastDate: DateTime.now());
            if (r != null) setState(() => range = r);
          },
          child: Text(range == null ? 'Pick Date Range' : '${_df.format(range!.start)} → ${_df.format(range!.end)}'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Preview PDF'),
          onPressed: () async {
            if (range == null) return;
            final bytes = await _pdf.branchReport(branch, range!.start, range!.end);
            await Printing.layoutPdf(onLayout: (_) async => bytes);
          },
        ),
        const Divider(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
          onPressed: () => auth.clearSession(),
        ),
        if (Platform.isAndroid) const SizedBox(height: 24),
        if (Platform.isAndroid) const Text('Note: SMS parsing requires Android permissions.'),
      ]),
    );
  }
}