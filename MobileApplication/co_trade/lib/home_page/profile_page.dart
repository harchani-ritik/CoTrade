import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/models/stock.dart';
import 'package:co_trade/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../models/trader.dart';

class ProfilePage extends StatefulWidget {
  final String traderId;
  final bool isPersonal;
  ProfilePage(this.traderId,{this.isPersonal=false});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Trader trader = Trader();
  bool isLoading = false;

  List<Stock> dummyList = [
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
    Stock('Reliance','500.09','20','20th Oct Fri'),
  ];

  _loadProfile() async{
    setState(() => isLoading = true);

    final db = FirebaseFirestore.instance;
    var snapshot = await db.collection('user_data').doc(widget.traderId).get();
    print(snapshot.data());
    var data = snapshot.data();
    trader.username = data['username'];
    trader.phoneNo = data['phoneNo'];
    trader.email = data['email'];
    trader.fullName = data['name'];
    trader.coins = data['coins'];
    
    //load stocks
    try {
      await db.collection('user_data').doc(widget.traderId)
          .collection('stock')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          var data = element.data();
          print(data);
          if (widget.isPersonal || data['public']) {
            //add that stock to list
            trader.stocksHold.add(Stock(
              data['stock_name'],
              data['purchase_price'],
              data['count'],
              data['timestamp'],
            ));
          }
        });
      });
      //TODO: Uncomment for real data
      // dummyList = trader.stocksHold;
    }
    catch(e){
      print('Error while finding stock data');
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(kBrightBlue),
      ),
      inAsyncCall: isLoading,
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 40,),
              Text('Trader Profile',style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),),
              SizedBox(height: 40,),
              Image(
                height: 180,
                image: AssetImage('images/trader_avatar.png'),
              ),
              SizedBox(height: 10,),
              Text(trader.fullName,style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
              Text(trader.username,style: TextStyle(fontSize: 18,color: Colors.white),),
              Text(trader.email,style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              widget.isPersonal?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      height: 40,
                      image: AssetImage('images/coins_icon.png'),
                    ),
                  ),
                  Text(trader.coins.toString(),style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),),
                ],
              ):
              Container(),
              Text('History',style: TextStyle(fontSize: 16,color: Colors.white),),

              Container(
                color: kDarkBlue,
                height: 50,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Stock',style: TextStyle(color: Colors.white),),
                    Text('Purchase\nPrice(Rs.)',style: TextStyle(color: Colors.white),),
                    Text('Shares',style: TextStyle(color: Colors.white),),
                    Text('Time',style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: dummyList.length,
                  itemBuilder: (context,index){
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(dummyList[index].id??'',style: TextStyle(color: Colors.white),),
                        Text(dummyList[index].purchasedPrice??'',style: TextStyle(color: Colors.white),),
                        Text(dummyList[index].sharesBought??'',style: TextStyle(color: Colors.white),),
                        Text(dummyList[index].time??'',style: TextStyle(color: Colors.white),),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
