
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

  // Filter States
  final List<String> _gateTypes = ['Entry', 'Exit', 'Parking', 'Summary'];
  final List<String> _vehicleTypes = ['2-Wheeler', '4-Wheeler'];
  
  List<String> _selectedGateTypes = [];
  List<String> _selectedVehicleTypes = [];

  // Mock Data
  final List<MovementLog> _allLogs = [
    MovementLog(
      dateTime: DateTime(2026, 1, 4, 22, 14, 44),
      vehicleNumber: 'AP10FH9786',
      fastTagId: 'FT1999670874',
      type: 'ENTRY',
      status: 'Authorized',
      vehicleType: '4-Wheeler',
    ),
    MovementLog(
      dateTime: DateTime(2026, 1, 4, 19, 53, 30),
      vehicleNumber: 'AP10FH2624',
      fastTagId: 'FT0644177210',
      type: 'EXIT',
      status: 'Authorized',
      vehicleType: '4-Wheeler',
    ),
    MovementLog(
      dateTime: DateTime(2026, 1, 4, 18, 20, 10),
      vehicleNumber: 'AP10FH2724',
      fastTagId: 'FT1479878430',
      type: 'ENTRY',
      status: 'Authorized',
      vehicleType: '4-Wheeler',
    ),
    MovementLog(
      dateTime: DateTime(2026, 1, 3, 14, 10, 05),
      vehicleNumber: 'TS08UB1234',
      fastTagId: 'FT9988776655',
      type: 'ENTRY',
      status: 'Authorized',
      vehicleType: '2-Wheeler',
    ),
    MovementLog(
      dateTime: DateTime(2026, 1, 3, 10, 00, 00),
      vehicleNumber: 'MH02AB9988',
      fastTagId: 'FT1122334455',
      type: 'EXIT',
      status: 'Unauthorized',
      vehicleType: '4-Wheeler',
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
        // Date Logic
        bool dateInRange = true;
        if (_fromDate != null) {
          dateInRange = dateInRange && log.dateTime.isAfter(_fromDate!.subtract(const Duration(days: 1)));
        }
        if (_toDate != null) {
          dateInRange = dateInRange && log.dateTime.isBefore(_toDate!.add(const Duration(days: 1)));
        }
        
        // Search Logic
        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          matchesSearch = log.vehicleNumber.toLowerCase().contains(query) ||
                          log.fastTagId.toLowerCase().contains(query);
        }

        // Gate Type Logic
        bool matchesGateType = true;
        if (_selectedGateTypes.isNotEmpty) {
           matchesGateType = _selectedGateTypes.any((type) => type.toUpperCase() == log.type.toUpperCase());
        }

        // Vehicle Type Logic
        bool matchesVehicleType = true;
        if (_selectedVehicleTypes.isNotEmpty) {
          matchesVehicleType = _selectedVehicleTypes.contains(log.vehicleType);
        }

        return dateInRange && matchesSearch && matchesGateType && matchesVehicleType;
      }).toList();
    });
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.filter_alt, color: Color(0xFF009688)),
                  ),
                  const SizedBox(width: 12),
                  const Text('Filter Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDateBox(context, 'From', _fromDate, (date) {
                          setDialogState(() => _fromDate = date);
                          setState(() {});
                        })),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDateBox(context, 'To', _toDate, (date) {
                          setDialogState(() => _toDate = date);
                          setState(() {});
                        })),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Gate Type
                    Row(
                      children: [
                        const Icon(Icons.door_sliding, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text('Gate Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _gateTypes.map((type) {
                        final isSelected = _selectedGateTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                _selectedGateTypes.add(type);
                              } else {
                                _selectedGateTypes.remove(type);
                              }
                            });
                          },
                          backgroundColor: Colors.grey.shade50,
                          selectedColor: const Color(0xFF4CAF50), // Green selection
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          checkmarkColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : Colors.grey.shade300,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Vehicle Type
                     Row(
                      children: [
                        const Icon(Icons.directions_car, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text('Vehicle Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _vehicleTypes.map((type) {
                        final isSelected = _selectedVehicleTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                _selectedVehicleTypes.add(type);
                              } else {
                                _selectedVehicleTypes.remove(type);
                              }
                            });
                          },
                          backgroundColor: Colors.grey.shade50,
                          selectedColor: const Color(0xFF4CAF50),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                             fontSize: 13,
                          ),
                          checkmarkColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : Colors.grey.shade300,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                             _selectedGateTypes.clear();
                             _selectedVehicleTypes.clear();
                             _fromDate = null;
                             _toDate = null;
                             _filterLogs();
                          });
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 14),
                           foregroundColor: Colors.grey.shade700,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Reset Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                           _filterLogs();
                           Navigator.pop(context);
                        },
                         style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF009688), // Teal Apply
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text('Apply Details', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateBox(BuildContext context, String hint, DateTime? date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
           context: context,
           initialDate: date ?? DateTime.now(),
           firstDate: DateTime(2020),
           lastDate: DateTime(2030),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
           color: date != null ? const Color(0xFFE0F2F1) : Colors.grey.shade50,
           border: Border.all(color: date != null ? const Color(0xFF009688) : Colors.grey.shade300),
           borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Expanded(
                child: Text(
                   date != null ? DateFormat('dd-MM-yyyy').format(date) : hint,
                   style: TextStyle(
                      color: date != null ? const Color(0xFF00796B) : Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                   ),
                   overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.calendar_today_outlined, size: 18, color: date != null ? const Color(0xFF00796B) : Colors.grey.shade500),
           ],
        ),
      ),
    );
  }

  
  // CSV/Excel Export
  Future<void> _exportExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    
    // Headers
    List<String> headers = ['#', 'Date & Time', 'Vehicle Number', 'Vehicle Type', 'FastTag ID', 'Gate', 'Status'];
    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());
    
    // Data
    for (var i = 0; i < _filteredLogs.length; i++) {
        final log = _filteredLogs[i];
        final formattedDate = DateFormat('dd-MM-yyyy\nHH:mm:ss').format(log.dateTime);
        sheetObject.appendRow([
            IntCellValue(i + 1),
            TextCellValue(formattedDate),
            TextCellValue(log.vehicleNumber),
            TextCellValue(log.vehicleType),
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
                headers: ['#', 'Date & Time', 'Vehicle Number', 'Vehicle Type', 'Gate', 'Status'],
                data: _filteredLogs.asMap().entries.map((entry) {
                   final log = entry.value;
                   return [
                     (entry.key + 1).toString(),
                     DateFormat('dd-MM-yyyy HH:mm:ss').format(log.dateTime),
                     log.vehicleNumber,
                     log.vehicleType,
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
      appBar: AppBar(
        title: const Text(
          'Movement Reports',
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
                                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                                 maxLines: 2,
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
             
             // Action Buttons
             Card(
                 elevation: 0,
                 color: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 child: Padding(
                     padding: const EdgeInsets.all(20.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Row(
                           children: [
                             Expanded(
                               child: ElevatedButton.icon(
                                 onPressed: _openFilterDialog,
                                 icon: const Icon(Icons.filter_list, color: Colors.white, size: 20),
                                 label: const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                                 icon: const Icon(Icons.table_chart, color: Colors.white, size: 20),
                                 label: const Text('XL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                          SizedBox(
                            width: 150,
                            child: ElevatedButton.icon(
                                 onPressed: _exportPdf,
                                 icon: const Icon(Icons.print, color: Colors.white, size: 20),
                                 label: const Text('Print', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: const Color(0xFFE53935), // Red
                                   foregroundColor: Colors.white,
                                   padding: const EdgeInsets.symmetric(vertical: 16),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                   elevation: 0,
                                 ),
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
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                             // Table Header Tools
                             Row(
                                 children: [
                                     Container(
                                       padding: const EdgeInsets.all(8),
                                       decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                       child: const Icon(Icons.table_chart_outlined, size: 20, color: Colors.blue),
                                     ),
                                     const SizedBox(width: 12),
                                     const Text(
                                         'Detailed Log Report',
                                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                     ),
                                 ],
                             ),
                             const SizedBox(height: 16),
                             Container(
                                height: 45,
                                decoration: BoxDecoration(
                                    color: AppColors.inputBackground, // Light grey input
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: TextField(
                                   controller: _searchController,
                                   onChanged: (val) => _filterLogs(),
                                    decoration: const InputDecoration(
                                        hintText: 'Search Vehicle No or FastTag...',
                                        prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                ),
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
                                     child: ConstrainedBox(
                                       constraints: const BoxConstraints(minWidth: 800),
                                       child: DataTable(
                                           headingRowColor: MaterialStateProperty.all(Colors.transparent),
                                           columnSpacing: 20,
                                           horizontalMargin: 12,
                                           columns: const [
                                               DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                                               DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold))),
                                               DataColumn(label: Text('Vehicle No', style: TextStyle(fontWeight: FontWeight.bold))),
                                               DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                               DataColumn(label: Text('FastTag ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                               DataColumn(label: Text('Gate', style: TextStyle(fontWeight: FontWeight.bold))),
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
                                                                  Icon(
                                                                    log.vehicleType == '2-Wheeler' ? Icons.two_wheeler : Icons.directions_car, 
                                                                    size: 16, 
                                                                    color: Colors.blue
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  Text(log.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                              ],
                                                          )
                                                      ),
                                                       DataCell(Text(log.vehicleType)),
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


  Widget _buildTypeBadge(String type) {
    bool isEntry = type.toUpperCase() == 'ENTRY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isEntry ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD), // Light Green / Light Blue
        border: Border.all(color: isEntry ? const Color(0xFF4CAF50) : const Color(0xFF2196F3), width: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(isEntry ? Icons.login : Icons.logout, size: 12, color: isEntry ? const Color(0xFF2E7D32) : const Color(0xFF1565C0)),
           const SizedBox(width: 4),
           Text(type, style: TextStyle(color: isEntry ? const Color(0xFF2E7D32) : const Color(0xFF1565C0), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
     bool isAuth = status == 'Authorized';
     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAuth ? const Color(0xFFF1F8E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status, style: TextStyle(color: isAuth ? const Color(0xFF33691E) : const Color(0xFFB71C1C), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
