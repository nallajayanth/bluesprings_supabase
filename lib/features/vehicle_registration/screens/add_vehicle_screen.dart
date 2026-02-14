
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicleToEdit; // If null, simple Add mode

  const AddVehicleScreen({super.key, this.vehicleToEdit});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleService = VehicleService();
  bool _isLoading = false;

  // Controllers
  final _vehicleNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _flatNumberController = TextEditingController();
  final _blockNameController = TextEditingController();
  final _parkingSlotController = TextEditingController();
  final _fastTagIdController = TextEditingController();
  final _reasonController = TextEditingController();

  // Dropdowns & Checkboxes
  String? _selectedVehicleType;
  String? _selectedResidentType;
  bool _isAuthorized = false;
  bool _isBlocked = false;

  final List<String> _vehicleTypes = [
    'Car', 'Motorcycle', 'SUV', 'Truck', 'Van', 'Bus', 'Other'
  ];

  final List<String> _residentTypes = [
    'Owner', 'Tenant', 'Visitor'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vehicleToEdit != null) {
      _loadVehicleData(widget.vehicleToEdit!);
    }
  }

  void _loadVehicleData(Vehicle vehicle) {
    _vehicleNumberController.text = vehicle.vehicleNumber;
    _ownerNameController.text = vehicle.ownerName;
    _flatNumberController.text = vehicle.flatNumber;
    _blockNameController.text = vehicle.blockName;
    _parkingSlotController.text = vehicle.parkingSlot;
    _fastTagIdController.text = vehicle.fastTagId ?? '';
    _reasonController.text = vehicle.reason ?? '';
    
    // Check if values exist in list to prevent errors if data is stale
    if (_vehicleTypes.contains(vehicle.vehicleType)) {
      _selectedVehicleType = vehicle.vehicleType;
    }
    if (_residentTypes.contains(vehicle.residentType)) {
      _selectedResidentType = vehicle.residentType;
    }

    _isAuthorized = vehicle.status == 'Authorized';
    _isBlocked = vehicle.isBlocked;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedVehicleType == null || _selectedResidentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required dropdowns')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final vehicle = Vehicle(
      id: widget.vehicleToEdit?.id,
      vehicleNumber: _vehicleNumberController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      vehicleType: _selectedVehicleType!,
      flatNumber: _flatNumberController.text.trim(),
      blockName: _blockNameController.text.trim(),
      parkingSlot: _parkingSlotController.text.trim(),
      residentType: _selectedResidentType!,
      fastTagId: _fastTagIdController.text.trim().isEmpty 
          ? null 
          : _fastTagIdController.text.trim(),
      status: _isAuthorized ? 'Authorized' : 'Unauthorized',
      isBlocked: _isBlocked,
      reason: _isBlocked ? _reasonController.text.trim() : null,
    );

    try {
      if (widget.vehicleToEdit != null) {
        await _vehicleService.updateVehicle(vehicle);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _vehicleService.addVehicle(vehicle);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle registered successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add New Vehicle',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16.0),
        //     child: OutlinedButton.icon(
        //       onPressed: () => Navigator.pop(context),
        //       icon: const Icon(Icons.arrow_back, size: 18),
        //       label: const Text('Back'), // Shortened text
        //       style: OutlinedButton.styleFrom(
        //         foregroundColor: AppColors.textSecondary,
        //         side: const BorderSide(color: AppColors.inputBorder),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check available width. If < 600, use single column for better mobile experience
          final bool isNarrow = constraints.maxWidth < 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Form Fields
                  _buildResponsiveRow(
                    isNarrow,
                    _buildTextField('Vehicle Number *', _vehicleNumberController),
                    _buildTextField('Owner Name *', _ownerNameController),
                  ),
                  const SizedBox(height: 16),
                  _buildResponsiveRow(
                    isNarrow,
                    _buildDropdown('Vehicle Type *', _vehicleTypes, _selectedVehicleType, (val) {
                      setState(() => _selectedVehicleType = val);
                    }),
                    _buildTextField('Flat/Apartment Number *', _flatNumberController),
                  ),
                  const SizedBox(height: 16),
                  _buildResponsiveRow(
                    isNarrow,
                    _buildTextField('Block Name *', _blockNameController),
                    _buildDropdown('Resident Type *', _residentTypes, _selectedResidentType, (val) {
                      setState(() => _selectedResidentType = val);
                    }),
                  ),
                  const SizedBox(height: 16),
                  _buildResponsiveRow(
                    isNarrow,
                    _buildTextField('Parking Slot *', _parkingSlotController),
                    _buildTextField('FastTag ID', _fastTagIdController, isOptional: true),
                  ),
                  const SizedBox(height: 16),
                  
                  // Checkboxes
                  _buildResponsiveRow(
                    isNarrow,
                     Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Authorization Status', style: TextStyle(fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            Checkbox(
                              value: _isAuthorized,
                              onChanged: (val) {
                                setState(() {
                                  _isAuthorized = val!;
                                  if (_isAuthorized) {
                                    _isBlocked = false;
                                  }
                                });
                              },
                              activeColor: AppColors.gradientStart,
                            ),
                            const Expanded(child: Text('Authorized Vehicle', overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Check if vehicle is authorized for entry',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Block Vehicle', style: TextStyle(fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            Checkbox(
                              value: _isBlocked,
                              onChanged: (val) {
                                setState(() {
                                  _isBlocked = val!;
                                  if (_isBlocked) {
                                    _isAuthorized = false;
                                  }
                                });
                              },
                              activeColor: Colors.red,
                            ),
                            const Expanded(child: Text('Block Vehicle', overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Check to block vehicle from entry',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reason field - only visible if blocked
                  if (_isBlocked) ...[
                    const SizedBox(height: 16),
                    _buildTextField('Reason for Blocking *', _reasonController),
                  ],
                  
                  const SizedBox(height: 40),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2), // Blue color from image
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Text(
                                'Register Vehicle',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.textSecondary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveRow(bool isNarrow, Widget child1, Widget child2) {
    if (isNarrow) {
      return Column(
        children: [
          child1,
          const SizedBox(height: 16),
          child2,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child1),
          const SizedBox(width: 16),
          Expanded(child: child2),
        ],
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isOptional = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (!isOptional && (value == null || value.isEmpty)) {
              return 'Required';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            hintText: isOptional ? 'Optional' : null, // Shortened hint
            hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          onChanged: onChanged,
          validator: (value) => value == null ? 'Required' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
          ),
          isExpanded: true, // Make dropdown content expanded
          hint: const Text('Select Type', overflow: TextOverflow.ellipsis),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
        ),
      ],
    );
  }
}
