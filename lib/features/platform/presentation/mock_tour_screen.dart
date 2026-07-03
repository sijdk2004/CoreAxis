import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MockTourScreen extends StatefulWidget {
  final String tourId;

  const MockTourScreen({super.key, required this.tourId});

  @override
  State<MockTourScreen> createState() => _MockTourScreenState();
}

class _MockTourScreenState extends State<MockTourScreen> {
  int _currentStep = 0;
  
  // Hardcoded mock steps for any tour, representing different "highlights"
  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Welcome to the Tour',
      'description': 'This is an interactive walkthrough of this feature. Follow along to learn the basics.',
      'alignment': Alignment.center,
      'cutoutSize': const Size(0, 0),
    },
    {
      'title': 'The Sidebar Menu',
      'description': 'Use this menu to navigate between different modules of the application.',
      'alignment': Alignment.centerLeft,
      'cutoutSize': const Size(250, 400),
    },
    {
      'title': 'Top Navigation Bar',
      'description': 'Search for anything globally, access your profile, or toggle dark mode.',
      'alignment': Alignment.topCenter,
      'cutoutSize': const Size(600, 60),
    },
    {
      'title': 'Primary Action Area',
      'description': 'This is where you initiate core actions for this module (e.g., Create New).',
      'alignment': Alignment.topRight,
      'cutoutSize': const Size(200, 100),
    },
    {
      'title': 'Main Content View',
      'description': 'Your data will appear here. You can filter, sort, and paginate through records.',
      'alignment': Alignment.center,
      'cutoutSize': const Size(600, 300),
    }
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      context.pop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipTour() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final alignment = step['alignment'] as Alignment;
    final cutoutSize = step['cutoutSize'] as Size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Simulated Background Application
          const _MockApplicationBackground(),
          
          // Tour Overlay Custom Painter
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _TourOverlayPainter(
                  cutoutAlignment: alignment,
                  cutoutSize: cutoutSize,
                  overlayColor: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ),
          
          // Tooltip Card Positioning
          Align(
            alignment: _getTooltipAlignment(alignment),
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surface,
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.info, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step['title'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 18),
                            onPressed: _skipTour,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step['description'],
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step ${_currentStep + 1} of ${_steps.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Row(
                            children: [
                              if (_currentStep > 0)
                                TextButton(
                                  onPressed: _previousStep,
                                  child: const Text('Back'),
                                ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: _nextStep,
                                child: Text(_currentStep == _steps.length - 1 ? 'Finish' : 'Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment _getTooltipAlignment(Alignment cutoutAlignment) {
    if (cutoutAlignment == Alignment.center) return Alignment.center;
    if (cutoutAlignment == Alignment.centerLeft) return Alignment.centerRight;
    if (cutoutAlignment == Alignment.topCenter) return Alignment.center;
    if (cutoutAlignment == Alignment.topRight) return Alignment.center;
    return Alignment.center;
  }
}

class _MockApplicationBackground extends StatelessWidget {
  const _MockApplicationBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          // Sidebar mock
          Container(
            width: 250,
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                Container(height: 60, color: theme.colorScheme.primary.withOpacity(0.1)),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index) => ListTile(
                      leading: Icon(LucideIcons.box, color: theme.colorScheme.onSurfaceVariant),
                      title: Container(height: 12, color: theme.colorScheme.surfaceContainerHighest),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Main content area mock
          Expanded(
            child: Column(
              children: [
                // Topbar mock
                Container(
                  height: 60,
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(LucideIcons.bell, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 16),
                      CircleAvatar(backgroundColor: theme.colorScheme.primary.withOpacity(0.2)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Dashboard body mock
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 200, height: 32, color: theme.colorScheme.surfaceContainerHighest),
                            Container(
                              width: 120,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: ListView.separated(
                              itemCount: 5,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) => ListTile(
                                title: Container(width: double.infinity, height: 16, color: theme.colorScheme.surfaceContainerHighest),
                                subtitle: Container(width: 100, height: 12, color: theme.colorScheme.surfaceContainerHighest),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TourOverlayPainter extends CustomPainter {
  final Alignment cutoutAlignment;
  final Size cutoutSize;
  final Color overlayColor;

  _TourOverlayPainter({
    required this.cutoutAlignment,
    required this.cutoutSize,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cutoutSize.isEmpty) {
      canvas.drawColor(overlayColor, BlendMode.srcOver);
      return;
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Calculate cutout rect based on alignment
    double left = 0;
    double top = 0;

    if (cutoutAlignment == Alignment.centerLeft) {
      left = 0;
      top = (size.height - cutoutSize.height) / 2;
    } else if (cutoutAlignment == Alignment.topCenter) {
      left = (size.width - cutoutSize.width) / 2;
      top = 0;
    } else if (cutoutAlignment == Alignment.topRight) {
      left = size.width - cutoutSize.width - 24; // padding
      top = 60 + 24; // topbar height + padding
    } else if (cutoutAlignment == Alignment.center) {
      left = (size.width - cutoutSize.width) / 2;
      top = (size.height - cutoutSize.height) / 2;
    }

    final cutoutRect = Rect.fromLTWH(left, top, cutoutSize.width, cutoutSize.height);
    final rrect = RRect.fromRectAndRadius(cutoutRect, const Radius.circular(8));

    canvas.saveLayer(rect, Paint());
    canvas.drawColor(overlayColor, BlendMode.srcOver);
    canvas.drawRRect(rrect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
    
    // Draw glowing border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.blue.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _TourOverlayPainter oldDelegate) {
    return oldDelegate.cutoutAlignment != cutoutAlignment ||
           oldDelegate.cutoutSize != cutoutSize;
  }
}
