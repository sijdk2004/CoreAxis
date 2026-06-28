import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';

class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
    );
  }
}

class UserProfileNotifier extends Notifier<UserProfileState> {
  @override
  UserProfileState build() {
    return const UserProfileState(isLoading: true);
  }

  void init(String userId) async {
    // If already loaded for this user, skip
    if (state.profile != null && state.profile!.userId == userId) return;

    state = const UserProfileState(isLoading: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    final mockProfile = UserProfile(
      userId: userId,
      firstName: 'Barbara',
      lastName: 'Garcia',
      email: 'barbara.garcia@example.com',
      phone: '+1 555-231-7844',
      avatarUrl: null,
      signatureUrl: null,
      language: 'English',
      timeZone: 'UTC-5 (Eastern Time)',
      dateFormat: 'MM/DD/YYYY',
      currency: 'USD (\$)',
      themeMode: 'System',
      sidebarMode: 'Expanded',
      density: 'Standard',
      emailEnabled: true,
      smsEnabled: false,
      pushEnabled: true,
      whatsappEnabled: false,
      mfaEnabled: true,
      sessionTimeout: '30 minutes',
      trustedDevices: ['MacBook Pro - New York', 'iPhone 14 - New York'],
    );

    state = state.copyWith(
      profile: mockProfile,
      isLoading: false,
      error: null,
    );
  }

  // --- Updates ---
  
  void updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) {
    if (state.profile == null) return;
    state = state.copyWith(
      profile: state.profile!.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      ),
    );
  }

  void updatePreferences({
    String? language,
    String? timeZone,
    String? dateFormat,
    String? currency,
  }) {
    if (state.profile == null) return;
    state = state.copyWith(
      profile: state.profile!.copyWith(
        language: language,
        timeZone: timeZone,
        dateFormat: dateFormat,
        currency: currency,
      ),
    );
  }

  void updateAppearance({
    String? themeMode,
    String? sidebarMode,
    String? density,
  }) {
    if (state.profile == null) return;
    state = state.copyWith(
      profile: state.profile!.copyWith(
        themeMode: themeMode,
        sidebarMode: sidebarMode,
        density: density,
      ),
    );
  }

  void updateNotifications({
    bool? emailEnabled,
    bool? smsEnabled,
    bool? pushEnabled,
    bool? whatsappEnabled,
  }) {
    if (state.profile == null) return;
    state = state.copyWith(
      profile: state.profile!.copyWith(
        emailEnabled: emailEnabled,
        smsEnabled: smsEnabled,
        pushEnabled: pushEnabled,
        whatsappEnabled: whatsappEnabled,
      ),
    );
  }

  void updateSecurity({
    bool? mfaEnabled,
    String? sessionTimeout,
  }) {
    if (state.profile == null) return;
    state = state.copyWith(
      profile: state.profile!.copyWith(
        mfaEnabled: mfaEnabled,
        sessionTimeout: sessionTimeout,
      ),
    );
  }

  Future<void> saveChanges() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Success
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Failed to save changes: \$e');
    }
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfileState>(
  UserProfileNotifier.new,
);
