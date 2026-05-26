import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  final Rx<UserModel?> profileUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  Future<void> loadProfile(String userId) async {
    isLoading.value = true;
    try {
      profileUser.value = await _profileService.getProfile(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String username,
    required String bio,
  }) async {
    if (username.trim().isEmpty) {
      Get.snackbar('Validation', 'Username cannot be empty',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving.value = true;
    try {
      final updated = await _profileService.updateProfile(
        userId: userId,
        username: username.trim(),
        bio: bio.trim(),
      );
      profileUser.value = updated;

      // Update auth controller's cached user
      final authController = Get.find<AuthController>();
      authController.updateCurrentUser(updated);

      Get.back();
      Get.snackbar(
        'Profile Updated',
        'Your profile has been saved.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> uploadAvatar(String userId) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 400,
    );
    if (picked == null) return;

    isSaving.value = true;
    try {
      final avatarUrl =
          await _profileService.uploadAvatar(userId, File(picked.path));
      final updated = await _profileService.updateProfile(
        userId: userId,
        avatarUrl: avatarUrl,
      );
      profileUser.value = updated;
      Get.find<AuthController>().updateCurrentUser(updated);

      Get.snackbar('Avatar Updated', 'Profile photo changed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800);
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload avatar',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
}
