import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/city_stay.dart';
import '../providers/tour_provider.dart';
import '../widgets/glass_card.dart';

class AddEditCityStayScreen extends StatefulWidget {
  final String tourId;
  final CityStay? cityStay;

  const AddEditCityStayScreen({super.key, required this.tourId, this.cityStay});

  @override
  State<AddEditCityStayScreen> createState() => _AddEditCityStayScreenState();
}

class _AddEditCityStayScreenState extends State<AddEditCityStayScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _cityName;
  DateTime? _arrivalDate;
  DateTime? _departureDate;

  @override
  void initState() {
    super.initState();
    if (widget.cityStay != null) {
      _cityName = widget.cityStay!.cityName;
      _arrivalDate = widget.cityStay!.arrivalDate;
      _departureDate = widget.cityStay!.departureDate;
    } else {
      _cityName = '';
    }
  }

  Future<void> _pickDate(BuildContext context, bool isArrival) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isArrival ? (_arrivalDate ?? DateTime.now()) : (_departureDate ?? (_arrivalDate ?? DateTime.now())),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF3498DB)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isArrival) {
          _arrivalDate = picked;
          if (_departureDate != null && _departureDate!.isBefore(_arrivalDate!)) {
            _departureDate = _arrivalDate;
          }
        } else {
          _departureDate = picked;
        }
      });
    }
  }

  void _saveCityStay() {
    if (_formKey.currentState!.validate() && _arrivalDate != null && _departureDate != null) {
      _formKey.currentState!.save();
      final provider = Provider.of<TourProvider>(context, listen: false);

      if (widget.cityStay == null) {
        final newCityStay = CityStay(
          id: const Uuid().v4(),
          tourId: widget.tourId,
          cityName: _cityName,
          arrivalDate: _arrivalDate!,
          departureDate: _departureDate!,
        );
        provider.addCityStay(newCityStay);
      } else {
        final updatedCityStay = CityStay(
          id: widget.cityStay!.id,
          tourId: widget.tourId,
          cityName: _cityName,
          arrivalDate: _arrivalDate!,
          departureDate: _departureDate!,
        );
        provider.updateCityStay(updatedCityStay);
      }
      Navigator.pop(context);
    } else if (_arrivalDate == null || _departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both arrival and departure dates.')),
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
    final isEditing = widget.cityStay != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit City Stay' : 'Add City Stay', style: const TextStyle(color: Colors.white)),
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
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
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
                          initialValue: _cityName,
                          style: const TextStyle(color: Colors.white),
                          decoration: _glassInputDecoration('City Name', Icons.location_city),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a city name' : null,
                          onSaved: (value) => _cityName = value!,
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
                                icon: const Icon(Icons.login),
                                label: Text(_arrivalDate == null ? 'Arrival Date' : dateFormat.format(_arrivalDate!)),
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
                                icon: const Icon(Icons.logout),
                                label: Text(_departureDate == null ? 'Departure Date' : dateFormat.format(_departureDate!)),
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
                          onPressed: _saveCityStay,
                          child: const Text('Save City Stay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
