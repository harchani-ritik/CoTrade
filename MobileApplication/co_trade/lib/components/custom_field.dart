import 'package:flutter/material.dart';

import '../services/constants.dart';

class CustomField extends StatelessWidget {

  final String hintText;
  final controller;
  final bool large;

  CustomField({this.hintText,this.controller,this.large=true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large?18:16),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.white,
        style: TextStyle(
            color: Colors.white,
            fontSize: large?18:16,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
      decoration: BoxDecoration(
          color: kDarkBlue,
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      width: 260,
    );
  }
}
