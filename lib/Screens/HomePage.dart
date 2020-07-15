import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneysavvy/Database/databaseProvider.dart';
import 'package:moneysavvy/bloc/record_bloc.dart';
import 'package:moneysavvy/bloc/record_events.dart';
import 'package:moneysavvy/bloc/record_states.dart';
import 'package:path/path.dart';
import 'package:moneysavvy/Charts/Charts.dart';
import 'package:moneysavvy/Screens/settingsScreen.dart';
import 'package:moneysavvy/Screens/recordsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddRecord.dart';
import 'package:get/get.dart';
import 'package:moneysavvy/models/expenseDataClass.dart';
import 'package:moneysavvy/models/categoriesClass.dart';

String _currencySymbol = "₹";

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = PageController(
    viewportFraction: 0.8,
    initialPage: 0,
  );

  _currencyUpdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currencySymbol = currencySymbol[(prefs.getString('sym') ?? 'INR')];
    });
  }

  @override
  void initState() {
    _currencyUpdate();

    BlocProvider.of<RecordBloc>(this.context).add(ShowRecords());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: floatingActionButtonMethod(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(
          'Money Savvy',
          style: GoogleFonts.ubuntu(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SettingsScreen();
                })).then((value) {
                  print('The symbol got is ${value[0]}');
                  setState(() {
                    _currencySymbol = value[0];
                  });
                });
              })
        ],
      ),
      body: PageView(
        pageSnapping: true,
        controller: controller,
        children: <Widget>[
          TotalWithChart(),
          IncomeExpensePieChart(),
          ViewAll(),
        ],
      ),
    );
  }
}

FloatingActionButton floatingActionButtonMethod(BuildContext context) {
  return FloatingActionButton.extended(
    elevation: 10,
    onPressed: () {
      Get.to(AddItem(null));
    },
    icon: Icon(
      Icons.add,
      //size: 30,
    ),
    label: Text(
      'Add Record',
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    foregroundColor: Colors.white,
    backgroundColor: Colors.black.withOpacity(0.7),
  );
}

class TotalWithChart extends StatelessWidget {
  Widget totalText(double _val) {
    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.fitWidth,
      child: Text(
        '$_currencySymbol $_val',
        style: GoogleFonts.lato(
          fontSize: 50,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget totCredDebRow(double credit, double debit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Total Credit'),
            FittedBox(
              child: Text('$_currencySymbol $credit'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Total Debit'),
            FittedBox(
              child: Text('$_currencySymbol $debit'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
          ],
        ),
      ],
    );
  }

  Widget iconStatus(_credit, _debit) {
    if (_credit - _debit > (_credit / 4))
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.thumb_up,
            color: Colors.green,
          ),
          SizedBox(
            width: 10,
          ),
          Text('Keep it Up'),
        ],
      );
    else if (_debit > _credit)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.thumb_down,
            color: Colors.red,
          ),
          SizedBox(
            width: 10,
          ),
          Text('Stop Freaking Spending so Much'),
        ],
      );
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.thumbs_up_down,
            color: Colors.yellow,
          ),
          SizedBox(
            width: 10,
          ),
          Text('Meh'),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 35, 15, 85),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(4, 3),
              blurRadius: 5,
            ),
            BoxShadow(
              color: Colors.grey,
              offset: Offset(-2, -1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Text(
              'BALANCE',
              style: GoogleFonts.exo(
                fontWeight: FontWeight.bold,
                fontSize: 21,
                color: Colors.black,
              ),
            ),
            BlocBuilder<RecordBloc, RecordState>(
              builder: (context, state) {
                double _credit = 0;
                double _debit = 0;
                if (state is RecordLoadedState) {
                  state.records.forEach((element) {
                    if (element.type == 1)
                      _credit += element.amount.toDouble();
                    else
                      _debit += element.amount.toDouble();
                  });
                }
                return Column(
                  children: <Widget>[
                    totalText(_credit - _debit),
                    totCredDebRow(_credit, _debit),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: iconStatus(_credit, _debit),
                    ),
                  ],
                );
              },
            ),
            SizedBox(
              height: 25,
            ),
            PieChartDraw(),
          ],
        ),
      ),
    );
  }
}

class IncomeExpensePieChart extends StatelessWidget {
  double textSize = 20;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 35, 15, 85),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(4, 3),
              blurRadius: 5,
            ),
            BoxShadow(
              color: Colors.grey,
              offset: Offset(-2, -1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'CREDIT',
              style: GoogleFonts.lato(
                fontSize: textSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            IncomePieChart(),
            Divider(
              height: 25,
              thickness: 5,
            ),
            Text(
              'DEBIT',
              style: GoogleFonts.lato(
                fontSize: textSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            ExpensePieChart(),
          ],
        ),
      ),
    );
  }
}

class ViewAll extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 35, 15, 85),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(4, 3),
              blurRadius: 5,
            ),
            BoxShadow(
              color: Colors.grey,
              offset: Offset(-2, -1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton.icon(
                onPressed: () {
                  Get.to(ViewByRecord());
                },
                icon: Icon(Icons.open_in_new),
                label: Text('View Records'))
          ],
        ),
      ),
    );
  }
}
