import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/shared/widgets/app_lifecycle_observer.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/layout/stopwatch_landscape.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/layout/stopwatch_portrait.dart';
import 'package:stopwatch/l10n/app_strings.dart';
import 'package:stopwatch/shared/widgets/stopwatch_alert_dialog.dart';

class StopwatchScreen extends ConsumerWidget {
  const StopwatchScreen({super.key});

  void displaySnackbar(BuildContext context, String contentText) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(contentText)));
  }

  void displayReadFailedAlert(BuildContext context, WidgetRef ref) {
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    showStopwatchAlertDialog(
      context,
      StopwatchAlertDialog(
        title: AppStrings.errorReadFailedTitle,
        description: AppStrings.errorReadFailedDescription,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await notifier.clearSavedSession();
            },
            child: Text(AppStrings.errorReadFailedDiscard),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await notifier.retrySessionRestore();
            },
            child: Text(AppStrings.errorTryAgain),
          ),
        ],
      ),
    );
  }

  void displayClearFailedAlert(BuildContext context, WidgetRef ref) {
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    showStopwatchAlertDialog(
      context,
      StopwatchAlertDialog(
        title: AppStrings.errorClearFailedTitle,
        description: AppStrings.errorClearFailedDescription,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await notifier.clearSavedSession();
            },
            child: Text(AppStrings.errorTryAgain),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    ref.listen(
      stopwatchNotifierProvider.select((state) => state.value?.sessionIssue),
      (_, SessionIssue? next) {
        switch (next) {
          case .invalidSavedSession:
            displaySnackbar(context, AppStrings.errorInvalidSession);
            notifier.acknowledgeInvalidSavedSession();
            break;
          case .readFailed:
            displayReadFailedAlert(context, ref);
            break;
          case .clearFailed:
            displayClearFailedAlert(context, ref);
            break;
          case .saveFailed:
            displaySnackbar(context, AppStrings.errorSaveFailed);
          default:
        }
      },
    );

    return AppLifecycleObserver(
      onVisible: () => notifier.startRefresh(),
      onHidden: () => notifier.stopRefresh(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.appTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: SafeArea(
          top: false,
          child: switch (MediaQuery.orientationOf(context)) {
            .portrait => StopwatchPortrait(),
            .landscape => StopwatchLandscape(),
          },
        ),
      ),
    );
  }
}
