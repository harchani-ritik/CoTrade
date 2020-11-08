import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/components/custom_button.dart';
import 'package:co_trade/components/custom_search.dart';
import 'package:co_trade/home_page/profile_page.dart';
import 'package:co_trade/models/nse_share.dart';
import 'package:co_trade/models/trader.dart';
import 'package:co_trade/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class StockDetailsPage extends StatefulWidget {
  @override
  _StockDetailsPageState createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {

  List<NSEShare> shares = [];
  List<NSEShare> allShares = [];
  bool isLoading = false;

  _fetchNSEShares() async {
    final db = FirebaseFirestore.instance;
    await for (var snapshots in db.collection('stock_data').snapshots()) {
      List<NSEShare> nseShares = [];
      for (var snapshot in snapshots.docs) {
        nseShares.add(NSEShare(
            snapshot.id,
            snapshot.data()['current_price'],
            snapshot.data()['open_price'],
            snapshot.data()['high_price'],
            snapshot.data()['low_price'],
            snapshot.data()['previous_close'],
        ));
      }
      allShares = nseShares;
      shares = allShares;
      setState(() {});
    }
  }

  static freeStr(String s) {
    String newString = '';
    for (int i = 0; i < s.length; i++) {
      if (s[i] != ',') newString += s[i];
    }
    return newString;
  }

  _buyStock(NSEShare share) async{
    double cost = double.parse(freeStr(share.currentPrice));
    int purchasePrice = (cost *10).round();
    print(purchasePrice);

    if(Provider.of<Trader>(context,listen: false).coins<purchasePrice){
      Fluttertoast.showToast(msg: 'You don\'t have enough coins');
      return;
    }
    final db = FirebaseFirestore.instance;
    String docId = await ProfilePage.getDocId(Provider.of<Trader>(context,listen: false).username);
    await db.collection('user_data').doc(docId).collection('stock').add({
      'count':10,
      'public':true,
      'purchase_price': share.currentPrice,
      'stock_name':share.name,
      'timestamp':Timestamp.now().millisecondsSinceEpoch.toString(),
    });

    int newCoinsValue = Provider.of<Trader>(context,listen: false).coins-purchasePrice;
    await db.collection('user_data').doc(docId).update({
      'coins': newCoinsValue,
    });
    Provider.of<Trader>(context,listen: false).coins = newCoinsValue;

    await db.collection('user_data').doc(docId).collection('history').add({
      'bought':true,
      'price': share.currentPrice,
      'stocks_name':share.name,
      'timestamp':Timestamp.now().millisecondsSinceEpoch.toString(),
    });

    Fluttertoast.showToast(msg: 'Transaction Successful');
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
              onChange: (value) {
                if (value != '') {
                  shares = shares
                      .where((element) => element.name
                          .toLowerCase()
                          .contains(value.toString().toLowerCase()))
                      .toList();
                  setState(() {});
                } else {
                  shares = allShares;
                  setState(() {});
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shares.length,
              itemBuilder: (context, index) {
                double diff =
                    (double.parse(freeStr(shares[index].currentPrice)) -
                        double.parse(freeStr(shares[index].openPrice)));
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          width: double.infinity,
                              color: kSlightDarkBlue,
                              height: 400,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(shares[index].name,style: TextStyle(color: Colors.white,fontSize: 24),),
                                SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${shares[index].highPrice}↑',style: TextStyle(color: Colors.white,fontSize: 18),),
                                    Text('${shares[index].lowPrice}↓',style: TextStyle(color: Colors.white,fontSize: 18),),
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Text('LOT SIZE: 10',style: TextStyle(color: Colors.white),),
                                Text('${shares[index].currentPrice}₹ /share',style: TextStyle(color: Colors.white,fontSize: 18),),
                                SizedBox(height: 20,),
                                CustomButton(
                                    text: 'Buy',
                                    onPress: (){

                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: Container(
                                            color: kSlightDarkBlue,
                                            height: 200,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Are you sure you want to invest in ${shares[index].name}',
                                                    style:
                                                    TextStyle(color: Colors.white,fontSize: 18),
                                                  ),
                                                  SizedBox(height: 20,),
                                                  Row(
                                                    children: [
                                                      Checkbox(
                                                        activeColor: kBrightBlue,
                                                        checkColor: Colors.white,
                                                        value: true,
                                                        onChanged: (val){
                                                          setState(() {
                                                            // isPublic=val;
                                                          });
                                                        },
                                                      ),
                                                      Text('Make it a public transaction',style: TextStyle(color: Colors.white),),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      FlatButton(
                                                          child: Text('YES',style: TextStyle(color: Colors.white),),
                                                        onPressed: (){
                                                            Navigator.pop(context);
                                                            _buyStock(shares[index]);
                                                        },
                                                      ),
                                                      FlatButton(
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          'NO',style: TextStyle(color: Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                  }
                                )
                              ],
                            ),
                          ),
                            ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          shares[index].name,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                            color: diff > 0 ? kGreen : kRed,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              diff > 0
                                  ? '+${diff.toStringAsFixed(2)}'
                                  : diff.toStringAsFixed(2),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
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
