import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/lap_button.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/pause_resume_button.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/reset_button.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/layout/button_slot.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/start_button.dart';

class StopwatchControls extends StatelessWidget {
  const new({super.key, this.useCompactLayout = false});

  final bool useCompactLayout;

  @visibleForTesting
  static const landscapeKey = Key("stopwatchControlsLandscape");

  @visibleForTesting
  static const compactKey = Key("stopwatchControlsCompact");

  @visibleForTesting
  static const regularKey = Key("stopwatchControlsRegular");

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact =
            useCompactLayout ||
            MediaQuery.sizeOf(context).width <
                StopwatchConstants.compactControlsBreakpoint;
        final bool landscape = MediaQuery.orientationOf(context) == .landscape;

        if (landscape) {
          return SingleChildScrollView(
            child: Column(
              key: landscapeKey,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: StopwatchConstants.compactSpacing / 2,
              children: [
                StartButton(),
                PauseResumeButton(),
                ResetButton(),
                LapButton(),
              ],
            ),
          );
        }

        if (compact) {
          return Padding(
            key: compactKey,
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: StopwatchConstants.controlSpacing / 4,
              children: [
                Row(
                  spacing: StopwatchConstants.controlSpacing / 4,
                  children: [
                    Expanded(child: StartButton()),
                    Expanded(child: PauseResumeButton()),
                  ],
                ),
                Row(
                  spacing: StopwatchConstants.controlSpacing / 4,
                  children: [
                    Expanded(child: ResetButton()),
                    Expanded(child: LapButton()),
                  ],
                ),
              ],
            ),
          );
        }

        return Padding(
          key: regularKey,
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < StopwatchConstants.baseWidth
                ? 10
                : 0,
          ),
          child: Column(
            spacing: StopwatchConstants.controlSpacing,
            children: [
              Row(
                spacing: StopwatchConstants.controlSpacing,
                children: [
                  Expanded(child: StartButton()),
                  Expanded(child: PauseResumeButton()),
                  Expanded(child: ResetButton()),
                ],
              ),
              ButtonSlot(child: LapButton()),
            ],
          ),
        );
      },
    );
  }
}
