import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

enum ToastType { success, error, warning, info, progress, undo }
enum ToastPosition { topRight, bottomRight, bottomCenter }

class ToastRequest {
  final String id;
  final ToastType type;
  final String title;
  final String? message;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final ToastPosition position;

  ToastRequest({
    required this.id,
    required this.type,
    required this.title,
    this.message,
    required this.duration,
    this.actionLabel,
    this.onAction,
    required this.position,
  });
}

class PlatformToastService {
  static final PlatformToastService _instance = PlatformToastService._internal();
  factory PlatformToastService() => _instance;
  PlatformToastService._internal();

  OverlayEntry? _overlayEntry;
  final List<ToastRequest> _activeToasts = [];
  final GlobalKey<_ToastOverlayManagerState> _managerKey = GlobalKey();

  void init(BuildContext context) {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastOverlayManager(key: _managerKey, service: this),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void showToast(
    BuildContext context, {
    required ToastType type,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    ToastPosition position = ToastPosition.topRight,
  }) {
    init(context);
    
    final request = ToastRequest(
      id: UniqueKey().toString(),
      type: type,
      title: title,
      message: message,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      position: position,
    );

    _activeToasts.add(request);
    _managerKey.currentState?.updateState();
  }

  void removeToast(String id) {
    _activeToasts.removeWhere((t) => t.id == id);
    _managerKey.currentState?.updateState();
  }
}

class _ToastOverlayManager extends StatefulWidget {
  final PlatformToastService service;

  const _ToastOverlayManager({super.key, required this.service});

  @override
  State<_ToastOverlayManager> createState() => _ToastOverlayManagerState();
}

class _ToastOverlayManagerState extends State<_ToastOverlayManager> {
  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group toasts by position
    final topRightToasts = widget.service._activeToasts.where((t) => t.position == ToastPosition.topRight).toList();
    final bottomRightToasts = widget.service._activeToasts.where((t) => t.position == ToastPosition.bottomRight).toList();
    final bottomCenterToasts = widget.service._activeToasts.where((t) => t.position == ToastPosition.bottomCenter).toList();

    return Stack(
      children: [
        if (topRightToasts.isNotEmpty)
          Positioned(
            top: 16,
            right: 16,
            child: _ToastGroup(toasts: topRightToasts, service: widget.service, align: CrossAxisAlignment.end, reverse: false),
          ),
        if (bottomRightToasts.isNotEmpty)
          Positioned(
            bottom: 16,
            right: 16,
            child: _ToastGroup(toasts: bottomRightToasts, service: widget.service, align: CrossAxisAlignment.end, reverse: true),
          ),
        if (bottomCenterToasts.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: _ToastGroup(toasts: bottomCenterToasts, service: widget.service, align: CrossAxisAlignment.center, reverse: true),
            ),
          ),
      ],
    );
  }
}

class _ToastGroup extends StatelessWidget {
  final List<ToastRequest> toasts;
  final PlatformToastService service;
  final CrossAxisAlignment align;
  final bool reverse;

  const _ToastGroup({
    required this.toasts,
    required this.service,
    required this.align,
    required this.reverse,
  });

  @override
  Widget build(BuildContext context) {
    final displayToasts = reverse ? toasts.reversed.toList() : toasts;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: displayToasts.map((toast) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _ToastWidget(
            key: ValueKey(toast.id),
            request: toast,
            onDismiss: () => service.removeToast(toast.id),
          ),
        );
      }).toList(),
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final ToastRequest request;
  final VoidCallback onDismiss;

  const _ToastWidget({super.key, required this.request, required this.onDismiss});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(widget.request.duration, () {
      if (mounted && !_isDismissing) {
        _dismiss();
      }
    });
  }
  
  void _dismiss() {
    setState(() => _isDismissing = true);
    // Let animation run then dismiss
    Future.delayed(300.ms, () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getColor(BuildContext context, ToastType type) {
    switch (type) {
      case ToastType.success: return Colors.green.shade600;
      case ToastType.error: return Colors.red.shade600;
      case ToastType.warning: return Colors.orange.shade600;
      case ToastType.info: return Colors.blue.shade600;
      case ToastType.progress: return Colors.blueAccent.shade700;
      case ToastType.undo: return Colors.grey.shade800;
    }
  }

  IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success: return LucideIcons.checkCircle2;
      case ToastType.error: return LucideIcons.xCircle;
      case ToastType.warning: return LucideIcons.alertTriangle;
      case ToastType.info: return LucideIcons.info;
      case ToastType.progress: return LucideIcons.loader;
      case ToastType.undo: return LucideIcons.undo2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(context, widget.request.type);
    final icon = _getIcon(widget.request.type);

    Widget content = Material(
      color: Colors.transparent,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: theme.dividerColor),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.request.type == ToastType.progress)
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: color, strokeWidth: 2),
                        )
                      else
                        Icon(icon, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.request.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            if (widget.request.message != null) ...[
                              const SizedBox(height: 4),
                              Text(widget.request.message!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                            if (widget.request.actionLabel != null) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () {
                                  widget.request.onAction?.call();
                                  _dismiss();
                                },
                                child: Text(
                                  widget.request.actionLabel!,
                                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _dismiss,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (_isDismissing) {
      return content.animate().fadeOut(duration: 300.ms).slideX(begin: 0, end: 0.2, duration: 300.ms);
    } else {
      return content.animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic, duration: 400.ms);
    }
  }
}
