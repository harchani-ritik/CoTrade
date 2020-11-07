import 'package:co_trade/services/constants.dart';
import 'package:flutter/material.dart';

class CustomSearch extends StatelessWidget {
  final Function onChange;
  CustomSearch({this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        color: kDarkBlue,
      ),
      height: 40,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
              child: TextFormField(
                onChanged: onChange,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                    hintText: 'Search Users',
                    border: InputBorder.none),
                cursorColor: Colors.white,
              )),
          Icon(
            Icons.search,
            size: 30,
            color: kBrightBlue,
          ),
        ],
      ),
    );
  }
}
