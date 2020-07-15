import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moneysavvy/Screens/HomePage.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneysavvy/bloc/record_bloc.dart';
import 'package:moneysavvy/bloc/record_states.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecordBloc>(
      create: (context) => RecordBloc(RecordEmptyState()),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
