import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/trader.dart';

class ProfilePage extends StatefulWidget {
  final String traderId;
  ProfilePage(this.traderId);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Trader trader = Trader();

  loadProfile(){
    final db = FirebaseFirestore.instance;

  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
