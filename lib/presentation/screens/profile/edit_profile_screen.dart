import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/theme/app_text_styles.dart';
import 'package:level_bot/core/utils/validators.dart' show Validators;
import 'package:level_bot/domain/entities/user_entity.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/user_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_button.dart';
import 'package:level_bot/presentation/widgets/common/app_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _ageController;

  File? _selectedPhoto;
  FitnessLevel _selectedLevel = FitnessLevel.beginner;
  FitnessGoal _selectedGoal = FitnessGoal.buildMuscle;
  bool _useMetric = true;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  UserEntity? _initialUser;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController()..addListener(_markDirty);
    _usernameController = TextEditingController()..addListener(_markDirty);
    _bioController = TextEditingController()..addListener(_markDirty);
    _heightController = TextEditingController()..addListener(_markDirty);
    _weightController = TextEditingController()..addListener(_markDirty);
    _ageController = TextEditingController()..addListener(_markDirty);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    _initialUser = user;
    _displayNameController.text = user.displayName;
    _usernameController.text = user.username;
    _bioController.text = user.bio ?? '';
    _heightController.text = user.height?.toStringAsFixed(0) ?? '';
    _weightController.text = user.weight?.toStringAsFixed(1) ?? '';
    _ageController.text = user.age?.toString() ?? '';
    setState(() {
      _selectedLevel = user.level;
      _selectedGoal = user.goal;
      _hasUnsavedChanges = false;
    });
  }

  void _markDirty() {
    if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discardChanges),
        content: Text(l10n.discardChangesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.stay),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
        _hasUnsavedChanges = true;
      });
    }
  }

  void _showPhotoPickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(AppLocalizations.of(context)!.takePhoto),
                onTap: () => _pickPhoto(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(AppLocalizations.of(context)!.chooseFromLibrary),
                onTap: () => _pickPhoto(ImageSource.gallery),
              ),
              if (_selectedPhoto != null ||
                  (_initialUser?.photoUrl?.isNotEmpty ?? false))
                ListTile(
                  leading: Icon(
                    Icons.delete_outlined,
                    color: AppColors.error,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.removePhoto,
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedPhoto = null;
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    final userId = _initialUser?.id ?? '';
    if (userId.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final result = await ref
          .read(userProfileNotifierProvider.notifier)
          .updateProfile(
            userId: userId,
            displayName: _displayNameController.text.trim(),
            username: _usernameController.text.trim().toLowerCase(),
            bio: _bioController.text.trim(),
            height: double.tryParse(_heightController.text.trim()),
            weight: double.tryParse(_weightController.text.trim()),
            age: int.tryParse(_ageController.text.trim()),
            level: _selectedLevel,
            goal: _selectedGoal,
            photoFile: _selectedPhoto,
          );

      if (mounted) {
        result.fold(
          (failure) => context.showErrorSnackBar(failure.message),
          (_) {
            context.showSnackBar(l10n.profileUpdatedSuccess);
            setState(() => _hasUnsavedChanges = false);
            context.pop();
          },
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to update profile: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && _hasUnsavedChanges) {
          final should = await _onWillPop();
          if (should && context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProfile),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              if (await _onWillPop()) context.pop();
            },
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoSection(),
                    const SizedBox(height: 28),
                    _sectionLabel(l10n.basicInfo),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _displayNameController,
                      label: l10n.displayName,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: Validators.validateDisplayName,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _usernameController,
                      label: l10n.username,
                      prefixIcon: Icons.alternate_email_rounded,
                      validator: Validators.validateUsername,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9_.]'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _bioController,
                      label: l10n.bioLabel,
                      prefixIcon: Icons.info_outline_rounded,
                      maxLines: 3,
                      maxLength: 150,
                      validator: (value) {
                        if (value != null && value.length > 150) {
                          return l10n.bioMaxLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel(l10n.physicalStats),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${l10n.units}:',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(width: 12),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: true,
                              label: Text('kg / cm'),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text('lbs / in'),
                            ),
                          ],
                          selected: {_useMetric},
                          onSelectionChanged: (val) => setState(() {
                            _useMetric = val.first;
                            _markDirty();
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _heightController,
                            label: _useMetric ? l10n.heightCm : l10n.heightIn,
                            prefixIcon: Icons.height_rounded,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                            validator: (val) {
                              if (val == null || val.isEmpty) return null;
                              final n = double.tryParse(val);
                              if (n == null) return 'Invalid';
                              if (_useMetric && (n < 50 || n > 300)) {
                                return '50–300 cm';
                              }
                              if (!_useMetric && (n < 20 || n > 120)) {
                                return '20–120 in';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppTextField(
                            controller: _weightController,
                            label: _useMetric ? l10n.weightKg : l10n.weightLbs,
                            prefixIcon: Icons.monitor_weight_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                            validator: (val) {
                              if (val == null || val.isEmpty) return null;
                              final n = double.tryParse(val);
                              if (n == null) return 'Invalid';
                              if (_useMetric && (n < 20 || n > 500)) {
                                return '20–500 kg';
                              }
                              if (!_useMetric && (n < 44 || n > 1100)) {
                                return '44–1100 lbs';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppTextField(
                            controller: _ageController,
                            label: l10n.ageLabel,
                            prefixIcon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (val) {
                              if (val == null || val.isEmpty) return null;
                              final n = int.tryParse(val);
                              if (n == null) return 'Invalid';
                              if (n < 10 || n > 120) return '10–120';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel(l10n.fitnessLevel),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FitnessLevel.values.map((level) {
                        final isSelected = _selectedLevel == level;
                        return ChoiceChip(
                          label: Text(level.displayName),
                          selected: isSelected,
                          onSelected: (_) => setState(() {
                            _selectedLevel = level;
                            _markDirty();
                          }),
                          selectedColor: AppColors.primary.withAlpha(80),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel(l10n.fitnessGoal),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FitnessGoal.values.map((goal) {
                        final isSelected = _selectedGoal == goal;
                        return ChoiceChip(
                          label: Text(goal.displayName),
                          selected: isSelected,
                          onSelected: (_) => setState(() {
                            _selectedGoal = goal;
                            _markDirty();
                          }),
                          selectedColor: AppColors.accent.withAlpha(80),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: AppColors.darkDivider),
                  ),
                ),
                child: AppButton(
                  label: l10n.saveChanges,
                  isLoading: _isSaving,
                  onPressed: _hasUnsavedChanges ? _saveChanges : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final photoUrl = _initialUser?.photoUrl;
    final hasPhoto = _selectedPhoto != null ||
        (photoUrl != null && photoUrl.isNotEmpty);

    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showPhotoPickerSheet,
            child: CircleAvatar(
              radius: 54,
              backgroundColor: AppColors.darkCard,
              backgroundImage: _selectedPhoto != null
                  ? FileImage(_selectedPhoto!) as ImageProvider
                  : (photoUrl != null && photoUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(photoUrl)
                      : null,
              child: !hasPhoto
                  ? Text(
                      (_initialUser?.displayName.isNotEmpty == true)
                          ? _initialUser!.displayName[0].toUpperCase()
                          : 'U',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showPhotoPickerSheet,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
    );
  }
}
