import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _initAuthListener();
    _loadCurrentUser();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((state) async {
      if (state.event.name == 'signedIn') {
        await _loadCurrentUser();
      } else if (state.event.name == 'signedOut') {
        currentUser.value = null;
        Get.offAllNamed('/login');
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      currentUser.value = await _authService.getCurrentProfile();
    } catch (_) {
      currentUser.value = null;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    isLoading.value = true;
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        username: username,
      );
      currentUser.value = user;
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final user = await _authService.signIn(email: email, password: password);
      currentUser.value = user;
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void updateCurrentUser(UserModel user) {
    currentUser.value = user;
  }
}
