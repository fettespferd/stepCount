import 'package:flutter/material.dart';
import 'package:stepCalc/app/module.dart';
import 'package:stepCalc/settings/preferences.dart';
import 'utils.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../main.dart';
part 'cubit.freezed.dart';

class StepCounter extends Cubit<StepCounterState> {
  StepCounter() : super(StepCounterState.initial());

  Future<void> setTargetSteps(int selectedTargetSteps) async {
    UserPreferences().targetSteps = selectedTargetSteps;
    emit(StepCounterState.newTarget(selectedTargetSteps));
  }

  Future<void> toggleNotification() async {
    emit(StepCounterState.toggleNotification());
    emit(StepCounterState.success());
    return;
  }

  Future<void> syncData(double weight, int height) async {
    emit(StepCounterState.isLoading());
    var _healthDataList = <HealthDataPoint>[];
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = now;

    final health = HealthFactory();

    /// Define the types to get.
    final types = <HealthDataType>[HealthDataType.STEPS];

    /// Fetch new data
    final healthData =
        await health.getHealthDataFromTypes(startDate, endDate, types);

    /// Save all the new data points
    _healthDataList.addAll(healthData);

    /// Filter out duplicates
    _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
    // ignore: omit_local_variable_types
    final int totalSteps = _healthDataList.fold(
        0,
        (previousValue, element) =>
            previousValue.toInt() + element.value.toInt());

    //Calc calories
    final totalCalories = calcCalories(weight, height, totalSteps);

    emit(StepCounterState.resynched(totalSteps, totalCalories));
  }

  Future<void> scheduleNotification(BuildContext context,
      {bool notificationsAllowed}) async {
    final now = tz.TZDateTime.now(local);
    final reminderTime = now;
    //tz.TZDateTime.local(now.year, now.month, now.day, 20, 00);
    if (notificationsAllowed) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          context.s.stepCalc_goalmissed,
          context.s.stepCalc_motivation,
          reminderTime.add(const Duration(seconds: 5)),
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'channel ID', 'stepCalc', 'Calc Steps per day')),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }
}

@freezed
abstract class StepCounterState with _$StepCounterState {
  const factory StepCounterState.initial() = _InitialState;
  const factory StepCounterState.initialized(int targetSteps) =
      _InitializedState;
  const factory StepCounterState.isLoading() = _LoadingState;
  const factory StepCounterState.resynched(int totalSteps, int totalCalories) =
      _ResynchedState;
  const factory StepCounterState.newTarget(int selectedTargetSteps) =
      _NewTargetState;
  const factory StepCounterState.toggleNotification() = _ToggeledState;
  const factory StepCounterState.success() = _SuccessState;

  const factory StepCounterState.reset() = _ResetState;
}
