import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'chatpage.dart';
import 'chatservice.dart';
import 'controlles/pledgedcontroller.dart';
import 'models/eventlistmodel.dart'; // Event model
import 'models/giftdetailsmodel.dart';
import 'models/mainmodel.dart';
import 'models/pledgedmodel.dart'; // Import Event model

class FriendDetailsPage extends StatelessWidget
{
  final String friendId; // Friend's userId
  final String friendName;

  const FriendDetailsPage({
    Key? key,
    required this.friendId, // Pass the friend's userId
    required this.friendName, required String friendEvents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('FriendDetailsPage initialized with friendId: $friendId');
    return Scaffold(
      appBar: AppBar(
        title: Text(friendName), // Friend's name as title
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: ()
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage
                    (
                    friendId: friendId,
                    friendName: friendName,
                    currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: fetchFriendEvents(friendId), // Fetch friend's events
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Show loading indicator
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading events: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('$friendName has no events.'));
          }

          final events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index)
            {
              final event = events[index];
              return ListTile
                (
                title: Text(event.name),
                subtitle: Text('${event.category} - ${event.status}'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to GiftsPage for this specific event
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GiftsPage(

                        friendName: friendName,
                        eventId: event.id!, // Pass event ID
                        eventName: event.name, friendId: friendId, // Pass event name
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Function to fetch friend's events from Firestore
  Future<List<Event>> fetchFriendEvents(String friendId) async
  {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users') // Access the users collection
          .doc(friendId) // Access the specific friend's document
          .collection('events') // Access their events subcollection
          .get();

      // Map Firestore data to a list of Event objects
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching friend\'s events: $e');
      return [];
    }
  }

}






class GiftsPage extends StatefulWidget
{
  final String eventId;
  final String friendId;
  final String eventName;
  final String friendName;

  const GiftsPage({
    required this.eventId,
    required this.friendId,
    required this.eventName,
    required this.friendName,
  });

  @override
  _GiftsPageState createState() => _GiftsPageState();
}

class _GiftsPageState extends State<GiftsPage>
{
  late Future<List<Gift>> _giftsFuture;

  @override
  void initState() {
    super.initState();
    _giftsFuture = fetchFriendEventGifts(widget.friendId, widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts for ${widget.eventName}'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Gift>>(
        future: _giftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading gifts: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No gifts for ${widget.eventName}.'));
          }

          final gifts = snapshot.data!;

          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return ListTile(
                title: Text(gift.name),
                subtitle: Text('Category: ${gift.category}\nPrice: \$${gift.price}'),
                leading: Icon(Icons.card_giftcard, color: Colors.green),
                trailing: ElevatedButton(
                  onPressed: () async
                  {
                    final User? currentUser = FirebaseAuth.instance.currentUser;

                    if (currentUser == null)
                    {
                      // Handle unauthenticated users
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You must be logged in to pledge gifts.')),
                      );
                      return;
                    }

                    // Create the pledged gift object
                    final pledgedGift = pGift(
                      name: gift.name,
                      friendName: widget.friendName,
                      EventName: widget.eventName,
                      isPending: true,
                      userId: currentUser.uid, // Associate gift with current user
                    );

                    // Add the pledged gift to the controller
                    await Provider.of<GiftpledgedController>(context, listen: false).addGift(pledgedGift);

                    // Show confirmation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${gift.name} has been pledged!')),
                    );
                  },
                  child: Text('Pledge'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}




  // Function to fetch gifts for a specific friend's event
Future<List<Gift>> fetchFriendEventGifts(String friendId, String eventId) async
{
  print('Fetching gifts for friendId: $friendId, eventId: $eventId');

  if (friendId.isEmpty || eventId.isEmpty) {
    print("Error: friendId or eventId is empty");
    return []; // Return an empty list if the IDs are invalid
  }

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users') // Access the users collection
        .doc(friendId) // Access the specific friend's document
        .collection('events') // Access their events collection
        .doc(eventId) // Access the specific event document
        .collection('gifts') // Access the gifts collection under the event
        .get();

    if (snapshot.docs.isEmpty) {
      print('No gifts found for eventId: $eventId');
      return []; // If no gifts are found, return an empty list
    }

    // Map Firestore documents to Gift objects
    List<Gift> gifts = snapshot.docs
        .map((doc) => Gift.fromMap(doc.data())) // Assuming Gift.fromMap maps doc data to Gift
        .toList();

    print('Fetched ${gifts.length} gifts for eventId: $eventId');
    return gifts;
  } catch (e) {
    print('Error fetching gifts for eventId: $eventId: $e');
    return []; // Return an empty list in case of an error
  }
}








