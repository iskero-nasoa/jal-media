import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import 'auth_controller.dart';
import 'feed_controller.dart';

class PostController extends GetxController {
  final PostService _postService = PostService();
  final ImagePicker _picker = ImagePicker();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isUploading = false.obs;

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (picked != null) {
      selectedImage.value = File(picked.path);
    }
  }

  void clearImage() {
    selectedImage.value = null;
  }

  Future<void> createPost(String caption) async {
    if (selectedImage.value == null) {
      Get.snackbar(
        'No Image',
        'Please select an image first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id;
    if (userId == null) return;

    isUploading.value = true;
    try {
      final post = await _postService.createPost(
        userId: userId,
        imageFile: selectedImage.value!,
        caption: caption.trim().isEmpty ? null : caption.trim(),
      );

      selectedImage.value = null;

      // Add to feed
      if (Get.isRegistered<FeedController>()) {
        Get.find<FeedController>().addNewPost(post);
      }

      Get.back(); // pop create screen
      Get.snackbar(
        'Posted!',
        'Your post has been shared with the community.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isUploading.value = false;
    }
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    return _postService.getUserPosts(userId);
  }
}
