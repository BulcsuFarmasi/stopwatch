import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/button_slot.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/lap_row.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps_header.dart';
import 'package:stopwatch/l10n/app_strings.dart';

class StopwatchLaps extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ({List<Lap> laps, bool areStopwatchActionsBlocked}) state = ref.watch(
      stopwatchNotifierProvider.select(
        (AsyncValue<StopwatchState> state) => (
          laps: state.value?.laps ?? [],
          areStopwatchActionsBlocked:
              state.value?.areStopwatchActionsBlocked ?? false,
        ),
      ),
    );
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    return Column(
      children: [
        if (state.laps.isNotEmpty) LapsHeader(),
        Expanded(
          child: ListView.separated(
            itemBuilder: (_, int index) => LapRow(lap: state.laps[index]),
            separatorBuilder: (_, _) {
              return Divider(color: AppColors.text);
            },
            itemCount: state.laps.length,
          ),
        ),
        if (state.laps.isNotEmpty)
          Padding(
            padding: EdgeInsetsGeometry.only(
              top: StopwatchConstants.lapsBelowSpacing,
            ),
            child: ButtonSlot(
              child: OutlinedButton(
                onPressed: state.areStopwatchActionsBlocked
                    ? null
                    : () => notifier.clearLaps(),
                child: Text(AppStrings.clearLaps),
              ),
            ),
          ),
      ],
    );
  }
}
