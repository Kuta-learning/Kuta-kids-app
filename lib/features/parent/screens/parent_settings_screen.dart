import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_event.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../profile/bloc/profile_state.dart';
import '../../profile/data/profile_repository.dart';

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  final ProfileRepository _repository = ProfileRepository();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileBloc(_repository)..add(const ProfileRequested()),
      child: const _ParentSettingsBody(),
    );
  }
}

class _ParentSettingsBody extends StatefulWidget {
  const _ParentSettingsBody();

  @override
  State<_ParentSettingsBody> createState() => _ParentSettingsBodyState();
}

class _ParentSettingsBodyState extends State<_ParentSettingsBody> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedGrade = 1;
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _prefillFromProfile(ProfileState state) {
    if (_prefilled) return;
    if (state is ProfileLoaded) {
      _nameController.text = state.profile.name;
      _selectedGrade = state.profile.gradeLevel.clamp(1, 4);
      _prefilled = true;
    }
  }

  Future<void> _saveChanges() async {
    if (_saving) return;
    setState(() => _saving = true);

    final repository = ProfileRepository();
    final success = await repository.updateProfile(
      name: _nameController.text.trim(),
      gradeLevel: _selectedGrade,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Settings saved!' : 'Failed to save.'),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      appBar: AppBar(
        backgroundColor: AppColors.orange500,
        foregroundColor: Colors.white,
        title: Text(
          'Parent Settings',
          style: AppTypography.kidsBodyMd.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) => _prefillFromProfile(state),
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _SectionLabel(label: "Child's Name"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: state is ProfileLoading ? 'Loading...' : 'Enter name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.borderVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.orange500, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.child_care_rounded,
                        color: AppColors.orange500),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel(label: 'Grade Level'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedGrade,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.orange500, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.school_rounded,
                        color: AppColors.orange500),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Grade 1')),
                    DropdownMenuItem(value: 2, child: Text('Grade 2')),
                    DropdownMenuItem(value: 3, child: Text('Grade 3')),
                    DropdownMenuItem(value: 4, child: Text('Grade 4')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedGrade = v);
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange500,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: AppTypography.kidsBodyMd.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                    },
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.red),
                    label: Text(
                      'Log Out',
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.kidsBodyMd.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
