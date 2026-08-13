import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/widgets/custom_switch.dart';
import '../../../providers/discounts_provider.dart';

class DiscountFormScreen extends StatefulWidget {
  final String? discountId;

  const DiscountFormScreen({super.key, this.discountId});

  @override
  State<DiscountFormScreen> createState() => _DiscountFormScreenState();
}

class _DiscountFormScreenState extends State<DiscountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _totalUsageController = TextEditingController();
  final _perUserUsageController = TextEditingController();
  
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEditing => widget.discountId != null;

  final List<String> _discountTypes = ['Percentage', 'Fixed Amount'];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<DiscountsProvider>();
        final discount = provider.getDiscountById(widget.discountId!);
        if (discount != null) {
          _titleController.text = discount.title;
          _codeController.text = discount.code;
          _valueController.text = discount.value.toString();
          _minPurchaseController.text = discount.minPurchaseAmount?.toString() ?? '';
          _maxDiscountController.text = discount.maxDiscountAmount?.toString() ?? '';
          _totalUsageController.text = discount.totalUsageLimit?.toString() ?? '';
          _perUserUsageController.text = discount.perUserUsageLimit?.toString() ?? '';
          _selectedType = discount.type == 'percentage' ? 'Percentage' : 'Fixed Amount';
          _startDate = discount.startDate;
          _endDate = discount.endDate;
          _isActive = discount.isActive;
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _valueController.dispose();
    _minPurchaseController.dispose();
    _maxDiscountController.dispose();
    _totalUsageController.dispose();
    _perUserUsageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: AppColors.getSurface(context),
                  onSurface: AppColors.getPrimaryText(context),
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  String? _validatePositiveNumber(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'This field is required' : null;
    }
    final num = double.tryParse(value);
    if (num == null) return 'Invalid number';
    if (num < 0) return 'Value cannot be negative';
    return null;
  }

  String? _validatePerUserLimit(String? value) {
    final error = _validatePositiveNumber(value);
    if (error != null) return error;

    if (value != null && value.isNotEmpty) {
      final perUser = int.tryParse(value);
      final totalUsage = int.tryParse(_totalUsageController.text);
      if (perUser != null && totalUsage != null && perUser > totalUsage) {
        return 'Cannot be greater than Total Usage Limit';
      }
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select discount type'), backgroundColor: AppColors.error),
        );
        return;
      }
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() => _isLoading = true);

      final discountData = {
        'title': _titleController.text,
        'code': _codeController.text.toUpperCase(),
        'type': _selectedType == 'Percentage' ? 'percentage' : 'fixed_amount',
        'value': double.parse(_valueController.text),
        'min_purchase_amount': _minPurchaseController.text.isEmpty ? null : double.parse(_minPurchaseController.text),
        'max_discount_amount': _maxDiscountController.text.isEmpty ? null : double.parse(_maxDiscountController.text),
        'total_usage_limit': _totalUsageController.text.isEmpty ? null : int.parse(_totalUsageController.text),
        'per_user_usage_limit': _perUserUsageController.text.isEmpty ? null : int.parse(_perUserUsageController.text),
        'is_active': _isActive,
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
      };

      try {
        final provider = context.read<DiscountsProvider>();
        if (isEditing) {
          await provider.updateDiscount(widget.discountId!, discountData);
        } else {
          await provider.createDiscount(discountData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Discount updated successfully' : 'Discount created successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Discount' : 'Add New Discount'),
        backgroundColor: AppColors.getSurface(context),
        foregroundColor: AppColors.getPrimaryText(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discount Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.getPrimaryText(context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      controller: _titleController,
                      labelText: 'Discount Title *',
                      hintText: 'e.g., Summer Sale',
                      validator: (value) => value!.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _codeController,
                      labelText: 'Discount Code *',
                      hintText: 'SUMMER20',
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) => value!.isEmpty ? 'Code is required' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppDropdown<String>(
                      value: _selectedType,
                      items: _discountTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (value) => setState(() => _selectedType = value),
                      labelText: 'Discount Type *',
                      hintText: 'Select Type',
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _valueController,
                      labelText: _selectedType == 'Fixed Amount' ? 'Value (Toman) *' : 'Value (%) *',
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      validator: (value) => _validatePositiveNumber(value, isRequired: true),
                    ),
                    const SizedBox(height: AppSizes.md),
                    // Date Pickers
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(context, true),
                            child: AbsorbPointer(
                              child: AppTextField(
                                labelText: 'Start Date *',
                                hintText: _startDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_startDate!),
                                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(context, false),
                            child: AbsorbPointer(
                              child: AppTextField(
                                labelText: 'End Date *',
                                hintText: _endDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_endDate!),
                                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Limits & Conditions Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Limits & Conditions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.getPrimaryText(context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Wrap(
                      spacing: AppSizes.md,
                      runSpacing: AppSizes.md,
                      children: [
                        SizedBox(
                          width: 250,
                          child: AppTextField(
                            controller: _minPurchaseController,
                            labelText: 'Min Purchase Amount (Toman)',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: (value) => _validatePositiveNumber(value),
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: AppTextField(
                            controller: _maxDiscountController,
                            labelText: 'Max Discount Amount (Toman)',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: (value) => _validatePositiveNumber(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Wrap(
                      spacing: AppSizes.md,
                      runSpacing: AppSizes.md,
                      children: [
                        SizedBox(
                          width: 250,
                          child: AppTextField(
                            controller: _totalUsageController,
                            labelText: 'Total Usage Limit',
                            hintText: 'e.g., 100',
                            keyboardType: TextInputType.number,
                            validator: (value) => _validatePositiveNumber(value),
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: AppTextField(
                            controller: _perUserUsageController,
                            labelText: 'Per User Usage Limit',
                            hintText: 'e.g., 1',
                            keyboardType: TextInputType.number,
                            validator: _validatePerUserLimit,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Settings Card
              AppCard(
                child: SwitchListTile(
                  title: const Text('Active Discount'),
                  subtitle: const Text('If disabled, discount cannot be used by customers'),
                  value: _isActive,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: AppStrings.cancel,
                    type: AppButtonType.outline,
                    width: 120,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSizes.md),
                  AppButton(
                    label: AppStrings.save,
                    isLoading: _isLoading,
                    width: 120,
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}