import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/button_slot.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/lap_row.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps_header.dart';

class StopwatchLaps extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Lap> laps = ref.watch(
      stopwatchNotifierProvider.select((StopwatchState state) => state.laps),
    );
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );
    return Column(
      children: [
        if (laps.isNotEmpty) LapsHeader(),
        Expanded(
          child: ListView.separated(
            itemBuilder: (_, int index) => LapRow(lap: laps[index]),
            separatorBuilder: (_, _) {
              return Divider(color: AppColors.text);
            },
            itemCount: laps.length,
          ),
        ),
        if (laps.isNotEmpty)
          Padding(
            padding: EdgeInsetsGeometry.only(
              top: StopwatchConstants.lapsBelowSpacing,
            ),
            child: ButtonSlot(
              child: OutlinedButton(
                onPressed: () => notifier.clearLaps(),
                child: Text("Clear laps"),
              ),
            ),
          ),
      ],
    );
  }
}
