import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:moneysavvy/Database/databaseProvider.dart';
import 'package:moneysavvy/bloc/record_bloc.dart';
import 'package:moneysavvy/bloc/record_events.dart';
import 'package:moneysavvy/models/expenseDataClass.dart';
import 'recordsScreen.dart';
import 'package:intl/intl.dart';
import 'package:moneysavvy/models/categoriesClass.dart';

bool _isEnabled;
String _initialTitle;
double _initialAmount;
String _currentSelected;
DateTime _dateB;
int _itemIndex;

class AddItem extends StatelessWidget {
  ExpenseData temp;

  AddItem(this.temp) {
    if (this.temp == null) {
      _isEnabled = true;
      _initialTitle = '';
      _initialAmount = 0;
      _currentSelected = category.keys.first;
      _dateB = DateTime.now();
      _itemIndex = null;
    } else {
      _isEnabled = temp.type == 1;
      _initialTitle = temp.description;
      _initialAmount = temp.amount;
      _currentSelected = temp.category;
      _dateB = temp.date;
      _itemIndex = temp.id;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Add Records",
          style: GoogleFonts.ubuntu(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: InputForm(),
    );
  }
}

class InputForm extends StatelessWidget {
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _key,
          child: Column(
            children: <Widget>[
              ChoiceButton(),
              TextFormField(
                initialValue: _initialTitle,
                autovalidate: true,
                decoration: InputDecoration(
                  labelText: "Description",
                ),
                validator: (value) {
                  if (value.isEmpty) return 'Enter Valid Description';
                  if (value.length > 20)
                    return 'Description can only be 20 characters';
                  return null;
                },
                onSaved: (value) {
                  _initialTitle = value;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                initialValue:
                    (_initialAmount == 0) ? null : _initialAmount.toString(),
                decoration: InputDecoration(
                  labelText: "Amount",
                ),
                onSaved: (value) {
                  _initialAmount = double.parse(value);
                },
                autovalidate: true,
                validator: (value) {
                  if (value.split('.').length > 2)
                    return 'Not a valid Amount';
                  else {
                    try {
                      double.parse(value);
                      if (value.split('.').length > 1) {
                        if (value.split('.')[1].length > 2)
                          return 'Only 2 decimal places allowed';
                        if (value.split('.')[0].length > 8)
                          return "You're using the wrong app xD";
                      } else if (value.length > 8)
                        return "You're using the wrong app xD";
                    } catch (e) {
                      return 'Not a valid Amount';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  DropDownItems(_currentSelected ?? 'Food'),
                  DateTimePicker(DateFormat('d MMM y').format(_dateB)),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton.icon(
                onPressed: () {
                  if (_key.currentState.validate()) {
                    _key.currentState.save();

                    if (_itemIndex == null) {
                      ExpenseData temp = ExpenseData(
                          description: _initialTitle,
                          amount: _initialAmount,
                          category: _currentSelected,
                          date: _dateB,
                          type: (_isEnabled) ? 1 : 0);

                      DatabaseProvider.db.insertRecord(temp).then((value) {
                        BlocProvider.of<RecordBloc>(context)
                            .add(AddRecord(temp));
                      });
                    } else {
                      ExpenseData temp = ExpenseData(
                          id: _itemIndex,
                          description: _initialTitle,
                          amount: _initialAmount,
                          category: _currentSelected,
                          date: _dateB,
                          type: (_isEnabled) ? 1 : 0);

                      DatabaseProvider.db.updateRecord(temp).then((value) {
                        BlocProvider.of<RecordBloc>(context)
                            .add(UpdateRecord(temp));
                      });
                    }
                    Get.back();
                  } else
                    Get.snackbar('Form Error', 'Please Check the values');
                },
                icon: Icon(Icons.save),
                label: Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChoiceButton extends StatefulWidget {
  @override
  _ChoiceButtonState createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<ChoiceButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ChoiceChip(
            selectedColor: Colors.green,
            disabledColor: Colors.grey,
            elevation: 2,
            avatar: Icon(
              Icons.add_circle_outline,
              color: Colors.white,
            ),
            labelStyle: GoogleFonts.lato(
              fontSize: 20,
            ),
            labelPadding: EdgeInsets.fromLTRB(2, 4, 15, 4),
            label: Text('Credit'),
            selected: _isEnabled,
            onSelected: (val) {
              setState(() {
                _isEnabled = !_isEnabled;
              });
            },
          ),
          ChoiceChip(
            selectedColor: Colors.red,
            disabledColor: Colors.grey,
            elevation: 2,
            avatar: Icon(
              Icons.remove_circle_outline,
              color: Colors.white,
            ),
            labelStyle: GoogleFonts.lato(
              fontSize: 20,
            ),
            labelPadding: EdgeInsets.fromLTRB(2, 4, 15, 4),
            label: Text('Debit'),
            selected: !_isEnabled,
            onSelected: (val) {
              setState(() {
                _isEnabled = !_isEnabled;
              });
            },
          ),
        ],
      ),
    );
  }
}

class DropDownItems extends StatefulWidget {
  String _prevCat;
  DropDownItems(@required this._prevCat);
  @override
  _DropDownItemsState createState() => _DropDownItemsState();
}

class _DropDownItemsState extends State<DropDownItems> {
  @override
  void initState() {
    super.initState();
    _currentSelected = widget._prevCat;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: category.keys.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: <Widget>[
              Icon(category[value]),
              SizedBox(
                width: 10,
              ),
              Text(value)
            ],
          ),
        );
      }).toList(),
      //value: _currentSelected,
      onChanged: (val) {
        setState(() {
          _currentSelected = val;
          print(_currentSelected);
        });
      },
      value: _currentSelected,
    );
  }
}

class DateTimePicker extends StatefulWidget {
  String _date;
  DateTimePicker(@required this._date);
  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  //String _date = 'Pick a Date';
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 1),
        child: FlatButton(
          onPressed: () {
            dateFunc(context);
          },
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.calendar_today,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    widget._date,
                    style: GoogleFonts.exo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future dateFunc(context) async {
    DateTime _picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2001),
        lastDate: DateTime.now());
    //print((_picked == null) ? "NULL" : _picked.toString().split(' ')[0]);
    if (_picked == null) {
      setState(() {
        widget._date = 'Something went wrong';
      });
    } else {
      setState(() {
        _dateB = _picked;
        widget._date = DateFormat('d MMM y').format(_dateB);
      });
    }
  }
}
