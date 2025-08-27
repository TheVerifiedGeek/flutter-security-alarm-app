import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../dao/log_dao.dart';

class PDFService {
  final _dao = LogDao();

  Future<Uint8List> branchReport(String branch, DateTime from, DateTime to) async {
    final logs = await _dao.list(branch: branch, from: from, to: to);
    final df = DateFormat('y-MM-dd HH:mm');
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => [
        pw.Text('SaccoSecure Branch Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text('Branch: $branch'),
        pw.Text('Period: ${df.format(from)} — ${df.format(to)}'),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: const ['Time', 'Type', 'Status', 'Compliance'],
          data: logs.map((e) => [df.format(e.timestamp), e.type.name, e.status, e.compliance]).toList(),
        )
      ],
    ));

    return pdf.save();
  }
}