import 'package:chattify/constant.dart';
import 'package:chattify/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profiles_state.dart';

class ProfilesCubit extends Cubit<ProfilesState> {
  ProfilesCubit() : super(ProfilesLoaded(profiles: {}));

  final Map<String, Profile?> profiles = {};
  final Set<String> _loadingProfileIds = {};

  Future<void> getProfile(String userID) async {
    if (profiles.containsKey(userID)) return;

    if (_loadingProfileIds.contains(userID)) return;
    _loadingProfileIds.add(userID);

    try {
      final data = await supabase.from('profiles').select().match({
        'id': userID,
      }).single();
      profiles[userID] = Profile.fromMap(data);
      emit(ProfilesLoaded(profiles: profiles));
    } finally {
      _loadingProfileIds.remove(userID);
    }
  }

  Future<void> getProfiles(List<String> userIDs) async {
    final idsToFetch = userIDs
        .where((id) => !profiles.containsKey(id))
        .toList();

    if (idsToFetch.isEmpty) return;

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .inFilter('id', idsToFetch);

      for (var row in data) {
        final profile = Profile.fromMap(row);
        profiles[profile.id] = profile;
      }
      emit(ProfilesLoaded(profiles: profiles));
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
    }
  }

  void clearProfile(String userID) {
    profiles.remove(userID);
  }

  void clearAllProfiles() {
    profiles.clear();
    _loadingProfileIds.clear();
    emit(ProfilesLoaded(profiles: {}));
  }
}
