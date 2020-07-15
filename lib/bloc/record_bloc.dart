import 'package:moneysavvy/Database/databaseProvider.dart';
import 'package:moneysavvy/models/expenseDataClass.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'record_events.dart';
import 'record_states.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  RecordState get initialState => RecordLoadingState();

  RecordBloc(RecordState initialState) : super(initialState);

  @override
  void onTransition(Transition<RecordEvent, RecordState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  @override
  Stream<RecordState> mapEventToState(RecordEvent event) async* {
    try {
      List<ExpenseData> records;
      if (event is ShowRecords) {
        yield RecordLoadingState();
        records = await DatabaseProvider.db.fetchRecords();
        if (records.length == 0)
          yield RecordEmptyState();
        else
          yield RecordLoadedState(records);
      } else if (event is ShowPastRecords) {
        yield RecordLoadingState();
        records = await DatabaseProvider.db.fetchPastRecords(event.dateTime);
        if (records.length == 0)
          yield RecordEmptyState();
        else
          yield RecordPastLoadedState(records);
      } else if (event is DeleteRecord) {
        yield RecordLoadingState();
        records = await DatabaseProvider.db.fetchRecords();
        yield RecordLoadedState(records);
      } else if (event is AddRecord) {
        yield RecordLoadingState();
        records = await DatabaseProvider.db.fetchRecords();
        yield RecordLoadedState(records);
      } else if (event is UpdateRecord) {
        yield RecordLoadingState();
        records = await DatabaseProvider.db.fetchRecords();
        yield RecordLoadedState(records);
      } else
        yield RecordLoadingState();
    } catch (_) {
      yield RecordErrorState();
    }
  }
}
