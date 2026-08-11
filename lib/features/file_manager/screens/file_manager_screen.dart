import 'package:crm_panel/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/dialogs/delete_dialog.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  bool _isUploading = false;

  // Mock Data for uploaded files
  final List<Map<String, dynamic>> _files = [
    {'id': 1, 'name': 'banner1.jpg', 'type': 'image', 'size': '250 KB', 'url': 'https://via.placeholder.com/150'},
    {'id': 2, 'name': 'product_a52.jpg', 'type': 'image', 'size': '1.2 MB', 'url': 'https://via.placeholder.com/150'},
    {'id': 3, 'name': 'invoice.pdf', 'type': 'pdf', 'size': '500 KB', 'url': ''},
    {'id': 4, 'name': 'avatar_admin.png', 'type': 'image', 'size': '120 KB', 'url': 'https://via.placeholder.com/150'},
  ];

  Future<void> _pickAndUploadFile() async {
    final file = await UploadService.pickFile();
    if (file == null) return;

    setState(() => _isUploading = true);

    // Simulate upload process
    await Future.delayed(const Duration(seconds: 2));
    // In a real app, you would call: await UploadService.uploadFile(file: file, folderName: 'crm-assets');

    if (mounted) {
      setState(() {
        _isUploading = false;
        _files.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          'name': file.path.split('/').last,
          'type': file.path.endsWith('.pdf') ? 'pdf' : 'image',
          'size': '2.1 MB',
          'url': '',
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فایل با موفقیت آپلود شد'), backgroundColor: AppColors.success),
      );
    }
  }

  void _showImagePreview(BuildContext context, Map<String, dynamic> file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: AppCard(
          padding: const EdgeInsets.all(AppSizes.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Image.network(file['url'], fit: BoxFit.contain, height: 400),
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(file['name'], style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مدیریت فایل‌ها',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppButton(
                label: _isUploading ? 'در حال آپلود...' : 'آپلود فایل جدید',
                icon: Icons.cloud_upload_outlined,
                isLoading: _isUploading,
                onPressed: _isUploading ? null : _pickAndUploadFile,
                width: 200,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Files Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.8,
                crossAxisSpacing: AppSizes.md,
                mainAxisSpacing: AppSizes.md,
              ),
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                bool isImage = file['type'] == 'image';

                return AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.getBackground(context),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.large),
                            ),
                          ),
                          child: isImage
                              ? GestureDetector(
                                  onTap: () => _showImagePreview(context, file),
                                  child: file['url'].isNotEmpty
                                      ? Image.network(file['url'], fit: BoxFit.cover)
                                      : Icon(Icons.image_outlined, size: 40, color: AppColors.getSecondaryText(context)),
                                )
                              : Center(
                                  child: Icon(Icons.picture_as_pdf_outlined, size: 40, color: AppColors.error),
                                ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file['name'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.getPrimaryText(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                file['size'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.getSecondaryText(context),
                                    ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (isImage)
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.info),
                                      onPressed: () => _showImagePreview(context, file),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                    onPressed: () {
                                      DeleteDialog.show(
                                        context: context,
                                        title: 'حذف فایل',
                                        message: 'آیا از حذف فایل "${file['name']}" مطمئن هستید؟',
                                        onDelete: () {
                                          setState(() {
                                            _files.removeAt(index);
                                          });
                                        },
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}