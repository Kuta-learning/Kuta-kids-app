import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(const ProfileInitial()) {
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile = await _repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _repository.updateProfile(
      name: event.name,
      avatarUrl: event.avatarUrl,
    );
    // Re-fetch the profile to reflect any changes.
    add(const ProfileRequested());
  }
}
