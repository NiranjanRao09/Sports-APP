import 'package:flutter/material.dart';
import 'package:sportsapp/Screens/home_screen.dart';

// import 'package:sportsapp/Screens/user_dashboard.dart';

void main() {
  runApp(
    MaterialApp(
      title: "Sports App",
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),

      // home: Scaffold(
      //   appBar: AppBar(title: Text("Home Page")),
      //   bottomNavigationBar: BottomNavigationBar(
      //     type: BottomNavigationBarType.fixed,
      //     backgroundColor: const Color.fromARGB(255, 67, 67, 67),

      //     items: [
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.home, color: Colors.white),
      //         label: 'Home',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.account_circle_rounded, color: Colors.white),
      //         label: 'Login',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.badge, color: Colors.white),
      //         label: 'Id card',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.event, color: Colors.white),
      //         label: 'Event',
      //       ),
      //     ],
      //   ),
      // ),
    ),
  );
}
