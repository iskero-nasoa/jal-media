import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/feed_controller.dart';
import '../../controllers/post_controller.dart';
import '../../controllers/profile_controller.dart';
import '../post/create_post_screen.dart';
import '../profile/profile_screen.dart';
import 'feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ensure controllers are registered
    if (!Get.isRegistered<FeedController>()) Get.put(FeedController());
    if (!Get.isRegistered<PostController>()) Get.put(PostController());
    if (!Get.isRegistered<ProfileController>()) Get.put(ProfileController());
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      // "+" tab → navigate to create post screen
      Get.to(() => const CreatePostScreen());
      return;
    }
    setState(() => _currentIndex = index == 2 ? 1 : index);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    final screens = [
      const FeedScreen(),
      ProfileScreen(userId: authController.currentUser.value?.id ?? ''),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex == 0 ? 0 : 2,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline, size: 32),
            selectedIcon: Icon(Icons.add_circle, size: 32),
            label: 'Post',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
