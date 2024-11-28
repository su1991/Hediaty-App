import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mbileprogrammingproject/controlles/pledgedcontroller.dart';
import 'package:mbileprogrammingproject/models/pledgedmodel.dart';

class PledgedGiftsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pledged Gifts'),
      ),
      body: FutureBuilder(
        future: Provider.of<GiftpledgedController>(context, listen: false).initDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading gifts!'));
          } else {
            return Consumer<GiftpledgedController>(
              builder: (context, giftController, _) {
                final gifts = giftController.gifts;

                if (gifts.isEmpty) {
                  return Center(
                    child: Text(
                      'No pledged gifts yet!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(gift.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('For: ${gift.friendName}\nDue: ${gift.dueDate.toLocal().toString().split(' ')[0]}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                gift.isPending ? Icons.check_box_outline_blank : Icons.check_box,
                                color: gift.isPending ? Colors.orange : Colors.green,
                              ),
                              onPressed: () {
                                giftController.modifyGift(gift);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      gift.isPending
                                          ? '${gift.name} marked as completed!'
                                          : '${gift.name} marked as pending!',
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                giftController.deleteGift(gift);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${gift.name} deleted.')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGiftDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add Gift',
      ),
    );
  }

  void _showAddGiftDialog(BuildContext context) {
    final nameController = TextEditingController();
    final friendNameController = TextEditingController();
    final dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Gift'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Gift Name'),
                ),
                TextField(
                  controller: friendNameController,
                  decoration: InputDecoration(labelText: 'Friend Name'),
                ),
                TextField(
                  controller: dueDateController,
                  decoration: InputDecoration(
                    labelText: 'Due Date (YYYY-MM-DD)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final friendName = friendNameController.text.trim();
                final dueDateText = dueDateController.text.trim();

                if (name.isEmpty || friendName.isEmpty || dueDateText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are required.')),
                  );
                  return;
                }

                try {
                  final dueDate = DateTime.parse(dueDateText);
                  final newGift = Gift(
                    name: name,
                    friendName: friendName,
                    dueDate: dueDate,
                  );

                  Provider.of<GiftpledgedController>(context, listen: false).addGift(newGift);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid date format. Use YYYY-MM-DD.')),
                  );
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
}
