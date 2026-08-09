import 'package:social_and_recommendation_system/data/models/user_model.dart';

abstract class AuthRepository {
Future<UserModel?> login(String email, String password);
Future<UserModel?> signup(String name, String email, String password);
Future<void> logout();

}