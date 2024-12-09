import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/controlles/giftlistcontroller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Gift details page.dart';
import 'controlles/giftdetailscontroller.dart';
import 'darkcontroller.dart';
import 'eventlistpage.dart';
import 'GiftListPage .dart';
import 'My Pledged Gifts Page.dart';
import 'package:mbileprogrammingproject/controlles/profilecontroller.dart';
import 'models/profilemodel.dart';
import 'profilepage.dart';
import 'Login.dart';
import 'package:flutter/services.dart';
import 'package:mbileprogrammingproject/database/databasehelp.dart';
import 'package:mbileprogrammingproject/controlles/maincontroller.dart';
import 'package:mbileprogrammingproject/models/profilemodel.dart';
import 'package:mbileprogrammingproject/controlles/giftdetailscontroller.dart';
import 'package:mbileprogrammingproject/controlles/pledgedcontroller.dart';
import 'package:mbileprogrammingproject/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations
    (
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ); // Ensure
  // bindings are initialized before running the app
  final mainController = MainViewController();
  await mainController.initializeApp();

  runApp(
    MultiProvider
      (
      providers: [
        ChangeNotifierProvider(
          create: (context) => MainViewController(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProfileController(
            userProfile: UserProfile(), // Pass an initial UserProfile instance here
          ),
        ),
        ChangeNotifierProvider
          (
          create: (context) => GiftController(),
        ),
        ChangeNotifierProvider(
          create: (context) => GiftpledgedController(),
        ),
        ChangeNotifierProvider(
          create: (context) => GiftlistController(),
        ),
        ChangeNotifierProvider(create: (context) => ThemeController()..loadThemePreference()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Hediaty App',
      theme: themeController.isDarkMode
          ? ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey, // Neutral primary colors
        scaffoldBackgroundColor: Colors.black, // True black background
        appBarTheme: AppBarTheme(
          color: Colors.black, // True black AppBar
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
        ),
        cardColor: Colors.black, // Cards with true black background
        textTheme: TextTheme(

        ),
      )
          : ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(color: Colors.lightBlue),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.blue,
        ),
        textTheme: TextTheme(

        ),
      ),

      home: Consumer<MainViewController>(
        builder: (context, controller, child) {
          if (!controller.isInitialized) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return controller.isLoggedIn ? MainView() : LoginPage();
        },
      ),
    );
  }
}


class MainView extends StatelessWidget {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MainViewController>(context);
    final themeController = Provider.of<ThemeController>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeController.toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Logout"),
                  content: Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await controller.logout(context);
              }
            },
          ),
        ],
      ),
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: controller.selectedIndex,
          children: [
            FriendListPage(),
            EventListPage(),
            GiftDetailsPage(),
            PledgedGiftsPage(),
            UserProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.selectedIndex,
        onTap: (index) {
          controller.updateSelectedIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: Colors.blue),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, color: Colors.blue),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.blue),
            label: 'Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.blue),
            label: 'Pledged',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.blue),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.blue,
      ),
    );
  }
}
class FriendListPage extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MainViewController>(context);

    return FutureBuilder(
      future: controller.loadFriends(1), // Pass user ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        return ListView.builder(
          itemCount: controller.friends.length,
          itemBuilder: (context, index) {
            final friend = controller.friends[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(friend.profilePic),
              ),
              title: Text(friend.name),
              subtitle: Text(friend.events),
            );
          },
        );
      },
    );
  }
}


