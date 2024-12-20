import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'GiftListPage .dart'; // Corrected import for GiftListPage
import 'package:mbileprogrammingproject/controlles/giftdetailscontroller.dart'; // Import GiftListPage
import 'controlles/eventlistcontroller.dart'; // Import your controller
import 'models/eventlistmodel.dart'; // Import your model

import 'package:firebase_auth/firebase_auth.dart'; // Correct import


class EventListPage extends StatefulWidget {
  EventListPage({Key? key, required String userId}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> with AutomaticKeepAliveClientMixin
{
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().firstWhere((user) => user != null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Event List'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          // User is not logged in
          return Scaffold(
            appBar: AppBar(
              title: Text('Event List'),
            ),
            body: Center(
              child: Text("User is not logged in."),
            ),
          );
        }

        String userId = snapshot.data!.uid;

        return ChangeNotifierProvider(
          create: (context) => EventController()..fetchEvents(userId),
          child: Scaffold(
            appBar: AppBar(
              title: Text('Event List'),
              actions: [
                Consumer<EventController>(builder: (context, controller, _) {
                  return DropdownButton<String>(
                    value: controller.dropdownValue, // Link dropdown value to controller
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: ['Category', 'Status', 'Name'].map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.setDropdownValue(newValue); // Update dropdown value
                        controller.sortEvents(newValue);       // Sort events based on new value
                      }
                    },
                  );
                }),
              ],
            ),
            body: Consumer<EventController>(
              builder: (context, controller, _) {
                return AnimatedSwitcher(
                  duration:  const Duration(milliseconds: 180),
                  child: controller.events.isEmpty
                      ? Center(child: Text('No events available'))
                      : ListView.builder(
                    key: ValueKey(controller.events.length),
                    itemCount: controller.events.length,
                    itemBuilder: (context, index) {
                      final event = controller.events[index];
                      return ListTile(
                        title: GestureDetector(
                          child: Text(
                            event.name,
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () async {
                            // Initialize selectedEventId here, after you have the event object
                            String selectedEventId = event.id.toString();

                            // Default to 0 if parsing fails
                            // Safely parse the string to an int
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GiftListPage(
                                  event: event,
                                  eventId: selectedEventId,
                                  eventName: event.name, userId: userId,
                                ),
                              ),
                            );
                          },
                        ),
                        subtitle: Text('${event.category} - ${event.status}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditDialog(
                                context,
                                controller,
                                index,
                                userId,  // Pass userId here
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => controller.deleteEvent(
                                userId,  // Ensure non-null userId
                                index as int,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            floatingActionButton: Consumer<EventController>(
              builder: (context, controller, _) {
                return FloatingActionButton(
                  onPressed: () {
                    if (userId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User ID is empty.')),
                      );
                      return;
                    }
                    controller.addEvent(
                      userId,  // Ensure non-null userId
                      Event(name: 'New Event', category: 'General', status: 'Upcoming'),
                    );
                  },
                  tooltip: 'Add Event',
                  child: Icon(Icons.add),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

void _showEditDialog(BuildContext context, EventController controller, int index, String userId) {
  final event = controller.events[index];
  final nameController = TextEditingController(text: event.name);
  final categoryController = TextEditingController(text: event.category);
  final statusController = TextEditingController(text: event.status);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: statusController,
              decoration: InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = nameController.text;
              final category = categoryController.text;
              final status = statusController.text;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Name field should not be empty')),
                );
              } else if (category != 'Work' && category != 'Personal') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category must be "Work" or "Personal".')),
                );
              } else if (status != 'Past' && status != 'Upcoming' && status != 'Current') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status must be "Past", "Upcoming", or "Current".')),
                );
              } else {
                await controller.editEvent(
                  userId,  // Pass userId safely
                  index,
                  name,
                  category,
                  status,
                );
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}