import 'package:chattify/constant.dart';
import 'package:chattify/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profiles_state.dart';

class ProfilesCubit extends Cubit<ProfilesState> {
  ProfilesCubit() : super(ProfilesInitial());

  final Map<String, Profile?> profiles = {};

  Future<void> getProfile(String userID) async {
    if (profiles[userID] != null) {
      return;
    }

    final data = await supabase.from('profiles').select().match({
      'id': userID,
    }).single();

    if (data == null) {
      return;
    }
    profiles[userID] = Profile.fromMap(data);
    emit(ProfilesLoaded(profiles: profiles));
  }
}
