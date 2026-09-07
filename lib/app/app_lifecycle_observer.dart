import 'package:flutter/material.dart';

class AppLifecycleObserver extends StatefulWidget {
  const new({
    super.key,
    required this.onVisible,
    required this.onHidden,
    required this.child,
  });

  final VoidCallback onVisible;
  final VoidCallback onHidden;
  final Widget child;

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    final WidgetsBinding widgetsBinding = WidgetsBinding.instance;

    widgetsBinding.addObserver(this);

    widgetsBinding.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (widgetsBinding.lifecycleState case final state?) {
        _mapLifecycleStateToCallBack(state);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _mapLifecycleStateToCallBack(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _mapLifecycleStateToCallBack(AppLifecycleState state) {
    switch (state) {
      case .resumed:
      case .inactive:
        widget.onVisible();
        break;
      case .hidden:
      case .paused:
      case .detached:
        widget.onHidden();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
