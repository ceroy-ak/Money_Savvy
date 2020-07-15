import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneysavvy/bloc/record_bloc.dart';
import 'package:moneysavvy/bloc/record_states.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class PieChartDraw extends StatelessWidget {
  Map<String, double> dataMap = {
    'Remaining': 1,
    'Used': 1,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordBloc, RecordState>(builder: (context, state) {
      if (state is RecordLoadedState) {
        double _credits = 0;
        double _debits = 0;
        state.records.forEach((element) {
          if (element.type == 0)
            _debits += element.amount.toDouble();
          else
            _credits += element.amount.toDouble();
        });
        dataMap['Used'] = _debits;
        dataMap['Remaining'] = _credits - _debits;
      }
      return Container(
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32.0,
          chartRadius: MediaQuery.of(context).size.width / 2.7,
          showChartValuesInPercentage: false,
          showChartValues: true,
          showChartValuesOutside: false,
          chartValueBackgroundColor: Colors.grey[200],
          showLegends: true,
          legendPosition: LegendPosition.right,
          decimalPlaces: 1,
          showChartValueLabel: true,
          initialAngle: 0,
          chartValueStyle: defaultChartValueStyle.copyWith(
            color: Colors.black,
          ),
          chartType: ChartType.ring,
          colorList: [
            Colors.green.withOpacity(0.9),
            Colors.red.withOpacity(0.9)
          ],
        ),
      );
    });
  }
}

class IncomePieChart extends StatelessWidget {
  Map<String, double> dataMap = Map();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        if (state is RecordLoadedState) {
          state.records.forEach((element) {
            if (element.type == 1) {
              if (dataMap[element.category] == null)
                dataMap[element.category] = 0;
              dataMap[element.category] += element.amount.toDouble();
            }
          });
        }
        return Container(
          child: PieChart(
            dataMap: dataMap,
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32.0,
            chartRadius: MediaQuery.of(context).size.width / 3,
            showChartValuesInPercentage: false,
            showChartValues: true,
            showChartValuesOutside: false,
            chartValueBackgroundColor: Colors.grey[200],
            showLegends: true,
            legendPosition: LegendPosition.right,
            decimalPlaces: 1,
            showChartValueLabel: true,
            initialAngle: 0,
            chartValueStyle: defaultChartValueStyle.copyWith(
              color: Colors.black,
            ),
            colorList: [
              Colors.red,
              Colors.orange,
              Colors.green,
              Colors.black,
              Colors.blue,
              Colors.teal,
              Colors.yellow,
              Colors.cyan,
              Colors.deepPurpleAccent
            ]..shuffle(),
            chartType: ChartType.ring,
            //colorList: [Colors.green.withOpacity(0.9), Colors.red.withOpacity(0.9)],
          ),
        );
      },
    );
  }
}

class ExpensePieChart extends StatelessWidget {
  Map<String, double> dataMap = Map();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordBloc, RecordState>(builder: (context, state) {
      if (state is RecordLoadedState) {
        state.records.forEach((element) {
          if (element.type == 0) {
            if (dataMap[element.category] == null)
              dataMap[element.category] = 0;
            dataMap[element.category] += element.amount.toDouble();
          }
        });
      } else
        dataMap['Nothing'] = 0;
      return Container(
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32.0,
          chartRadius: MediaQuery.of(context).size.width / 3,
          showChartValuesInPercentage: false,
          showChartValues: false,
          showChartValuesOutside: false,
          chartValueBackgroundColor: Colors.grey[200],
          showLegends: true,
          legendPosition: LegendPosition.right,
          decimalPlaces: 1,
          showChartValueLabel: true,
          initialAngle: 0,
          chartValueStyle: defaultChartValueStyle.copyWith(
            color: Colors.black,
          ),
          chartType: ChartType.ring,
          colorList: [
            Colors.red,
            Colors.orange,
            Colors.green,
            Colors.black,
            Colors.blue,
            Colors.teal,
            Colors.yellow,
            Colors.cyan,
            Colors.deepPurpleAccent
          ]..shuffle(),
        ),
      );
    });
  }
}
