import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'GiftListPage .dart'; // Corrected import for GiftListPage
import 'package:mbileprogrammingproject/controlles/giftlistcontroller.dart'; // Import GiftListPage
import 'controlles/eventlistcontroller.dart'; // Import your controller
import 'models/eventlistmodel.dart'; // Import your model

class EventListPage extends StatefulWidget
{
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Ensures state is retained

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call this to integrate with AutomaticKeepAliveClientMixin

    return ChangeNotifierProvider
      (
      create: (context) => EventController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Event List'),
          actions: [
            Consumer<EventController>(
              builder: (context, controller, _)
              {
                return DropdownButton(
                  value: controller.dropdownValue,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: ['Category', 'Status', 'Name'].map((String item)
                  {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? newValue)
                  {
                    if (newValue != null)
                    {
                      controller.sortEvents(newValue);
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<EventController>(
          builder: (context, controller, _)
          {
            return ListView.builder(
              itemCount: controller.events.length,
              itemBuilder: (context, index)
              {
                final event = controller.events[index];
                return ListTile
                  (
                  title: GestureDetector
                    (
                    child: Text
                      (
                      event.name,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () async
                    {
                      debugPrint("Navigating to GiftListPage for Event: ${event.name}, eventId: ${event.id}");
                      await Navigator.push(
                        context,
                          MaterialPageRoute
                            (
                            builder: (context) => GiftListPage
                              (
                              event: event,
                              eventId: event.id ?? 0,
                              eventName: event.name,// Provide a fallback value if event.id is null
                            ),
                          )

                      );
                      debugPrint("Returned from GiftListPage");
                    },
                  ),
                  subtitle: Text('${event.category} - ${event.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(context, controller, index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => controller.deleteEvent(index),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Consumer<EventController>(
          builder: (context, controller, _) {
            return FloatingActionButton(
              onPressed: controller.addEvent,
              tooltip: 'Add Event',
              child: Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, EventController controller, int index)
  {
    final event = controller.events[index];
    final nameController = TextEditingController(text: event.name);
    final categoryController = TextEditingController(text: event.category);
    final statusController = TextEditingController(text: event.status);

    showDialog(
      context: context,
      builder: (context)
      {
        return AlertDialog
          (
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
          actions:
          [
            TextButton(
              onPressed: ()
              {
                final name = nameController.text;
                final category = categoryController.text;
                final status = statusController.text;

                if (name.isEmpty)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name field should not be empty')),
                  );
                } else if (category != 'Work' && category != 'Personal') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Category must be "Work" or "Personal".')),
                  );
                } else if (status != 'Past' && status != 'Upcoming' && status != 'Current')
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status must be "Past", "Upcoming", or "Current".')),
                  );
                } else
                {
                  controller.editEvent(index, name, category, status);
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
}
