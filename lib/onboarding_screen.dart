import 'package:flutter/material.dart';
import 'package:rock_paper_scissors/main.dart'; // Assuming main.dart is in lib
// Import shared_preferences

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<Map<String, String>> onboardingPages = [
    {
      'title': 'Welcome to Rock Paper Scissors!',
      'description': 'Test your luck against the computer in this classic game.',
      'image': 'assets/images/onboarding1.png', // Placeholder
    },
    {
      'title': 'Choose Your Move',
      'description': 'Select Rock, Paper, or Scissors to play your turn.',
      'image': 'assets/images/onboarding2.png', // Placeholder
    },
    {
      'title': 'Track Your Score',
      'description': 'Keep an eye on the scores and see who wins the best of 5.',
      'image': 'assets/images/onboarding3.png', // Placeholder
    },
  ];

  @override
  void initState() {
    super.initState();
    // Remove the check for onboarding status here
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    //   if (hasSeenOnboarding) {
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(builder: (context) => const GamePage()),
    //     );
    //   }
    // });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToGame() async {
    // Add logic to mark onboarding as seen
    await prefs.setBool('hasSeenOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GamePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return OnboardingPage(
                title: onboardingPages[index]['title']!,
                description: onboardingPages[index]['description']!,
                imagePath: onboardingPages[index]['image']!,
              );
            },
          ),
          Positioned(
            bottom: 60.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingPages.length,
                    (index) => buildDot(index: index),
                  ),
                ),
                const SizedBox(height: 20),
                if (_currentPage == onboardingPages.length - 1)
                  ElevatedButton(
                    onPressed: _navigateToGame,
                    child: const Text('Get Started'),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 40.0,
            right: 20.0,
            child: TextButton(
              onPressed: _navigateToGame,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 24 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 200,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
} 