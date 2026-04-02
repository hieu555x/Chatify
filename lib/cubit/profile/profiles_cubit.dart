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
    if (profiles.containsKey(userID)) {
      debugPrint('✅ Profile cached for user: $userID');
      return;
    }

    if (_loadingProfileIds.contains(userID)) {
      debugPrint('⏳ Profile already loading for user: $userID');
      return;
    }

    _loadingProfileIds.add(userID);
    debugPrint('🔄 Fetching profile for user: $userID');

    try {
      final data = await supabase.from('profiles').select().match({
        'id': userID,
      }).single();

      profiles[userID] = Profile.fromMap(data);
      emit(ProfilesLoaded(profiles: profiles));
      debugPrint('✅ Profile loaded for user: $userID');
    } catch (e) {
      debugPrint('❌ Error fetching profile: $e');
      profiles[userID] = null;
      emit(ProfilesLoaded(profiles: profiles));
    } finally {
      _loadingProfileIds.remove(userID);
    }
  }

  Future<void> getProfiles(List<String> userIDs) async {
    final idsToFetch = userIDs
        .where((id) => !profiles.containsKey(id))
        .toList();

    if (idsToFetch.isEmpty) {
      debugPrint('✅ All profiles already cached');
      return;
    }

    debugPrint('🔄 Batch fetching ${idsToFetch.length} profiles');

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .inFilter('id', idsToFetch);

      for (var row in data) {
        final profile = Profile.fromMap(row);
        profiles[profile.id] = profile;
      }

      for (var id in idsToFetch) {
        if (!profiles.containsKey(id)) {
          profiles[id] = null;
        }
      }

      emit(ProfilesLoaded(profiles: profiles));
      debugPrint('✅ Batch loaded ${data.length} profiles');
    } catch (e) {
      debugPrint('❌ Error fetching profiles batch: $e');
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
