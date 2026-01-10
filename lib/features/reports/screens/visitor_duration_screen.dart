
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
      drawer: const CustomDrawer(currentRoute: 'Visitor Duration'),
      appBar: AppBar(
        title: const Text(
          'Vehicle Monitoring',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.gradientStart,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
        ),
         actions: [
          TextButton.icon(
             onPressed: () {},
             icon: const Icon(Icons.person, color: Colors.white),
             label: const Text('System Administrator', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Header
             const Text(
              'Visitor Vehicle Stay Report',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
             ),
             const SizedBox(height: 24),
             
             // Filters & Buttons
             Wrap(
                 spacing: 24,
                 runSpacing: 16,
                 crossAxisAlignment: WrapCrossAlignment.end,
                 children: [
                     _buildDatePicker('From Date', _fromDate, true),
                     _buildDatePicker('To Date', _toDate, false),
                     
                     ElevatedButton(
                         onPressed: _filterLogs,
                         style: ElevatedButton.styleFrom(
                             backgroundColor: const Color(0xFF1976D2),
                             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         ),
                         child: const Text('Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                     ),
                     
                     ElevatedButton(
                         onPressed: _exportExcel,
                         style: ElevatedButton.styleFrom(
                             backgroundColor: const Color(0xFF2E7D32), // Excel Green
                             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         ),
                         child: const Text('Export XL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                     ),
                     
                     ElevatedButton(
                         onPressed: _exportPdf,
                         style: ElevatedButton.styleFrom(
                             backgroundColor: const Color(0xFF546E7A), // Grey-ish
                             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         ),
                         child: const Text('Print', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                     ),
                 ],
             ),
             
             const SizedBox(height: 24),
             
             // Data Table
             Container(
               width: double.infinity,
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(8),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.05),
                     blurRadius: 10,
                   ),
                 ],
               ),
               child: SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child: DataTable(
                   columnSpacing: 30,
                   columns: const [
                       DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                       DataColumn(label: Text('Vehicle Number', style: TextStyle(fontWeight: FontWeight.bold))),
                       DataColumn(label: Text('FastTag', style: TextStyle(fontWeight: FontWeight.bold))),
                       DataColumn(label: Text('Entry Time', style: TextStyle(fontWeight: FontWeight.bold))),
                       DataColumn(label: Text('Exit Time', style: TextStyle(fontWeight: FontWeight.bold))),
                       DataColumn(label: Text('Stay Duration', style: TextStyle(fontWeight: FontWeight.bold))),
                   ],
                   rows: _filteredLogs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final log = entry.value;
                      final entryTimeStr = DateFormat('dd-MM-yyyy HH:mm').format(log.entryTime);
                      final exitTimeStr = log.exitTime != null 
                          ? DateFormat('dd-MM-yyyy HH:mm').format(log.exitTime!) 
                          : 'Still Inside';
                      
                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(log.vehicleNumber)),
                          DataCell(Text(log.fastTagId)),
                          DataCell(Text(entryTimeStr)),
                          DataCell(Text(exitTimeStr)),
                          DataCell(
                            log.exitTime != null 
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2), // Blue background
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    log.duration,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : const Text('-'),
                          ),
                        ],
                      );
                   }).toList(),
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, bool isFrom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isFrom),
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? DateFormat('dd-MM-yyyy').format(date) : 'dd-mm-yyyy',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
