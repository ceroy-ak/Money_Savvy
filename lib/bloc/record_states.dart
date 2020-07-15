import 'package:moneysavvy/models/expenseDataClass.dart';

abstract class RecordState {}

class RecordEmptyState extends RecordState {}

class RecordLoadingState extends RecordState {}

class RecordLoadedState extends RecordState {
  List<ExpenseData> records;
  RecordLoadedState(this.records);
}

class RecordPastLoadedState extends RecordState {
  List<ExpenseData> records;
  RecordPastLoadedState(this.records);
}

class RecordErrorState extends RecordState {}
