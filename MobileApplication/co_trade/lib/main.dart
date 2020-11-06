import 'package:co_trade/loading_page.dart';
import 'package:co_trade/trader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Provider<Trader>(
      create: (context) => Trader(),
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoTrade',
      theme: ThemeData.dark().copyWith(
        primaryColor: kDarkBlue,
        scaffoldBackgroundColor: kSlightDarkBlue,
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'NunitoSans',
        ),
        primaryTextTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'NunitoSans',
        ),
        accentTextTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'NunitoSans',
        ),
      ),
      home: LoadingPage(),
    );
  }
}
