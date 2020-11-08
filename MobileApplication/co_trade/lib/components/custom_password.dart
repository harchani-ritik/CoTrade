import 'package:co_trade/services/constants.dart';
import 'package:flutter/material.dart';

class CustomPasswordInput extends StatefulWidget {
  final String hintText;
  final controller;
  final bool large;

  CustomPasswordInput({this.hintText,this.controller,this.large=true});

  @override
  _CustomPasswordInputState createState() => _CustomPasswordInputState();
}

class _CustomPasswordInputState extends State<CustomPasswordInput> {

  bool passwordVisible=false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: widget.large?18:16),
      child: TextFormField(
        controller: widget.controller,
        obscureText: !passwordVisible,
        cursorColor: Colors.white,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.large?18:16,
        ),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            color: kBrightBlue,
            icon: Icon(passwordVisible?
            Icons.visibility:Icons.visibility_off,
              color: kBrightBlue,
            ),
            onPressed: (){
              setState(() {
                passwordVisible=!passwordVisible;
              });
            },
          ),
          border: InputBorder.none,
          hintText: widget.hintText,
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
