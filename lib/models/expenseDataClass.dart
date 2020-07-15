import 'package:flutter/material.dart';
import 'package:moneysavvy/Database/databaseProvider.dart';

class ExpenseData {
  int id;
  String description;
  double amount;
  String category;
  DateTime date;
  int type;

  ExpenseData(
      {this.id,
      this.description,
      this.amount,
      this.category,
      this.type,
      this.date});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.COLUMN_DESC: description,
      DatabaseProvider.COLUMN_TYPE: type,
      DatabaseProvider.COLUMN_DATE: date.toString().split(' ')[0],
      DatabaseProvider.COLUMN_AMOUNT: amount,
      DatabaseProvider.COLUMN_CAT: category,
    };

    if (id != null) {
      map[DatabaseProvider.COLUMN_ID] = id;
    }

    return map;
  }

  ExpenseData.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.COLUMN_ID];
    description = map[DatabaseProvider.COLUMN_DESC];
    date = DateTime.parse(map[DatabaseProvider.COLUMN_DATE]);
    amount = map[DatabaseProvider.COLUMN_AMOUNT].toDouble();
    category = map[DatabaseProvider.COLUMN_CAT];
    type = map[DatabaseProvider.COLUMN_TYPE];
  }
}
/*
List<ExpenseData> expenseName = [
  ExpenseData('Dominos', 2500, 'Food', 0, DateTime.now()),
  ExpenseData('Medicines', 25000, 'Health', 0, DateTime.now()),
  ExpenseData('Train', 15, 'Travel', 0, DateTime.now()),
  ExpenseData('Pocket Money', 15000, 'Savings', 1, DateTime.now())
];

List<ExpenseData> topDebitData = [
  ExpenseData('Dominos', 2500, 'Food', 0, DateTime.now()),
  ExpenseData('Medicines', 25000, 'Health', 0, DateTime.now()),
  ExpenseData('Train', 15, 'Travel', 0, DateTime.now()),
];

List<ExpenseData> topCreditData = [
  ExpenseData('Savings', 100000, 'Salary', 1, DateTime.now()),
  ExpenseData('Pocket Money', 15000, 'Savings', 1, DateTime.now())
];
*/
