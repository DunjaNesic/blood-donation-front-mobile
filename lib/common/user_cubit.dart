import 'package:blood_donation/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<User?> {
  UserCubit(super.state);

  void login(User user) => emit(user);

  void logout() => emit(null);
}
