import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<OnboardingStep> onboardingSteps = [
  OnboardingStep(
    title: 'Welcome to CoreAxis ERP',
    description: 'Your next-generation enterprise resource planning platform. Let us show you around.',
    icon: LucideIcons.rocket,
  ),
  OnboardingStep(
    title: 'Platform Overview',
    description: 'A unified workspace combining powerful analytics, workflow automation, and collaborative tools to run your entire business.',
    icon: LucideIcons.layoutDashboard,
  ),
  OnboardingStep(
    title: 'Seamless Navigation',
    description: 'Access any module instantly using the sidebar, or hit Ctrl+K to open the global command palette.',
    icon: LucideIcons.navigation,
  ),
  OnboardingStep(
    title: 'Platform Administration',
    description: 'Manage users, organizations, and granular role-based permissions with absolute precision.',
    icon: LucideIcons.shieldCheck,
  ),
  OnboardingStep(
    title: 'Workflow Automation',
    description: 'Design complex approval chains and business rules using our intuitive visual drag-and-drop editor.',
    icon: LucideIcons.workflow,
  ),
  OnboardingStep(
    title: 'Smart Documents',
    description: 'Store, share, and collaborate on files globally. Everything is version-controlled and fully auditable.',
    icon: LucideIcons.files,
  ),
  OnboardingStep(
    title: 'Advanced Reports',
    description: 'Build dynamic reports, schedule automated deliveries, and export beautiful data visualizations.',
    icon: LucideIcons.barChart4,
  ),
  OnboardingStep(
    title: 'AI & Copilot',
    description: 'Leverage our integrated AI assistant to query data, generate reports, and get predictive insights automatically.',
    icon: LucideIcons.sparkles,
  ),
  OnboardingStep(
    title: 'Industry Packs',
    description: 'Instantly tailor the platform for your specific sector—from manufacturing to retail—with pre-built templates.',
    icon: LucideIcons.packagePlus,
  ),
  OnboardingStep(
    title: 'You\'re All Set!',
    description: 'Dive in and start exploring CoreAxis. Your digital transformation begins now.',
    icon: LucideIcons.checkCircle2,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < onboardingSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() {
    context.go('/platform/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      body: Center(
        child: Container(
          width: isDesktop ? 800 : double.infinity,
          height: isDesktop ? 600 : double.infinity,
          decoration: isDesktop
              ? BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    )
                  ],
                )
              : BoxDecoration(color: theme.colorScheme.surface),
          child: Column(
            children: [
              // Page Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: onboardingSteps.length,
                  itemBuilder: (context, index) {
                    final step = onboardingSteps[index];
                    return Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              step.icon,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                          ).animate(key: ValueKey('icon_$index')).scale(duration: 500.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 48),
                          Text(
                            step.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ).animate(key: ValueKey('title_$index')).fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 16),
                          Text(
                            step.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ).animate(key: ValueKey('desc_$index')).fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Navigation Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip / Back
                    SizedBox(
                      width: 100,
                      child: _currentIndex == 0
                          ? TextButton(
                              onPressed: _finish,
                              child: const Text('Skip'),
                            )
                          : TextButton.icon(
                              onPressed: _previousPage,
                              icon: const Icon(LucideIcons.arrowLeft, size: 16),
                              label: const Text('Back'),
                            ),
                    ),

                    // Progress Dots
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(onboardingSteps.length, (index) {
                        final isActive = index == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Next / Finish
                    SizedBox(
                      width: 100,
                      child: _currentIndex == onboardingSteps.length - 1
                          ? FilledButton(
                              onPressed: _finish,
                              child: const Text('Finish'),
                            ).animate().shimmer(delay: 400.ms, duration: 1800.ms)
                          : FilledButton.icon(
                              onPressed: _nextPage,
                              icon: const Icon(LucideIcons.arrowRight, size: 16),
                              label: const Text('Next'),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
