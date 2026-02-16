import 'package:flutter/material.dart';
import '../models/visitor_request_model.dart';
import '../../../../core/constants/app_colors.dart';

class VisitorRequestScreen extends StatefulWidget {
  final String qrData;

  const VisitorRequestScreen({super.key, required this.qrData});

  @override
  State<VisitorRequestScreen> createState() => _VisitorRequestScreenState();
}

class _VisitorRequestScreenState extends State<VisitorRequestScreen> {
  late VisitorRequest _request;
  bool _isLoading = true;
  bool _isActionTaken = false;

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
  }

  // Mocking data fetch based on QR code
  Future<void> _fetchRequestDetails() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, we'll create a dummy request irrespective of QR data
    // In a real app, widget.qrData would be the ID used to fetch data
    if (mounted) {
      setState(() {
        _request = VisitorRequest(
          id: widget.qrData,
          residentName: 'Arjun Sharma',
          block: 'A',
          flatNumber: '304',
          visitorCount: 3,
          purpose: 'Family Visit',
          vehicleNumber: 'TS07 EX 1234',
          status: 'Pending',
          timestamp: DateTime.now(),
        );
        _isLoading = false;
      });
    }
  }

  void _handleAction(bool isApproved) {
    setState(() {
      _isActionTaken = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isApproved ? 'Visitor Approved Successfully' : 'Visitor Rejected'),
        backgroundColor: isApproved ? Colors.green : Colors.red,
      ),
    );

    // Navigate back after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Visitor Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navBarBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                   // Status Banner if action taken
                   if (_isActionTaken)
                     Container(
                       width: double.infinity,
                       margin: const EdgeInsets.only(bottom: 20),
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.green.withOpacity(0.1),
                         border: Border.all(color: Colors.green),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: const Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.check_circle, color: Colors.green),
                           SizedBox(width: 8),
                           Text('Action Recorded Successfully', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ),

                  // Resident Details Card
                  _buildSectionTitle('Resident Details'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 10,
                           offset: const Offset(0, 4),
                         ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.navBarBlue,
                              radius: 24,
                              child: Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_request.residentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Resident', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem('Block', _request.block),
                            _buildCompactDivider(),
                            _buildInfoItem('Flat No', _request.flatNumber),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Visitor Details Card
                  _buildSectionTitle('Visitor Details'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 10,
                           offset: const Offset(0, 4),
                         ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.people, 'Visitors Count', '${_request.visitorCount} Persons'),
                        const SizedBox(height: 16),
                        _buildDetailRow(Icons.directions_car, 'Vehicle Number', _request.vehicleNumber),
                        const SizedBox(height: 16),
                        _buildDetailRow(Icons.info_outline, 'Purpose', _request.purpose),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  if (!_isActionTaken)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleAction(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleAction(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navBarBlue, // Matches design "purple" button often used for primary
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 2,
                            ),
                            child: const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCompactDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.navBarBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.navBarBlue, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
             const SizedBox(height: 2),
             Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        )
      ],
    );
  }
}
