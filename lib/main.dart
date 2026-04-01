import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/controlles/eventlistcontroller.dart';
import 'package:mbileprogrammingproject/controlles/giftdetailscontroller.dart';
import 'package:mbileprogrammingproject/models/mainmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';
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
import 'package:mbileprogrammingproject/database/dataV2.dart';
import 'package:mbileprogrammingproject/controlles/maincontroller.dart';
import 'package:mbileprogrammingproject/models/profilemodel.dart';
import 'package:mbileprogrammingproject/controlles/giftdetailscontroller.dart';
import 'package:mbileprogrammingproject/controlles/pledgedcontroller.dart';
import 'package:mbileprogrammingproject/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbileprogrammingproject/friend_details_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await firebase.FirebaseAuth.instance.signOut();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clear all cached data on app initialization
  final mainController = MainViewController();
  await mainController.initializeApp();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // Default icon
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp
    (
    MultiProvider
      (
      providers:
      [
        ChangeNotifierProvider(create: (context) => mainController),
        ChangeNotifierProvider(create: (context) => UserProfileController(userProfile: UserProfile())),
        ChangeNotifierProvider(create: (context) => GiftpledgedController()),
        ChangeNotifierProvider(create: (context) => EventController()),
        ChangeNotifierProvider(create: (context) => GiftController()),
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

    return MaterialApp
      (
      debugShowCheckedModeBanner: false,
      title: 'Hediaty App',
      theme: themeController.isDarkMode
          ? ThemeData
        (
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          color: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
        ),
      )
          : ThemeData
        (
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(color: Colors.lightBlue),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.blue,
        ),
      ),
      home: FutureBuilder<firebase.User?>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading screen while the Firebase auth state is being checked
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            // Handle errors
            return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
          } else if (snapshot.data == null) {
            // If the user is not logged in, show the LoginPage
            return LoginPage();
          } else {
            // If the user is logged in, show the MainView
            return MainView();
          }
        },
      ),
    );
  }

  Future<firebase.User?> _getCurrentUser() async
  {
    // Check if the current user is logged in using Firebase Auth
    return firebase.FirebaseAuth.instance.currentUser;
  }
}






class MainView extends StatefulWidget
{
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
{
  final PageStorageBucket _bucket = PageStorageBucket();
  String userName = "User";
  String email = "email";
  // Make sure this is populated dynamically from Firebase or elsewhere
  String friendId = ''; // Likewise, this should be dynamically populated
  // Initialize email as an empty string

  @override
  void initState()
  {
    super.initState();
    _loadCachedUserData();
    Provider.of<MainViewController>(context, listen: false).fetchUserName(firebase.FirebaseAuth.instance.currentUser!.uid);

  }

  Future<void> _loadCachedUserData() async
  {
    try
    {
      final dbHelper = DatabaseHelperv2();

      // Retrieve the logged-in user's email (for example, from FirebaseAuth)
      final currentUser = firebase.FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        setState(() {
          email = currentUser.email ?? '';
          var userId = currentUser.uid;// Get the email from FirebaseAuth
        });

        final cachedUserData = await dbHelper.getUserData(email);  // Fetch user data based on email

        if (cachedUserData != null && cachedUserData['name'] != null) {
          setState(() {
            userName = cachedUserData['name'];  // Set the user name from cached data
          });
        }
      } else {
        print("No user is logged in");
      }
    } catch (e) {
      if (e is DatabaseException && e.isNoSuchTableError())
      {
        print("Users table not found. Initializing database.");
      } else {
        print("Error loading cached user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context)
  {
    final controller = Provider.of<MainViewController>(context);
    final themeController = Provider.of<ThemeController>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Hello, $userName'),  // Display the username in the AppBar
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

              if (confirm == true)
              {
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
          children:
          [
            FriendListPage(),
            EventListPage(userId: ''),
            GiftDetailsPage(),
            PledgedGiftsPage(),
            UserProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.selectedIndex,
        onTap: (index)
        {
          controller.updateSelectedIndex(index);
        },
        items: const
        [
          BottomNavigationBarItem
            (
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

        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.blue,
      ),
    );
  }
}



class FriendListPage extends StatefulWidget
{
  @override
  _FriendListPageState createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage>
{
  late Future<void> _loadData;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<MainViewController>(context, listen: false);

    final userId = firebase.FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      controller.loadFriends(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MainViewController>(context);

    return Scaffold(
      body: Consumer<MainViewController>(
        builder: (context, controller, child) {
          if (controller.friends.isEmpty) {
            return Center(child: Text("No friends found"));
          } else {
            return ListView(
              children: [
                ListTile(
                  title: Text("Your Friends", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                // Use Card for each friend in the list
                ...controller.friends.map((friend) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(friend.profilePic),
                        radius: 30,
                      ),
                      title: Text(friend.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(friend.events),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                      onTap: () {
                        if (friend.id.isNotEmpty) {
                          // Navigate to the FriendDetailsPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendDetailsPage(
                                friendName: friend.name,
                                friendEvents: friend.events,
                                friendId: friend.id,
                              ),
                            ),
                          );
                        } else {
                          print("Error: Friend ID is empty.");
                        }
                      },
                    ),
                  );
                }).toList(),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await controller.fetchAllUsers();
            _showAddFriendsDialog(context, controller);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error fetching users: $e")),
            );
          }
        },
        child: Icon(Icons.person_add),
      ),
    );
  }

  void _showAddFriendsDialog(BuildContext context, MainViewController controller) {
    TextEditingController friendname = TextEditingController();
    List<Friend> filteredUsers = List.from(controller.allUsers); // Use List<Friend>

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Friends"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: friendname,
                      decoration: InputDecoration(
                        hintText: "Search friends...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredUsers = controller.allUsers
                              .where((user) =>
                              user.name.toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user.profilePic),
                                radius: 30,
                              ),
                              title: Text(user.name),
                              trailing: IconButton(
                                icon: Icon(Icons.add, color: Colors.blue),
                                onPressed: () async {
                                  Map<String, dynamic> friendData = {
                                    'name': user.name,
                                    'profilePic': user.profilePic,
                                    'events': user.events,
                                  };

                                  await controller.addFriend(
                                      firebase.FirebaseAuth.instance.currentUser!.uid,
                                      friendData,
                                      user as Friend,
                                      context);

                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

}







