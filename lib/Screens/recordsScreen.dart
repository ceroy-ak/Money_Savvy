import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneysavvy/Database/databaseProvider.dart';
import 'package:moneysavvy/bloc/record_bloc.dart';
import 'package:moneysavvy/bloc/record_events.dart';
import 'package:moneysavvy/bloc/record_states.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart' as sp;
import 'AddRecord.dart';
import 'package:get/get.dart';
import 'package:moneysavvy/models/categoriesClass.dart';
import 'package:moneysavvy/models/expenseDataClass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settingsScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String _currencySymbol = "₹";

class ViewByRecord extends StatefulWidget {
  @override
  _ViewByRecordState createState() => _ViewByRecordState();
}

class _ViewByRecordState extends State<ViewByRecord> {
  DateTime selectedDate;

  _currencyUpdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currencySymbol = currencySymbol[(prefs.getString('sym') ?? 'INR')];
    });
  }

  @override
  void initState() {
    super.initState();
    _currencyUpdate();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Records',
          style: GoogleFonts.ubuntu(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              BlocProvider.of<RecordBloc>(context).add(ShowRecords());
              Get.back();
            }),
      ),
      body: RecordsList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.calendar_today,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        elevation: 15,
        onPressed: () {
          showMonthPicker(
            context: context,
            firstDate: DateTime(DateTime.now().year - 1, 5),
            lastDate: DateTime(DateTime.now().year + 1, 9),
            initialDate: selectedDate ?? DateTime.now(),
            locale: Locale("en"),
          ).then((date) {
            if (date != null) {
              setState(() {
                selectedDate = date;
                print(DateFormat('yMMMM').format(selectedDate));
              });
              BlocProvider.of<RecordBloc>(context)
                  .add(ShowPastRecords(selectedDate));
            }
          });
        },
      ),
    );
  }
}

class RecordsList extends StatefulWidget {
  @override
  _RecordsListState createState() => _RecordsListState();
}

class _RecordsListState extends State<RecordsList> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<RecordBloc>(context).add(ShowRecords());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecordBloc, RecordState>(
      //bloc: _bloc,
      listener: (context, state) {
        if (state is RecordEmptyState) {
          return Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('No Records Found'),
            ),
          );
        } else if (state is RecordLoadingState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is RecordErrorState) {
          return Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Something Definitely went wrong'),
            ),
          );
        } else {
          return Container(
            width: 0,
            height: 0,
          );
        }
      },
      builder: (context, state) {
        double _credit = 0, _debit = 0;
        if (state is RecordLoadedState) {
          state.records.forEach((element) {
            if (element.type == 1)
              _credit += element.amount.toDouble();
            else
              _debit += element.amount.toDouble();
          });
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text('BALANCE'),
                      Text('$_currencySymbol ${_credit - _debit}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text('CREDIT'),
                          Text('$_currencySymbol $_credit'),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text('DEBIT'),
                          Text('$_currencySymbol $_debit'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 10,
                    thickness: 5,
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 90, top: 20),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return sp.Slidable(
                        actionPane: sp.SlidableStrechActionPane(),
                        actions: <Widget>[
                          sp.IconSlideAction(
                            caption: 'Edit',
                            color: Colors.green,
                            icon: Icons.edit,
                            onTap: () {
                              print('Edit');
                              Get.to(AddItem(state.records[index]));
                            },
                          ),
                        ],
                        secondaryActions: <Widget>[
                          sp.IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete_forever,
                            onTap: () {
                              print('Delete');
                              DatabaseProvider.db
                                  .deleteRecord(state.records[index].id)
                                  .then((value) {
                                BlocProvider.of<RecordBloc>(context)
                                    .add(DeleteRecord(value));
                              });
                            },
                          ),
                        ],
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.grey,
                          child: ListTile(
                            isThreeLine: true,
                            title: Text(state.records[index].description),
                            trailing: Text(
                              '${_currencySymbol} ${state.records[index].amount.toString()} ',
                              style: GoogleFonts.ubuntu(
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text(
                                '${DateFormat('d MMM y').format(state.records[index].date)} \n${state.records[index].category}'),
                            leading: (state.records[index].type == 1)
                                ? Icon(
                                    category[state.records[index].category],
                                    color: Colors.green,
                                  )
                                : Icon(
                                    category[state.records[index].category],
                                    color: Colors.red,
                                  ),
                          ),
                        ),
                      );
                    },
                    itemCount: state.records.length,
                  ),
                ],
              ),
            ),
          );
        } else if (state is RecordPastLoadedState) {
          state.records.forEach((element) {
            if (element.type == 1)
              _credit += element.amount.toDouble();
            else
              _debit += element.amount.toDouble();
          });
          return SingleChildScrollView(
            child: Flexible(
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text('BALANCE'),
                      Text('$_currencySymbol ${_credit - _debit}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text('TOTAL CREDIT'),
                          Text('$_currencySymbol $_credit'),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text('TOTAL DEBIT'),
                          Text('$_currencySymbol $_debit'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 10,
                    thickness: 5,
                  ),
                  ListView.builder(
                    padding: EdgeInsets.only(bottom: 90, top: 20),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return sp.Slidable(
                        actionPane: sp.SlidableStrechActionPane(),
                        actions: <Widget>[
                          sp.IconSlideAction(
                            caption: 'Edit',
                            color: Colors.green,
                            icon: Icons.edit,
                            onTap: () {
                              print('Edit');
                              Get.to(AddItem(state.records[index]));
                            },
                          ),
                        ],
                        secondaryActions: <Widget>[
                          sp.IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete_forever,
                            onTap: () {
                              print('Delete');
                              DatabaseProvider.db
                                  .deleteRecord(state.records[index].id)
                                  .then((value) {
                                BlocProvider.of<RecordBloc>(context)
                                    .add(DeleteRecord(value));
                              });
                            },
                          ),
                        ],
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.grey,
                          child: ListTile(
                            isThreeLine: true,
                            title: Text(state.records[index].description),
                            trailing: Text(
                              '${_currencySymbol} ${state.records[index].amount.toString()} ',
                              style: GoogleFonts.ubuntu(
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text(
                                '${DateFormat('d MMM y').format(state.records[index].date)} \n${state.records[index].category}'),
                            leading: (state.records[index].type == 1)
                                ? Icon(
                                    category[state.records[index].category],
                                    color: Colors.green,
                                  )
                                : Icon(
                                    category[state.records[index].category],
                                    color: Colors.red,
                                  ),
                          ),
                        ),
                      );
                    },
                    itemCount: state.records.length,
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            width: 0,
            height: 0,
            child: Center(
              child: Text('No Records Found'),
            ),
          );
        }
      },
    );
  }
}
