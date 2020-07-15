import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, String> currencySymbol = {
  'INR': '₹',
  'USD': '\$',
  'GBP': '£',
  'YEN': '¥',
};

String _currentSelected = 'INR';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, [currencySymbol[_currentSelected]]);
          },
        ),
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.ubuntu(
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: Body(),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String _platOS = Platform.operatingSystem;
  String _platOSVersion = Platform.operatingSystemVersion;
  String _platVersion = Platform.version;

  _getCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentSelected = (prefs.getString('sym') ?? 'INR');
    });
  }

  _setCurrency(String sym) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sym', sym);
  }

  @override
  void initState() {
    _getCurrency();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Currency: ',
                style: GoogleFonts.exo(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              DropdownButton<String>(
                items: <String>['INR', 'USD', 'GBP', 'YEN'].map((String temp) {
                  return DropdownMenuItem<String>(
                    value: temp,
                    child: Text(
                      '${temp} (${currencySymbol[temp]})',
                      style: GoogleFonts.exo(
                        fontSize: 20,
                      ),
                    ),
                  );
                }).toList(),
                //value: _currentSelected,
                onChanged: (val) {
                  _setCurrency(val);
                  setState(() {
                    _currentSelected = val;
                    print(_currentSelected);
                  });
                },
                value: _currentSelected,
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 40, bottom: 20),
            width: 250,
            height: 100,
            child: RaisedButton.icon(
              icon: Icon(Icons.mail),
              onPressed: () async {
                dynamic email =
                    "mailto:ceroystudios@gmail.com?subject=Support[]&body=[Please don't edit the following\n\n\n\n ${_platOS} \n ${_platOSVersion} \n ${_platVersion}]\n\nWrite Below";
                if (await canLaunch(email)) {
                  await launch(email);
                } else {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Error in link opening')));
                }
              },
//              onPressed: () {
//                print(Platform.operatingSystem);
//                print(Platform.operatingSystemVersion);
//                print(Platform.version);
//              },
              label: Text(
                'Support',
                style: GoogleFonts.ubuntu(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 40, top: 20),
            width: 250,
            height: 100,
            child: RaisedButton.icon(
              icon: Icon(Icons.attach_money),
              onPressed: () async {
                const url = 'https://ceroy.io/donate';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Error in link opening')));
                }
              },
              label: Text(
                'Donate',
                style: GoogleFonts.ubuntu(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          Text(
            '\n\n\n\nMade with Love in India \n        by @ceroy_ak',
            style: GoogleFonts.roboto(
              fontSize: 25,
            ),
          )
        ],
      ),
    );
  }
}
