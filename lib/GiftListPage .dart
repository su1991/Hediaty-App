import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/models/eventlistmodel.dart';
import 'package:provider/provider.dart';
import 'package:mbileprogrammingproject/controlles/giftlistcontroller.dart';
import 'package:mbileprogrammingproject/controlles/giftdetailscontroller.dart';
import 'package:mbileprogrammingproject/models/giftdetailsmodel.dart';

class GiftListPage extends StatefulWidget {
  final int eventId;
  final String eventName;

  GiftListPage({required this.eventId, required Event event, required this.eventName});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List for ${widget.eventName}'),
      ),
      body: Consumer<GiftlistController>(
        builder: (context, giftlistController, child) {
          if (giftlistController.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return giftlistController.eventGifts.isEmpty
              ? Center(
            child: Text(
              'Empty.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
              : ListView.builder(
            itemCount: giftlistController.eventGifts.length,
            itemBuilder: (context, index) {
              final gift = giftlistController.eventGifts[index];
              bool isSelected = giftlistController.getSelectedGiftsForEvent(widget.eventId).contains(gift);
              return Card(
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  title: Text(gift.name),
                  subtitle: Text(gift.category),
                  trailing: Icon(
                    Icons.check_circle,
                    color: isSelected ? Colors.green : Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGiftDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add Gift',
      ),
    );
  }

  // Show dialog to add a gift
  void _showAddGiftDialog(BuildContext context) async {
    final giftController = Provider.of<GiftController>(context, listen: false);
    final giftlistController = Provider.of<GiftlistController>(context, listen: false);

    // Fetch available gifts for the event
    final availableGifts = await giftController.getAvailableGiftsForEvent(widget.eventId);

    print('Available gifts fetched: ${availableGifts.length}'); // Debugging output

    if (availableGifts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No available gifts to add.')));
      return;
    }

    // Show the dialog with available gifts to choose from
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Gifts to Add'),
              content: SizedBox(
                height: 250,
                width: 300,
                child: ListView.builder(
                  itemCount: availableGifts.length,
                  itemBuilder: (context, index) {
                    final gift = availableGifts[index];
                    bool isSelected = giftlistController.getSelectedGiftsForEvent(widget.eventId).contains(gift);
                    return ListTile(
                      title: Text(gift.name),
                      subtitle: Text(gift.category),
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              giftlistController.addGiftToSelectedList(widget.eventId, gift); // Add gift to selected list
                            } else {
                              giftlistController.removeGiftFromSelectedList(widget.eventId, gift); // Remove gift from selected list
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final selectedGifts = giftlistController.getSelectedGiftsForEvent(widget.eventId);

                    if (selectedGifts.isNotEmpty) {
                      for (var gift in selectedGifts) {
                        giftController.addGiftToEvent(
                          name: gift.name,
                          category: gift.category,
                          status: gift.status,
                          eventId: widget.eventId,
                          description: gift.description,
                          price: gift.price,
                        );
                      }

                      // Refresh the list of gifts for the event
                      giftlistController.loadEventGifts(widget.eventId);

                      Navigator.of(context).pop(); // Close dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No gifts selected')));
                    }
                  },
                  child: Text('Add Selected Gifts'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
