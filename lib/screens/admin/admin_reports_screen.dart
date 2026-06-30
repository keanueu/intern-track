import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../services/admin_state.dart';
import '../../models/profile_model.dart';
import '../../models/dtr_model.dart';
import '../../theme/app_theme.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  ProfileModel? _selectedIntern;

  Future<void> _generatePdf(BuildContext context, ProfileModel intern) async {
    final state = context.read<AdminState>();
    final logs = state.allLogs.where((l) => l.userId == intern.id).toList();
    logs.sort((a, b) => a.timeIn.compareTo(b.timeIn));

    double totalHours = logs.fold(0.0, (sum, log) => sum + log.calculatedHours);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildPdfHeader(intern),
            pw.SizedBox(height: 24),
            _buildPdfSummary(intern, totalHours, logs.length),
            pw.SizedBox(height: 24),
            _buildPdfTable(logs),
            pw.SizedBox(height: 48),
            _buildPdfSignatures(intern),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${intern.fullName.replaceAll(' ', '_')}_DTR.pdf',
    );
  }

  pw.Widget _buildPdfHeader(ProfileModel intern) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text('DAILY TIME RECORD', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('OJT Training Program', style: const pw.TextStyle(fontSize: 16)),
        pw.SizedBox(height: 24),
      ],
    );
  }

  pw.Widget _buildPdfSummary(ProfileModel intern, double totalHours, int daysPresent) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Name: ${intern.fullName}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Department: ${intern.department.isEmpty ? "N/A" : intern.department}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Company: ${intern.company}'),
              pw.Text('Required Hours: ${intern.requiredHours}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Hours Rendered: ${totalHours.toStringAsFixed(2)}'),
              pw.Text('Total Days: $daysPresent'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTable(List<DtrLog> logs) {
    final headers = ['Date', 'Time In', 'Time Out', 'Hours'];
    final data = logs.map((log) {
      final date = DateFormat('yyyy-MM-dd').format(log.timeIn);
      final timeIn = DateFormat('hh:mm a').format(log.timeIn);
      final timeOut = log.timeOut != null ? DateFormat('hh:mm a').format(log.timeOut!) : 'Ongoing';
      final hours = log.calculatedHours.toStringAsFixed(2);
      return [date, timeIn, timeOut, hours];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
      cellAlignment: pw.Alignment.center,
    );
  }

  pw.Widget _buildPdfSignatures(ProfileModel intern) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Container(width: 150, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 8),
            pw.Text(intern.fullName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Intern Signature', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(width: 150, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 8),
            pw.Text(intern.supervisor.isEmpty ? 'Supervisor' : intern.supervisor, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Supervisor Signature', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: FadeSlideIn(
                index: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reports & Export',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kWhite,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: kRadiusCard,
                        border: Border.all(color: kBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ProfileModel>(
                          value: _selectedIntern,
                          hint: const Text('Select Intern', style: TextStyle(color: kGrey)),
                          isExpanded: true,
                          dropdownColor: kSurface,
                          icon: const Icon(AppIcons.chevronDown, color: kWhite),
                          items: state.interns.map((intern) {
                            return DropdownMenuItem(
                              value: intern,
                              child: Text(intern.fullName, style: const TextStyle(color: kWhite)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedIntern = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedIntern != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeSlideIn(
                    index: 1,
                    child: Column(
                      children: [
                        DarkCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedIntern!.fullName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kWhite),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Company: ${_selectedIntern!.company}',
                                style: const TextStyle(color: kGrey),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kGreen,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: kRadiusBtn),
                                  ),
                                  icon: const Icon(AppIcons.pdf, color: kBg),
                                  label: const Text('Generate PDF Report', style: TextStyle(color: kBg, fontWeight: FontWeight.bold)),
                                  onPressed: () => _generatePdf(context, _selectedIntern!),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'Select an intern to generate report',
                    style: TextStyle(color: kGrey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
