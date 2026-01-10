
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../home/widgets/custom_drawer.dart';
import '../models/movement_log.dart';

class MovementReportsScreen extends StatefulWidget {
  const MovementReportsScreen({super.key});

  @override
  State<MovementReportsScreen> createState() => _MovementReportsScreenState();
}

class _MovementReportsScreenState extends State<MovementReportsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _searchController = TextEditingController();

  // Mock Data
  final List<MovementLog> _allLogs = [
    MovementLog(
      dateTime: DateTime(2026, 1, 4, 22, 14, 44),
      vehicleNumber: 'AP10FH9786',
      fastTagId: 'FT1999670874',
      type: 'ENTRY',
      status: 'Authorized',
    ),
    MovementLog(
      dateTime: DateTime(2026, 1, 4, 19, 53, 30),
      vehicleNumber: 'AP10FH2624',
      fastTagId: 'FT0644177210',
      type: 'EXIT',
      status: 'Authorized',
    ),
    MovementLog(
      dateTime: DateTime(2026, 1, 4, 18, 20, 10),
      vehicleNumber: 'AP10FH2724',
      fastTagId: 'FT1479878430',
      type: 'ENTRY',
      status: 'Authorized',
    ),
    MovementLog(
      dateTime: DateTime(2026, 1, 3, 14, 10, 05),
      vehicleNumber: 'TS08UB1234',
      fastTagId: 'FT9988776655',
      type: 'ENTRY',
      status: 'Authorized',
    ),
    MovementLog(
      dateTime: DateTime(2026, 1, 3, 10, 00, 00),
      vehicleNumber: 'MH02AB9988',
      fastTagId: 'FT1122334455',
      type: 'EXIT',
      status: 'Unauthorized',
    ),
  ];

  List<MovementLog> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _filteredLogs = List.from(_allLogs);
    // Set default dates based on image "06-12-2025" to "05-01-2026"
    // But for the sake of showing data, let's keep them null or set to recent
    _fromDate = DateTime(2025, 12, 6);
    _toDate = DateTime(2026, 1, 5);
  }

  void _filterLogs() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        bool dateInRange = true;
        if (_fromDate != null) {
          dateInRange = dateInRange && log.dateTime.isAfter(_fromDate!.subtract(const Duration(days: 1)));
        }
        if (_toDate != null) {
          dateInRange = dateInRange && log.dateTime.isBefore(_toDate!.add(const Duration(days: 1)));
        }
        
        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          matchesSearch = log.vehicleNumber.toLowerCase().contains(query) ||
                          log.fastTagId.toLowerCase().contains(query);
        }

        return dateInRange && matchesSearch;
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
  
  // CSV/Excel Export
  Future<void> _exportExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    
    // Headers
    List<String> headers = ['#', 'Date & Time', 'Vehicle Number', 'FastTag ID', 'Type', 'Status'];
    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());
    
    // Data
    for (var i = 0; i < _filteredLogs.length; i++) {
        final log = _filteredLogs[i];
        final formattedDate = DateFormat('dd-MM-yyyy\nHH:mm:ss').format(log.dateTime);
        sheetObject.appendRow([
            IntCellValue(i + 1),
            TextCellValue(formattedDate),
            TextCellValue(log.vehicleNumber),
            TextCellValue(log.fastTagId),
            TextCellValue(log.type),
            TextCellValue(log.status),
        ]);
    }
    
    // Save
    try {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/MovementReport_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final file = File(path);
        // encode() returns List<int>?
        final bytes = excel.save();
        if (bytes != null) {
             await file.writeAsBytes(bytes);
             if (mounted) {
                await Share.shareXFiles([XFile(path)], text: 'Vehicle Movement Report (Excel)');
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
              child: pw.Text('Vehicle Movement Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Paragraph(text: 'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}'),
             pw.Table.fromTextArray(
                headers: ['#', 'Date & Time', 'Vehicle Number', 'FastTag ID', 'Type', 'Status'],
                data: _filteredLogs.asMap().entries.map((entry) {
                   final log = entry.value;
                   return [
                     (entry.key + 1).toString(),
                     DateFormat('dd-MM-yyyy HH:mm:ss').format(log.dateTime),
                     log.vehicleNumber,
                     log.fastTagId,
                     log.type,
                     log.status,
                   ];
                }).toList(),
             ),
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/MovementReport_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await doc.save());
    
    if (mounted) {
        await Share.shareXFiles([XFile(path)], text: 'Vehicle Movement Report (PDF)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const CustomDrawer(currentRoute: 'Movement Reports'),
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
             // Placeholder for logout
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
             const Row(
                children: [
                   Icon(Icons.description_outlined, size: 32, color: Colors.black87),
                   SizedBox(width: 12),
                   Expanded(
                     child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                             Text(
                                 'Vehicle Movement Reports',
                                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                                 overflow: TextOverflow.ellipsis,
                             ),
                             Text(
                                 'Generate and export detailed vehicle entry/exit reports',
                                 style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                 overflow: TextOverflow.ellipsis,
                             ),
                         ],
                     ),
                   ),
                ],
             ),
             const SizedBox(height: 24),
             
             // Filters Card
             Card(
                 elevation: 0,
                 color: const Color(0xFFF0FDF4), // Light greenish background
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 child: Padding(
                     padding: const EdgeInsets.all(20.0),
                     child: Wrap(
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
                             
                             ElevatedButton.icon(
                                 onPressed: _exportExcel,
                                 icon: const Icon(Icons.table_chart, color: Colors.white, size: 18),
                                 label: const Text('XL'),
                                 style: ElevatedButton.styleFrom(
                                     backgroundColor: const Color(0xFF2E7D32), // Excel Green
                                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                 ),
                             ),
                             
                             ElevatedButton.icon(
                                 onPressed: _exportPdf,
                                 icon: const Icon(Icons.print, color: Colors.white, size: 18),
                                 label: const Text('Print'),
                                 style: ElevatedButton.styleFrom(
                                     backgroundColor: const Color(0xFFD32F2F), // PDF Red
                                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                 ),
                             ),
                         ],
                     ),
                 ),
             ),
             
             const SizedBox(height: 24),
             
             // Table Card
             Card(
                 elevation: 2,
                 color: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Column(
                         children: [
                             // Table Header Tools
                             Row(
                                 children: [
                                     const Icon(Icons.table_chart_outlined, size: 20),
                                     const SizedBox(width: 8),
                                     const Flexible(
                                       child: Text(
                                           'Detailed Log Report',
                                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                           overflow: TextOverflow.ellipsis,
                                       ),
                                     ),
                                     const SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
                                           height: 40,
                                           decoration: BoxDecoration(
                                               color: AppColors.inputBackground, // Light grey input
                                               borderRadius: BorderRadius.circular(8),
                                           ),
                                           child: TextField(
                                              controller: _searchController,
                                              onChanged: (val) => _filterLogs(),
                                               decoration: const InputDecoration(
                                                   hintText: 'Search...',
                                                   prefixIcon: Icon(Icons.search, size: 20),
                                                   border: InputBorder.none,
                                                   contentPadding: EdgeInsets.symmetric(vertical: 10),
                                               ),
                                           ),
                                       ),
                                      ),
                                     const SizedBox(width: 8),
                                     IconButton(
                                         onPressed: () {},
                                         icon: const Icon(Icons.download, size: 20),
                                         tooltip: 'Export Options',
                                         style: IconButton.styleFrom(
                                             foregroundColor: AppColors.textSecondary,
                                         ),
                                     ),
                                 ],
                             ),
                             const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 8.0),
                                 child: Divider(),
                             ),
                             
                             // Data Table
                             SizedBox(
                                 width: double.infinity,
                                 child: SingleChildScrollView(
                                     scrollDirection: Axis.horizontal,
                                     child: DataTable(
                                         headingRowColor: MaterialStateProperty.all(Colors.transparent),
                                         columnSpacing: 30,
                                         horizontalMargin: 12,
                                         columns: const [
                                             DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                                             DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold))),
                                             DataColumn(label: Text('Vehicle Number', style: TextStyle(fontWeight: FontWeight.bold))),
                                             DataColumn(label: Text('FastTag ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                             DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                             DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                         ],
                                         rows: _filteredLogs.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final log = entry.value;
                                            return DataRow(
                                                cells: [
                                                    DataCell(Text('${index + 1}')),
                                                    DataCell(
                                                        Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                                Text(
                                                                    DateFormat('dd-MM-yyyy').format(log.dateTime),
                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                                ),
                                                                Text(
                                                                    DateFormat('HH:mm:ss').format(log.dateTime),
                                                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                                                ),
                                                            ],
                                                        )
                                                    ),
                                                    DataCell(
                                                        Row(
                                                            children: [
                                                                const Icon(Icons.directions_car, size: 16, color: Colors.blue),
                                                                const SizedBox(width: 8),
                                                                Text(log.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                            ],
                                                        )
                                                    ),
                                                    DataCell(
                                                        Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                                color: Colors.cyan,
                                                                borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Text(
                                                                log.fastTagId,
                                                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                                            ),
                                                        )
                                                    ),
                                                    DataCell(
                                                        _buildTypeBadge(log.type)
                                                    ),
                                                    DataCell(
                                                        _buildStatusBadge(log.status)
                                                    ),
                                                ]
                                            );
                                         }).toList(),
                                     ),
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

  Widget _buildDatePicker(String label, DateTime? date, bool isFrom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isFrom),
          child: Container(
            width: 150,
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

  Widget _buildTypeBadge(String type) {
    bool isEntry = type == 'ENTRY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isEntry ? const Color(0xFF43A047) : const Color(0xFF1E88E5), // Green for Entry, Blue for Exit
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(isEntry ? Icons.login : Icons.logout, size: 12, color: Colors.white),
           const SizedBox(width: 4),
           Text(type, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
     bool isAuth = status == 'Authorized';
     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isAuth ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(isAuth ? Icons.verified : Icons.block, size: 12, color: Colors.white),
           const SizedBox(width: 4),
           Text(status, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
