import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/components/search_bar.dart';
import 'package:co_trade/models/nse_share.dart';
import 'package:co_trade/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class StockDetailsPage extends StatefulWidget {
  @override
  _StockDetailsPageState createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  List<NSEShare> shares = [];
  bool isLoading = false;

  _fetchNSEShares() async {
    final db = FirebaseFirestore.instance;
    await for (var snapshots in db.collection('stock_data').snapshots()) {
      List<NSEShare> nseShares = [];
      for (var snapshot in snapshots.docs) {
        nseShares.add(NSEShare(snapshot.id, snapshot.data()['current_price'],
            snapshot.data()['open_price']));
      }
      setState(() => shares=nseShares);
    }
  }

  freeStr(String s){
    String newString = '';
    for(int i=0;i<s.length;i++){
      if(s[i]!=',')
        newString+=s[i];
    }
    return newString;
  }

  @override
  void initState() {
    super.initState();
    _fetchNSEShares();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearch(
              hintText: 'Search Stocks',
              onChange: (value) {},
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shares.length,
              itemBuilder: (context,index){
                double diff = (double.parse(freeStr(shares[index].currentPrice))
                    -double.parse(freeStr(shares[index].openPrice)));
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shares[index].name,
                        style:
                        TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        shares[index].currentPrice,
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        shares[index].openPrice,
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                          width: 70,
                          decoration: BoxDecoration(
                            color: diff>0?kGreen:kRed,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              diff>0?'+${diff.toStringAsFixed(2)}':diff.toStringAsFixed(2),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
