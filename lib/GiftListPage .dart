import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mbileprogrammingproject/controlles/giftlistcontroller.dart';  // Import the GiftController
import 'package:mbileprogrammingproject/models/giftlistmodel.dart';

import 'models/eventlistmodel.dart';

// Import the Gift model

class GiftListPage extends StatefulWidget
{
  final Event event; // Define the event parameter here

  // Constructor with named parameter
  GiftListPage({required this.event});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}
class _GiftListPageState extends State<GiftListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List'),
        actions: [
          // Sorting Dropdown
          Consumer<GiftlistController>(
            builder: (context, controller, _) {
              return DropdownButton<String>(
                value: controller.sortCriteria,
                icon: const Icon(Icons.sort),
                items: <String>['name', 'category', 'status']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.capitalize()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.sortGifts(newValue);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<GiftlistController>(
        builder: (context, controller, _) {
          return controller.gifts.isEmpty
              ? Center(child: Text('No gifts added!'))
              : ListView.builder(
            itemCount: controller.gifts.length,
            itemBuilder: (context, index) {
              final gift = controller.gifts[index];
              return ListTile(
                title: Text(gift.name),
                subtitle: Text('${gift.category} - ${gift.status}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _showEditDialog(context, controller, index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        controller.deleteGift(index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<GiftlistController>(
        builder: (context, controller, _) {
          return FloatingActionButton(
            onPressed: () {
              _showAddDialog(context, controller);
            },
            tooltip: 'Add Gift',
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }

  // Add Gift Dialog
  void _showAddDialog(BuildContext context, GiftlistController controller) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    String status = 'Available';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Gift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Gift Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              DropdownButton<String>(
                value: status,
                items: <String>['Available', 'Pledged']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  status = newValue!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                  controller.addGift(nameController.text, categoryController.text, status);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Name and category are required'),
                  ));
                }
              },
              child: Text('Add'),
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

  // Edit Gift Dialog
  void _showEditDialog(BuildContext context, GiftlistController controller, int index)
  {
    final gift = controller.gifts[index];
    final nameController = TextEditingController(text: gift.name);
    final categoryController = TextEditingController(text: gift.category);
    String status = gift.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Gift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Gift Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              DropdownButton<String>(
                value: status,
                items: <String>['Available', 'Pledged']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  status = newValue!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                  controller.editGift(index, nameController.text, categoryController.text, status);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Name and category are required'),
                  ));
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

// Extension for capitalizing first letter
extension StringCapitalization on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}
