import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/tour.dart';
import '../providers/tour_provider.dart';
import '../widgets/glass_card.dart';

class AddEditTourScreen extends StatefulWidget {
  final Tour? tour;

  const AddEditTourScreen({super.key, this.tour});

  @override
  State<AddEditTourScreen> createState() => _AddEditTourScreenState();
}

class _AddEditTourScreenState extends State<AddEditTourScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  DateTime? _startDate;
  DateTime? _endDate;
  late double _advanceCash;
  late double _miscAdvanceCash;

  @override
  void initState() {
    super.initState();
    if (widget.tour != null) {
      _title = widget.tour!.title;
      _description = widget.tour!.description;
      _startDate = widget.tour!.startDate;
      _endDate = widget.tour!.endDate;
      _advanceCash = widget.tour!.advanceCash;
      _miscAdvanceCash = widget.tour!.miscAdvanceCash;
    } else {
      _title = '';
      _description = '';
      _advanceCash = 0.0;
      _miscAdvanceCash = 0.0;
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? (_startDate ?? DateTime.now())),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3498DB),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveTour() {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      _formKey.currentState!.save();
      final provider = Provider.of<TourProvider>(context, listen: false);

      if (widget.tour == null) {
        final newTour = Tour(
          id: const Uuid().v4(),
          title: _title,
          description: _description,
          startDate: _startDate!,
          endDate: _endDate!,
          advanceCash: _advanceCash,
          miscAdvanceCash: _miscAdvanceCash,
        );
        provider.addTour(newTour);
      } else {
        final updatedTour = Tour(
          id: widget.tour!.id,
          title: _title,
          description: _description,
          startDate: _startDate!,
          endDate: _endDate!,
          advanceCash: _advanceCash,
          miscAdvanceCash: _miscAdvanceCash,
        );
        provider.updateTour(updatedTour);
      }
      Navigator.pop(context);
    } else if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates.')),
      );
    }
  }

  InputDecoration _glassInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withAlpha(25),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: Colors.white70),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isEditing = widget.tour != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tour' : 'Schedule New Tour', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          initialValue: _title,
                          style: const TextStyle(color: Colors.white),
                          decoration: _glassInputDecoration('Tour Title', Icons.business_center),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                          onSaved: (value) => _title = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _description,
                          style: const TextStyle(color: Colors.white),
                          decoration: _glassInputDecoration('Description (Optional)', Icons.description),
                          maxLines: 3,
                          onSaved: (value) => _description = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _advanceCash == 0.0 ? '' : _advanceCash.toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: _glassInputDecoration('Advance Cash (PKR)', Icons.payments),
                          validator: (value) {
                            if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onSaved: (value) => _advanceCash = value == null || value.isEmpty ? 0.0 : double.parse(value),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _miscAdvanceCash == 0.0 ? '' : _miscAdvanceCash.toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: _glassInputDecoration('Misc Advance Cash (PKR)', Icons.account_balance_wallet),
                          validator: (value) {
                            if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onSaved: (value) => _miscAdvanceCash = value == null || value.isEmpty ? 0.0 : double.parse(value),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white54),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _pickDate(context, true),
                                icon: const Icon(Icons.calendar_today),
                                label: Text(_startDate == null ? 'Start Date' : dateFormat.format(_startDate!)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white54),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _pickDate(context, false),
                                icon: const Icon(Icons.calendar_today),
                                label: Text(_endDate == null ? 'End Date' : dateFormat.format(_endDate!)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _saveTour,
                          child: const Text('Save Tour', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ).animate().scale(delay: 300.ms),
                      ],
                    ),
                  ),
                ),
              ).animate().fade().slideY(begin: 0.1, end: 0),
            ),
          ),
        ],
      ),
    );
  }
}
