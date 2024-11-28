import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/controlles/giftlistcontroller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Gift details page.dart';
import 'controlles/giftdetailscontroller.dart';
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
import 'package:mbileprogrammingproject/controlles/pledgedcontroller.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);// Ensure bindings are initialized before running the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MainViewController(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProfileController(
            userProfile: UserProfile(), // Pass an initial UserProfile instance here
          ),
        ), ChangeNotifierProvider
          (create: (context) => GiftpledgedController(),) , ChangeNotifierProvider
(create: (context) => GiftlistController(),

        )],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Hediaty App',
      theme: ThemeData
        (
        primarySwatch: Colors.green,
      ),
      home: Consumer<MainViewController>(
        builder: (context, controller, child) {
          // Show loading spinner during initialization
          if (!controller.isInitialized) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          debugPrint("Logged in status: ${controller.isLoggedIn}");
          // Navigate to MainView if logged in
          return controller.isLoggedIn ? MainView() : LoginPage();
        },
      ),
    );
  }
}



class MainView extends StatelessWidget
{
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MainViewController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint("Search button pressed.");
            },
            icon: const Icon(Icons.search),
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
          debugPrint("Navigating to index: $index");
          controller.updateSelectedIndex(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group, color: Colors.blue,),  label:  'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.event,color: Colors.blue,), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.list,color: Colors.blue,), label: 'Gifts'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite,color: Colors.blue,), label: 'Pledged'),
          BottomNavigationBarItem(icon: Icon(Icons.person,color: Colors.blue,), label: 'Profile'),
        ],

        selectedItemColor: Colors.green, // Color for the selected label and icon
        unselectedItemColor: Colors.blue,
      ),
    );
  }
}



class FriendListPage extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
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
