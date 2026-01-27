part of 'profiles_cubit.dart';

@immutable
abstract class ProfilesState {}

class ProfilesInitial extends ProfilesState {}

class ProfilesLoaded extends ProfilesState {
  final Map<String, Profile?> profiles;
  ProfilesLoaded({required this.profiles});
}
