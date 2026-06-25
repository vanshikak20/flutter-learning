import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/menu_item_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class MenuItemFormScreen extends StatefulWidget {
  final MenuItemModel? existingItem;

  const MenuItemFormScreen({
    super.key,
    this.existingItem,
  });

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  XFile? _pickedImage;
  bool _isUploadingImage = false;

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _imageUrlController;

  String _selectedCategory = 'Breakfast';
  bool _isAvailable = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'Breakfast',
    'Snacks',
    'Drinks',
    'Lunch',
    'Desserts',
  ];

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    // if editing, prefill controllers with existing values
    // if adding, start with empty controllers
    _nameController = TextEditingController(
      text: widget.existingItem?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingItem?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.existingItem?.price.toStringAsFixed(0) ?? '',
    );
    _prepTimeController = TextEditingController(
      text: widget.existingItem?.prepTimeMinutes.toString() ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.existingItem?.imageUrl ?? '',
    );

    if (widget.existingItem != null) {
      _selectedCategory = widget.existingItem!.category;
      _isAvailable = widget.existingItem!.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final item = MenuItemModel(
        id: widget.existingItem?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        imageUrl: _imageUrlController.text.trim(),
        isAvailable: _isAvailable,
        prepTimeMinutes: int.parse(_prepTimeController.text.trim()),
      );

      if (_isEditing) {
        await _firestoreService.updateMenuItem(item);
      } else {
        await _firestoreService.addMenuItem(item);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    // show confirmation dialog before deleting
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Item',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.existingItem!.name}"? This cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await _firestoreService.deleteMenuItem(widget.existingItem!.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _pickImage() async {
  final image = await _storageService.pickImageFromGallery();

  if (image == null) return;

  setState(() {
    _pickedImage = image;
    _isUploadingImage = true;
  });

  try {
    final url = await _storageService.uploadMenuItemImage(image);

    setState(() {
      _imageUrlController.text = url;
      _isUploadingImage = false;
    });
  } catch (e) {
    setState(() => _isUploadingImage = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image upload failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add Item'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image preview
              _buildImagePreview(),
              const SizedBox(height: 24),
              // name
              Text(
                'Item Name',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                hint: 'e.g. Masala Dosa',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // description
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                hint: 'e.g. Crispy dosa with spicy potato filling',
                controller: _descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // price and prep time in a row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price (₹)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hint: 'e.g. 40',
                          controller: _priceController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid price';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prep Time (mins)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hint: 'e.g. 7',
                          controller: _prepTimeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter time';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Category',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              // availability toggle
              _buildAvailabilityToggle(),
              const SizedBox(height: 32),
              CustomButton(
                label: _isEditing ? 'Update Item' : 'Add Item',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
  return Center(
    child: Column(
      children: [
        GestureDetector(
          onTap: _isUploadingImage ? null : _pickImage,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildImageContent(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_isUploadingImage)
          Text(
            'Uploading...',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.primary,
            ),
          )
        else
          Text(
            'Tap to select image',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
      ],
    ),
  );
}
Widget _buildImageContent() {
  if (_isUploadingImage) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  if (_pickedImage != null) {
    return Image.network(
      _pickedImage!.path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.broken_image,
        color: AppColors.primary,
        size: 48,
      ),
    );
  }

  if (_imageUrlController.text.isNotEmpty) {
    return Image.network(
      _imageUrlController.text,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.fastfood,
        color: AppColors.primary,
        size: 48,
      ),
    );
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(
        Icons.add_photo_alternate_outlined,
        color: AppColors.primary,
        size: 48,
      ),
      const SizedBox(height: 4),
      Text(
        'Add Photo',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.primary,
        ),
      ),
    ],
  );
}

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Students can see and order this item',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          Switch(
            value: _isAvailable,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() => _isAvailable = value);
            },
          ),
        ],
      ),
    );
  }
}