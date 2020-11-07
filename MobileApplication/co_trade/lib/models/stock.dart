class Stock{

  Stock(this.id,this.purchasedPrice,this.sharesBought,this.time,{this.isPublic=false});

  String id;
  String sharesBought;
  String purchasedPrice;
  String time;
  bool isPublic;
}