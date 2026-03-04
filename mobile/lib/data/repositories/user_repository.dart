import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/user_api.dart';
import '../models/user_model.dart';

/// Repository provider for user operations
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final userApi = ref.watch(userApiProvider);
  return UserRepository(userApi);
});

/// User Repository
/// Provides a clean interface to the user API for the presentation layer.
class UserRepository {
  final UserApi _userApi;

  UserRepository(this._userApi);

  /// Get a user's profile by ID
  Future<UserModel> getUserById(String id) async {
    return _userApi.getUserById(id);
  }
}
