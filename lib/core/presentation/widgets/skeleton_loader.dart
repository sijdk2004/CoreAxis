import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SkeletonAnimation { shimmer, fade, pulse }

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final SkeletonAnimation animation;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.animation = SkeletonAnimation.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Widget box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    // Apply animation based on enum
    switch (animation) {
      case SkeletonAnimation.shimmer:
        return box.animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1200.ms, 
          color: isDark ? Colors.grey[700] : Colors.grey[100],
        );
      case SkeletonAnimation.fade:
        return box.animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(
          duration: 800.ms,
          begin: 0.4,
          end: 1.0,
        );
      case SkeletonAnimation.pulse:
        return box.animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
          duration: 800.ms,
          begin: const Offset(0.98, 0.98),
          end: const Offset(1.02, 1.02),
        ).fade(
          duration: 800.ms,
          begin: 0.7,
          end: 1.0,
        );
    }
  }
}

// 1. Dashboard Loader
class SkeletonDashboardLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonDashboardLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SkeletonBox(width: double.infinity, height: 120, borderRadius: 16, animation: animation),
            ),
          )),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(flex: 2, child: SkeletonBox(width: double.infinity, height: 300, borderRadius: 16, animation: animation)),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: SkeletonBox(width: double.infinity, height: 300, borderRadius: 16, animation: animation)),
            ],
          ),
        ),
      ],
    );
  }
}

// 2. Card Loader
class SkeletonCardLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonCardLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SkeletonBox(width: 48, height: 48, borderRadius: 24, animation: animation),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 150, height: 16, animation: animation),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 100, height: 12, animation: animation),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SkeletonBox(width: double.infinity, height: 150, borderRadius: 12, animation: animation),
          const SizedBox(height: 24),
          SkeletonBox(width: double.infinity, height: 12, animation: animation),
          const SizedBox(height: 8),
          SkeletonBox(width: 250, height: 12, animation: animation),
        ],
      ),
    );
  }
}

// 3. Table Loader
class SkeletonTableLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonTableLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(5, (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SkeletonBox(width: double.infinity, height: 24, animation: animation),
            ),
          )),
        ),
        const Divider(height: 32),
        ...List.generate(5, (rowIndex) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: List.generate(5, (colIndex) => Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SkeletonBox(width: double.infinity, height: 16, animation: animation),
              ),
            )),
          ),
        )),
      ],
    );
  }
}

// 4. Form Loader
class SkeletonFormLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonFormLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 120, height: 16, animation: animation),
        const SizedBox(height: 8),
        SkeletonBox(width: double.infinity, height: 48, borderRadius: 8, animation: animation),
        const SizedBox(height: 24),
        SkeletonBox(width: 150, height: 16, animation: animation),
        const SizedBox(height: 8),
        SkeletonBox(width: double.infinity, height: 48, borderRadius: 8, animation: animation),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 80, height: 16, animation: animation),
                  const SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 48, borderRadius: 8, animation: animation),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 80, height: 16, animation: animation),
                  const SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 48, borderRadius: 8, animation: animation),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SkeletonBox(width: 150, height: 48, borderRadius: 24, animation: animation),
      ],
    );
  }
}

// 5. Sidebar Loader
class SkeletonSidebarLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonSidebarLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SkeletonBox(width: 150, height: 24, animation: animation),
          ),
          const Divider(),
          ...List.generate(8, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                SkeletonBox(width: 24, height: 24, borderRadius: 4, animation: animation),
                const SizedBox(width: 16),
                SkeletonBox(width: 120, height: 16, animation: animation),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// 6. Chart Loader
class SkeletonChartLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonChartLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 150, height: 20, animation: animation),
              SkeletonBox(width: 100, height: 32, borderRadius: 16, animation: animation),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SkeletonBox(width: 32, height: 100, borderRadius: 4, animation: animation),
              SkeletonBox(width: 32, height: 180, borderRadius: 4, animation: animation),
              SkeletonBox(width: 32, height: 140, borderRadius: 4, animation: animation),
              SkeletonBox(width: 32, height: 220, borderRadius: 4, animation: animation),
              SkeletonBox(width: 32, height: 90, borderRadius: 4, animation: animation),
              SkeletonBox(width: 32, height: 160, borderRadius: 4, animation: animation),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => SkeletonBox(width: 32, height: 12, animation: animation)),
          )
        ],
      ),
    );
  }
}

// 7. Profile Loader
class SkeletonProfileLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonProfileLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkeletonBox(width: 120, height: 120, borderRadius: 60, animation: animation),
        const SizedBox(height: 24),
        SkeletonBox(width: 200, height: 24, animation: animation),
        const SizedBox(height: 8),
        SkeletonBox(width: 150, height: 16, animation: animation),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonBox(width: 100, height: 80, borderRadius: 12, animation: animation),
            const SizedBox(width: 16),
            SkeletonBox(width: 100, height: 80, borderRadius: 12, animation: animation),
            const SizedBox(width: 16),
            SkeletonBox(width: 100, height: 80, borderRadius: 12, animation: animation),
          ],
        )
      ],
    );
  }
}

// 8. Wizard Loader
class SkeletonWizardLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonWizardLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SkeletonBox(width: 40, height: 40, borderRadius: 20, animation: animation),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SkeletonBox(width: double.infinity, height: 4, animation: animation))),
            SkeletonBox(width: 40, height: 40, borderRadius: 20, animation: animation),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SkeletonBox(width: double.infinity, height: 4, animation: animation))),
            SkeletonBox(width: 40, height: 40, borderRadius: 20, animation: animation),
          ],
        ),
        const SizedBox(height: 48),
        SkeletonBox(width: 250, height: 24, animation: animation),
        const SizedBox(height: 16),
        SkeletonBox(width: double.infinity, height: 200, borderRadius: 12, animation: animation),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonBox(width: 100, height: 40, borderRadius: 20, animation: animation),
            SkeletonBox(width: 120, height: 40, borderRadius: 20, animation: animation),
          ],
        )
      ],
    );
  }
}

// 9. Document Loader
class SkeletonDocumentLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonDocumentLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Center(child: SkeletonBox(width: 64, height: 64, borderRadius: 8, animation: animation))),
              const SizedBox(height: 16),
              SkeletonBox(width: double.infinity, height: 12, animation: animation),
              const SizedBox(height: 8),
              SkeletonBox(width: 80, height: 10, animation: animation),
            ],
          ),
        );
      },
    );
  }
}

// 10. Report Loader
class SkeletonReportLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonReportLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 100, height: 16, animation: animation),
              const SizedBox(height: 16),
              SkeletonBox(width: double.infinity, height: 32, borderRadius: 4, animation: animation),
              const SizedBox(height: 16),
              SkeletonBox(width: double.infinity, height: 32, borderRadius: 4, animation: animation),
              const SizedBox(height: 16),
              SkeletonBox(width: double.infinity, height: 32, borderRadius: 4, animation: animation),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 200, height: 32, animation: animation),
                    SkeletonBox(width: 120, height: 40, borderRadius: 8, animation: animation),
                  ],
                ),
                const SizedBox(height: 24),
                SkeletonBox(width: double.infinity, height: 250, borderRadius: 12, animation: animation),
                const SizedBox(height: 24),
                const SkeletonTableLoader(),
              ],
            ),
          ),
        )
      ],
    );
  }
}

// 11. Workflow Canvas Loader
class SkeletonWorkflowCanvasLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonWorkflowCanvasLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simulated connection lines
          Positioned(top: 150, left: 100, right: 100, child: SkeletonBox(width: double.infinity, height: 4, animation: animation)),
          Positioned(top: 250, left: 200, bottom: 100, child: SkeletonBox(width: 4, height: 100, animation: animation)),
          
          // Nodes
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonBox(width: 180, height: 60, borderRadius: 30, animation: animation),
              const SizedBox(height: 60),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(width: 150, height: 80, borderRadius: 12, animation: animation),
                  const SizedBox(width: 100),
                  SkeletonBox(width: 150, height: 80, borderRadius: 12, animation: animation),
                ],
              ),
              const SizedBox(height: 60),
              SkeletonBox(width: 180, height: 60, borderRadius: 30, animation: animation),
            ],
          ),
        ],
      ),
    );
  }
}

// 12. AI Chat Loader
class SkeletonAIChatLoader extends StatelessWidget {
  final SkeletonAnimation animation;
  const SkeletonAIChatLoader({super.key, this.animation = SkeletonAnimation.shimmer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SkeletonBox(width: 250, height: 60, borderRadius: 16, animation: animation),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 40, height: 40, borderRadius: 20, animation: animation),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 300, height: 80, borderRadius: 16, animation: animation),
                        const SizedBox(height: 8),
                        SkeletonBox(width: 200, height: 60, borderRadius: 16, animation: animation),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SkeletonBox(width: 180, height: 50, borderRadius: 16, animation: animation),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 40, height: 40, borderRadius: 20, animation: animation),
                    const SizedBox(width: 12),
                    SkeletonBox(width: 280, height: 100, borderRadius: 16, animation: animation),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
          child: Row(
            children: [
              SkeletonBox(width: 40, height: 40, borderRadius: 20, animation: animation),
              const SizedBox(width: 12),
              Expanded(child: SkeletonBox(width: double.infinity, height: 48, borderRadius: 24, animation: animation)),
              const SizedBox(width: 12),
              SkeletonBox(width: 40, height: 40, borderRadius: 20, animation: animation),
            ],
          ),
        ),
      ],
    );
  }
}
