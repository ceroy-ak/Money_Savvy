import 'package:moneysavvy/models/expenseDataClass.dart';

abstract class RecordEvent {}

class ShowRecords extends RecordEvent {
  ShowRecords();
}

class ShowPastRecords extends RecordEvent {
  DateTime dateTime;
  ShowPastRecords(this.dateTime);
}

class UpdateRecord extends RecordEvent {
  ExpenseData record;
  UpdateRecord(this.record);
}

class DeleteRecord extends RecordEvent {
  int recordIndex;
  DeleteRecord(this.recordIndex);
}

class AddRecord extends RecordEvent {
  ExpenseData record;
  AddRecord(this.record);
}
