import 'package:co_trade/sign_up/auth_page.dart';
import 'package:co_trade/sign_up/profile_setup.dart';
import 'package:flutter/material.dart';
import 'initial_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  int _currentIndex = 0;
  final PageController _pageController = PageController();

  animateToNextPage() {
    if (_currentIndex == 2) return;
    _pageController.animateToPage(_currentIndex + 1,
        curve: Curves.linear, duration: Duration(milliseconds: 100));
  }

  animateToPreviousPage() {
    if (_currentIndex == 0) return;
    _pageController.animateToPage(_currentIndex - 1,
        curve: Curves.linear, duration: Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
      },
      controller: _pageController,
      children: [
        InitialPage(animateToNextPage),
        AuthPage(animateToNextPage, animateToPreviousPage),
        ProfileSetup(animateToPreviousPage),
      ],
    );
  }
}
