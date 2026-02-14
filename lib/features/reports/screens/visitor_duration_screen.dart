
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../home/widgets/custom_drawer.dart';
import '../models/visitor_log.dart';

class VisitorDurationScreen extends StatefulWidget {
  const VisitorDurationScreen({super.key});

  @override
  State<VisitorDurationScreen> createState() => _VisitorDurationScreenState();
}

class _VisitorDurationScreenState extends State<VisitorDurationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _fromDate;
  DateTime? _toDate;

  // Mock Data
  final List<VisitorLog> _allLogs = [
    VisitorLog(
      vehicleNumber: 'TS10D8932',
      fastTagId: 'FT1234567899',
      entryTime: DateTime(2026, 1, 2, 23, 41),
      exitTime: DateTime(2026, 1, 4, 16, 17),
    ),
    VisitorLog(
      vehicleNumber: 'TS10D8933',
      fastTagId: 'FT1234567898',
      entryTime: DateTime(2026, 1, 2, 23, 17),
      exitTime: DateTime(2026, 1, 4, 16, 24),
    ),
    VisitorLog(
      vehicleNumber: 'MH01AB1234',
      fastTagId: 'FT1234567893',
      entryTime: DateTime(2025, 12, 28, 8, 49),
      exitTime: null, // Still Inside
    ),
    VisitorLog(
      vehicleNumber: 'AP09CF9999',
      fastTagId: 'FT9876543210',
      entryTime: DateTime(2026, 1, 5, 10, 00),
      exitTime: DateTime(2026, 1, 5, 12, 30),
    ),
  ];

  List<VisitorLog> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _filteredLogs = List.from(_allLogs);
    // Set default dates to cover the mock data
    _fromDate = DateTime(2025, 12, 6);
    _toDate = DateTime(2026, 1, 6);
  }

  void _filterLogs() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        bool dateInRange = true;
        if (_fromDate != null) {
          dateInRange = dateInRange && log.entryTime.isAfter(_fromDate!.subtract(const Duration(days: 1)));
        }
        if (_toDate != null) {
          dateInRange = dateInRange && log.entryTime.isBefore(_toDate!.add(const Duration(days: 1)));
        }
        return dateInRange;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  // EXCEL Export
  Future<void> _exportExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Headers
    List<String> headers = ['#', 'Vehicle Number', 'FastTag', 'Entry Time', 'Exit Time', 'Stay Duration'];
    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // Data
    for (var i = 0; i < _filteredLogs.length; i++) {
        final log = _filteredLogs[i];
        final entryTime = DateFormat('dd-MM-yyyy HH:mm').format(log.entryTime);
        final exitTime = log.exitTime != null 
            ? DateFormat('dd-MM-yyyy HH:mm').format(log.exitTime!) 
            : 'Still Inside';

        sheetObject.appendRow([
            IntCellValue(i + 1),
            TextCellValue(log.vehicleNumber),
            TextCellValue(log.fastTagId),
            TextCellValue(entryTime),
            TextCellValue(exitTime),
            TextCellValue(log.duration),
        ]);
    }

    // Save & Share
    try {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/VisitorDuration_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final file = File(path);
        
        final bytes = excel.save();
        if (bytes != null) {
             await file.writeAsBytes(bytes);
             if (mounted) {
                await Share.shareXFiles([XFile(path)], text: 'Visitor Duration Report (Excel)');
             }
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting Excel: $e')));
      }
    }
  }

  // PDF Export
  Future<void> _exportPdf() async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Visitor Vehicle Stay Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Paragraph(text: 'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}'),
             pw.Table.fromTextArray(
                headers: ['#', 'Vehicle Number', 'FastTag', 'Entry Time', 'Exit Time', 'Stay Duration'],
                data: _filteredLogs.asMap().entries.map((entry) {
                   final log = entry.value;
                   final entryTime = DateFormat('dd-MM-yyyy HH:mm').format(log.entryTime);
                   final exitTime = log.exitTime != null 
                        ? DateFormat('dd-MM-yyyy HH:mm').format(log.exitTime!) 
                        : 'Still Inside';
                   return [
                     (entry.key + 1).toString(),
                     log.vehicleNumber,
                     log.fastTagId,
                     entryTime,
                     exitTime,
                     log.duration,
                   ];
                }).toList(),
             ),
          ];
        },
      ),
    );

    // Save & Share
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/VisitorDuration_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(await doc.save());

      if (mounted) {
          await Share.shareXFiles([XFile(path)], text: 'Visitor Duration Report (PDF)');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Visitor Duration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.navBarBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Header
             Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                     child: const Icon(Icons.history_toggle_off, size: 32, color: Colors.orange),
                   ),
                   const SizedBox(width: 16),
                   const Expanded(
                     child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                             Text(
                                 'Visitor Vehicle Stay Report',
                                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                             ),
                             Text(
                                 'Track entry/exit times and stay duration of visitors',
                                 style: TextStyle(fontSize: 14, color: Colors.grey),
                             ),
                         ],
                     ),
                   ),
                ],
             ),
             const SizedBox(height: 24),
             
             // Filters & Buttons
             Card(
                 elevation: 0,
                 color: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 child: Padding(
                     padding: const EdgeInsets.all(20.0),
                     child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                             const Row(
                               children: [
                                 Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                                 SizedBox(width: 8),
                                 Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                               ],
                             ),
                             const SizedBox(height: 12),
                             Row(
                               children: [
                                 Expanded(child: _buildDateBox('From Date', _fromDate, true)),
                                 const SizedBox(width: 16),
                                 Expanded(child: _buildDateBox('To Date', _toDate, false)),
                               ],
                             ),
                             const SizedBox(height: 24),
                             
                             Row(
                               children: [
                                 Expanded(
                                   child: ElevatedButton.icon(
                                     onPressed: _filterLogs,
                                     icon: const Icon(Icons.filter_list, color: Colors.white),
                                     label: const Text('Filter Data', style: TextStyle(fontWeight: FontWeight.bold)),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: const Color(0xFF26A69A), // Teal
                                       foregroundColor: Colors.white,
                                       padding: const EdgeInsets.symmetric(vertical: 16),
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                       elevation: 0,
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 16),
                                 Expanded(
                                   child: ElevatedButton.icon(
                                     onPressed: _exportExcel,
                                     icon: const Icon(Icons.table_view, color: Colors.white),
                                     label: const Text('Export XL', style: TextStyle(fontWeight: FontWeight.bold)),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: const Color(0xFF388E3C), // Green
                                       foregroundColor: Colors.white,
                                       padding: const EdgeInsets.symmetric(vertical: 16),
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                       elevation: 0,
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                             const SizedBox(height: 16),
                             Center(
                               child: SizedBox(
                                 width: 250,
                                 child: ElevatedButton.icon(
                                     onPressed: _exportPdf,
                                     icon: const Icon(Icons.print, color: Colors.white),
                                     label: const Text('Print Report', style: TextStyle(fontWeight: FontWeight.bold)),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: const Color(0xFFE53935), // Red
                                       foregroundColor: Colors.white,
                                       padding: const EdgeInsets.symmetric(vertical: 16),
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                       elevation: 0,
                                     ),
                                 ),
                               ),
                             ),
                         ],
                     ),
                 ),
             ),
             
             const SizedBox(height: 24),
             
             // Data Table
             Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                           children: [
                               Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                                 child: const Icon(Icons.timer, size: 20, color: Colors.orange),
                               ),
                               const SizedBox(width: 12),
                               const Text(
                                   'Detailed Stay Durations',
                                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                               ),
                           ],
                       ),
                       const Divider(height: 30),
                        SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 25,
                        headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                        columns: const [
                            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Vehicle No', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('FastTag ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Entry Time', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Exit Time', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _filteredLogs.asMap().entries.map((entry) {
                           final index = entry.key;
                           final log = entry.value;
                           final entryTimeStr = DateFormat('dd-MM-yyyy\nHH:mm').format(log.entryTime);
                           final exitTimeStr = log.exitTime != null 
                               ? DateFormat('dd-MM-yyyy\nHH:mm').format(log.exitTime!) 
                               : 'Still Inside';
                           
                           return DataRow(
                             cells: [
                               DataCell(Text('${index + 1}')),
                               DataCell(Text(log.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                               DataCell(Text(log.fastTagId, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                               DataCell(Text(entryTimeStr)),
                               DataCell(
                                 log.exitTime == null 
                                 ? const Text('Still Inside', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
                                 : Text(exitTimeStr)
                               ),
                               DataCell(
                                 log.exitTime != null 
                                   ? Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                       decoration: BoxDecoration(
                                         color: Colors.blue.shade50,
                                         border: Border.all(color: Colors.blue.shade200),
                                         borderRadius: BorderRadius.circular(20),
                                       ),
                                       child: Text(
                                         log.duration,
                                         style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),
                                       ),
                                     )
                                   : const Text('-'),
                               ),
                             ],
                           );
                        }).toList(),
                      ),
                    ),
                    ],
                  ),
                ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(String label, DateTime? date, bool isFrom) {
    return InkWell(
      onTap: () => _selectDate(context, isFrom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
           color: date != null ? const Color(0xFFE0F2F1) : Colors.grey.shade50,
           border: Border.all(color: date != null ? const Color(0xFF009688) : Colors.grey.shade300),
           borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Text(
                 date != null ? DateFormat('dd-MM-yyyy').format(date) : label,
                 style: TextStyle(
                    color: date != null ? const Color(0xFF00796B) : Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                 ),
              ),
              Icon(Icons.calendar_today, size: 18, color: date != null ? const Color(0xFF00796B) : Colors.grey.shade500),
           ],
        ),
      ),
    );
  }
}
