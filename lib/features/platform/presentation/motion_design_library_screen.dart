import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../core/theme/motion_system.dart';

class MotionDesignLibraryScreen extends StatelessWidget {
  const MotionDesignLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Motion Design Library'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Standardized Animations & Transitions',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A unified collection of movement patterns used across CoreAxis ERP. Powered by flutter_animate and our internal CoreAxisMotion abstraction.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            _buildSectionTitle(context, 'Core Presets'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _PlayableAnimationCard(
                  title: 'Fade In',
                  subtitle: '.coreFadeIn()',
                  builder: (context, key) => Icon(LucideIcons.sun, size: 64, color: theme.colorScheme.primary)
                      .animate(key: key)
                      .coreFadeIn(),
                ),
                _PlayableAnimationCard(
                  title: 'Slide Up & Fade',
                  subtitle: '.coreFadeIn().coreSlideUp()',
                  builder: (context, key) => Icon(LucideIcons.arrowUpCircle, size: 64, color: theme.colorScheme.primary)
                      .animate(key: key)
                      .coreFadeIn()
                      .coreSlideUp(),
                ),
                _PlayableAnimationCard(
                  title: 'Scale Up',
                  subtitle: '.coreScaleUp()',
                  builder: (context, key) => Icon(LucideIcons.scaling, size: 64, color: theme.colorScheme.primary)
                      .animate(key: key)
                      .coreFadeIn()
                      .coreScaleUp(),
                ),
                _PlayableAnimationCard(
                  title: 'Emphasize (Pop)',
                  subtitle: '.corePop()',
                  builder: (context, key) => Icon(LucideIcons.checkCircle, size: 64, color: theme.colorScheme.primary)
                      .animate(key: key)
                      .corePop(),
                ),
              ],
            ),
            const SizedBox(height: 48),

            _buildSectionTitle(context, 'Component Examples'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _PlayableAnimationCard(
                  title: 'Dialog Entrance',
                  subtitle: 'Simulating a modal open',
                  width: 300,
                  builder: (context, key) => Container(
                    width: 200,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Confirm Action?'),
                  ).animate(key: key).coreFadeIn().coreScaleUp(),
                ),
                _PlayableAnimationCard(
                  title: 'Toast Notification',
                  subtitle: 'Simulating a toast entry',
                  width: 300,
                  builder: (context, key) => Container(
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Saved Successfully', style: TextStyle(color: Colors.white)),
                  ).animate(key: key).coreFadeIn().coreSlideUp(begin: 0.5),
                ),
                _PlayableAnimationCard(
                  title: 'Chart Data Entry',
                  subtitle: '.coreChartEntry()',
                  width: 300,
                  builder: (context, key) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMockBar(60, theme).animate(delay: 0.ms).coreChartEntry(),
                      const SizedBox(width: 8),
                      _buildMockBar(100, theme).animate(delay: 100.ms).coreChartEntry(),
                      const SizedBox(width: 8),
                      _buildMockBar(40, theme).animate(delay: 200.ms).coreChartEntry(),
                      const SizedBox(width: 8),
                      _buildMockBar(80, theme).animate(delay: 300.ms).coreChartEntry(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            _buildSectionTitle(context, 'Interactions & States'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _InteractiveCardExample(),
                _InteractiveButtonExample(),
                _PlayableAnimationCard(
                  title: 'Skeleton Loading',
                  subtitle: '.coreShimmerLoading()',
                  builder: (context, key) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 16, color: theme.colorScheme.surfaceContainerHighest),
                      const SizedBox(height: 8),
                      Container(width: 180, height: 12, color: theme.colorScheme.surfaceContainerHighest),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 12, color: theme.colorScheme.surfaceContainerHighest),
                    ],
                  ).animate(key: key, onPlay: (controller) => controller.repeat()).coreShimmerLoading(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMockBar(double height, ThemeData theme) {
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class _PlayableAnimationCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget Function(BuildContext context, Key key) builder;
  final double width;

  const _PlayableAnimationCard({
    required this.title,
    required this.subtitle,
    required this.builder,
    this.width = 250,
  });

  @override
  State<_PlayableAnimationCard> createState() => _PlayableAnimationCardState();
}

class _PlayableAnimationCardState extends State<_PlayableAnimationCard> {
  Key _animationKey = UniqueKey();

  void _replay() {
    setState(() {
      _animationKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: widget.width,
      height: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.play),
                  onPressed: _replay,
                  tooltip: 'Replay Animation',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerLowest,
              alignment: Alignment.center,
              child: widget.builder(context, _animationKey),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveCardExample extends StatefulWidget {
  @override
  State<_InteractiveCardExample> createState() => _InteractiveCardExampleState();
}

class _InteractiveCardExampleState extends State<_InteractiveCardExample> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Card Hover', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Interactive MouseRegion', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Center(
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isHovered
                        ? [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))]
                        : [],
                  ),
                  transform: Matrix4.diagonal3Values(_isHovered ? 1.05 : 1.0, _isHovered ? 1.05 : 1.0, 1.0),
                  transformAlignment: Alignment.center,
                  alignment: Alignment.center,
                  child: const Text('Hover Me'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveButtonExample extends StatefulWidget {
  @override
  State<_InteractiveButtonExample> createState() => _InteractiveButtonExampleState();
}

class _InteractiveButtonExampleState extends State<_InteractiveButtonExample> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Button Press', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Interactive GestureDetector', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  width: 140,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  transform: Matrix4.diagonal3Values(_isPressed ? 0.95 : 1.0, _isPressed ? 0.95 : 1.0, 1.0),
                  transformAlignment: Alignment.center,
                  alignment: Alignment.center,
                  child: Text('Press Me', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
