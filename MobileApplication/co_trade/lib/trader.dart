
class Trader{
  static const int INITIAL_COINS_VALUE = 1000;

  Trader(){
    this.coins=INITIAL_COINS_VALUE;
  }

  String uid;
  String fullName;
  String email;
  String phoneNo;
  String username;
  String password;
  int coins;

  List<String> requests;
  List<String> connections;
}