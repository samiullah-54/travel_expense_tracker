import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expense.dart';
import '../providers/tour_provider.dart';
import '../widgets/glass_card.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final String cityStayId;
  final Expense? expense;

  const AddEditExpenseScreen({super.key, required this.cityStayId, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _amount;
  late String _category;
  late String _customCategory;
  late String _description;
  late DateTime _date;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = ['Fuel', 'Tolls', 'Hotel', 'Food', 'Ironing', 'Other'];
  late String _deductedFrom;
  final List<String> _deductionOptions = ['None', 'Advance Cash', 'Miscellaneous'];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amount = widget.expense!.amount;
      _description = widget.expense!.description;
      _date = widget.expense!.date;
      _imagePath = widget.expense!.imagePath;
      
      if (_categories.contains(widget.expense!.category)) {
        _category = widget.expense!.category;
        _customCategory = '';
      } else {
        _category = 'Other';
        _customCategory = widget.expense!.category;
      }
      _deductedFrom = widget.expense!.deductedFrom ?? 'None';
    } else {
      _amount = 0.0;
      _category = _categories.first;
      _customCategory = '';
      _description = '';
      _date = DateTime.now();
      _deductedFrom = 'None';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final name = p.basename(pickedFile.path);
        final String newPath = '${directory.path}/$name';
        
        final File localImage = await File(pickedFile.path).copy(newPath);

        if (!mounted) return;
        setState(() {
          _imagePath = localImage.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF2C3E50),
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Photo Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF8E44AD)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<TourProvider>(context, listen: false);

      final finalCategory = _category == 'Other' && _customCategory.isNotEmpty 
          ? _customCategory 
          : _category;

      final finalDeductedFrom = _deductedFrom == 'None' ? null : _deductedFrom;

      if (widget.expense == null) {
        final newExpense = Expense(
          id: const Uuid().v4(),
          cityStayId: widget.cityStayId,
          amount: _amount,
          category: finalCategory,
          description: _description,
          date: _date,
          imagePath: _imagePath,
          deductedFrom: finalDeductedFrom,
        );
        provider.addExpense(newExpense);
      } else {
        final updatedExpense = Expense(
          id: widget.expense!.id,
          cityStayId: widget.cityStayId,
          amount: _amount,
          category: finalCategory,
          description: _description,
          date: _date,
          imagePath: _imagePath,
          deductedFrom: finalDeductedFrom,
        );
        provider.updateExpense(updatedExpense);
      }
      Navigator.pop(context);
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
    final isEditing = widget.expense != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense', style: const TextStyle(color: Colors.white)),
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
                          initialValue: _amount == 0.0 ? '' : _amount.toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: _glassInputDecoration('Amount (PKR)', Icons.payments),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter an amount';
                            if (double.tryParse(value) == null) return 'Please enter a valid number';
                            return null;
                          },
                          onSaved: (value) => _amount = double.parse(value!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          dropdownColor: const Color(0xFF203A43),
                          style: const TextStyle(color: Colors.white),
                          decoration: _glassInputDecoration('Category', Icons.category),
                          items: _categories.map((String category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _category = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _deductedFrom,
                          dropdownColor: const Color(0xFF203A43),
                          style: const TextStyle(color: Colors.white),
                          decoration: _glassInputDecoration('Deduct From', Icons.account_balance_wallet),
                          items: _deductionOptions.map((String option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _deductedFrom = newValue!;
                            });
                          },
                        ),
                        if (_category == 'Other') ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _customCategory,
                            style: const TextStyle(color: Colors.white),
                            decoration: _glassInputDecoration('Specify Other Expense', Icons.more_horiz),
                            validator: (value) => value == null || value.trim().isEmpty ? 'Please specify the expense' : null,
                            onSaved: (value) => _customCategory = value!.trim(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _description,
                          style: const TextStyle(color: Colors.white),
                          decoration: _glassInputDecoration('Notes / Description (Optional)', Icons.note),
                          onSaved: (value) => _description = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _pickDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text('Date: ${dateFormat.format(_date)}'),
                        ),
                        const SizedBox(height: 16),
                        if (_imagePath != null)
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white30),
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(File(_imagePath!)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                                onPressed: () => setState(() => _imagePath = null),
                              ),
                            ],
                          ).animate().scale()
                        else
                          OutlinedButton.icon(
                            onPressed: _showImagePickerOptions,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Attach Receipt / Image'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white54),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E44AD),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _saveExpense,
                          child: const Text('Save Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
