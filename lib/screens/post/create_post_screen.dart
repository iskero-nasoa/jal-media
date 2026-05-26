import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/post_controller.dart';
import '../../widgets/loading_indicator.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  late final PostController _postController;

  @override
  void initState() {
    super.initState();
    _postController = Get.find<PostController>();
    _postController.clearImage();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          Obx(() => TextButton(
                onPressed: _postController.isUploading.value
                    ? null
                    : () => _postController.createPost(_captionController.text),
                child: const Text(
                  'Share',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
        ],
      ),
      body: Obx(() {
        if (_postController.isUploading.value) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LoadingIndicator(),
              const SizedBox(height: 16),
              Text('Uploading your post...',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            ],
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Image picker area
              GestureDetector(
                onTap: _postController.pickImage,
                child: _postController.selectedImage.value != null
                    ? Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Image.file(
                              _postController.selectedImage.value!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: _postController.clearImage,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey.shade100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 64, color: theme.colorScheme.primary),
                            const SizedBox(height: 12),
                            Text('Tap to select a photo',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary)),
                            const SizedBox(height: 4),
                            const Text('From your gallery',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),

              // Caption
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _captionController,
                  maxLines: 5,
                  minLines: 2,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    hintText: 'Write a caption (optional)...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
