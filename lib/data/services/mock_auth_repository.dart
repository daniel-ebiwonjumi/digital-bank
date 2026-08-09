import 'package:social_and_recommendation_system/data/models/user_model.dart';
import 'package:social_and_recommendation_system/data/repositories/auth_repository_impl.dart';

class MockAuthRepository implements AuthRepository {

  final List<Map<String, String>> _registeredUsers = [
    {'name': 'Daniel', 'email': 'ebjdan@gmail.com', 'password': 'mypassword'},
     {'name': 'Divine', 'email': 'bawadivine@gmail.com', 'password': 'aerospace'},
  ];
  @override
  Future<UserModel?> login(String email, String password) async {
    // TODO: remove simulated pause
    await Future.delayed(Duration(milliseconds: 1500));

    try{
      final userMap = _registeredUsers.firstWhere(
        (u) => u['email'] == email.trim() && u['password'] == password,
        orElse: ()=>{},
      );
        return UserModel(id: 'mock_id${userMap['email']}', email: userMap['email'] ?? '', name: userMap['name'] ?? 'Unknown user');
    }
    catch(_){
      return null;
    }
  }

  @override
  Future<void> logout() async {
    // TODO: removeSimulated pauses
    await Future.delayed(Duration(milliseconds: 1500));
   try{

   }
   catch(_){

   }
  }

  @override
  Future<UserModel?> signup(String name, String email, String password) async {
    // TODO: implement signup
   await Future.delayed(Duration(milliseconds: 1500));
bool exists = _registeredUsers.any((u) => u['email'] == email.trim());
if (exists) return null;
  
  _registeredUsers.add({'name': name, 'email': email, 'password': password});
  return UserModel(id: 'mock_id_email', email: email, name: name);
  }

}