import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/widgets/custom_switch.dart';

class DiscountFormScreen extends StatefulWidget {
  final int? discountId;

  const DiscountFormScreen({super.key, this.discountId});

  @override
  State<DiscountFormScreen> createState() => _DiscountFormScreenState();
}

class _DiscountFormScreenState extends State<DiscountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  final _maxUsageController = TextEditingController();
  
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEditing => widget.discountId != null;

  final List<String> _discountTypes = ['درصدی', 'مبلغی'];

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _valueController.dispose();
    _maxUsageController.dispose();
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفاً نوع تخفیف را انتخاب کنید'), backgroundColor: AppColors.error),
        );
        return;
      }
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفاً تاریخ شروع و پایان را انتخاب کنید'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() => _isLoading = true);

      // TODO: Call Repository to save discount
      await Future.delayed(const Duration(seconds: 2)); // Simulate network request

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'تخفیف با موفقیت ویرایش شد' : 'تخفیف با موفقیت ایجاد شد'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(isEditing ? 'ویرایش تخفیف' : 'افزودن تخفیف جدید'),
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
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اطلاعات تخفیف',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.getPrimaryText(context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      controller: _titleController,
                      labelText: 'عنوان تخفیف *',
                      hintText: 'مثال: جشنواره تابستانه',
                      validator: (value) => value!.isEmpty ? 'عنوان الزامی است' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _codeController,
                      labelText: 'کد تخفیف *',
                      hintText: 'SUMMER20',
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) => value!.isEmpty ? 'کد تخفیف الزامی است' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppDropdown<String>(
                      value: _selectedType,
                      items: _discountTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (value) => setState(() => _selectedType = value),
                      labelText: 'نوع تخفیف *',
                      hintText: 'انتخاب نوع',
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _valueController,
                            labelText: _selectedType == 'مبلغی' ? 'مبلغ (تومان) *' : 'درصد (%) *',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'مقدار الزامی است' : null,
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: AppTextField(
                            controller: _maxUsageController,
                            labelText: 'حداکثر استفاده (اختیاری)',
                            hintText: 'مثال: 100',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
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
                                labelText: 'تاریخ شروع *',
                                hintText: _startDate == null ? 'انتخاب تاریخ' : DateFormat('yyyy/MM/dd').format(_startDate!),
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
                                labelText: 'تاریخ پایان *',
                                hintText: _endDate == null ? 'انتخاب تاریخ' : DateFormat('yyyy/MM/dd').format(_endDate!),
                                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'وضعیت تخفیف',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.getPrimaryText(context),
                              ),
                        ),
                        CustomSwitch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
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