import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/models/eventlistmodel.dart';
import 'package:provider/provider.dart';
import 'package:mbileprogrammingproject/controlles/giftdetailscontroller.dart'; // Import GiftController
import 'package:mbileprogrammingproject/models/giftdetailsmodel.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String userId;

  const GiftListPage({
    required this.eventId,
    required this.eventName,
    required Event event,
    required this.userId, // You can remove this if not used
  });

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  @override
  Widget build(BuildContext context) {
    // Access GiftController via Provider
    final giftlistController = Provider.of<GiftController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List for ${widget.eventName}'),
      ),
      body: Consumer<GiftController>( // Consumer will rebuild the UI when the state changes
        builder: (context, giftlistController, child) {
          if (giftlistController.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Fetch selected gifts for this specific event
          final eventGifts = giftlistController.getSelectedGiftsForEvent(widget.eventId);

          if (eventGifts.isEmpty) {
            return Center(
              child: Text(
                'No gifts selected.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: eventGifts.length,
            itemBuilder: (context, index) {
              final gift = eventGifts[index];
              return Card(
                child: ListTile(
                  title: Text(gift.name),
                  subtitle: Text(gift.category),
                  trailing: Text('\$${gift.price.toStringAsFixed(2)}'),
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

  void _showAddGiftDialog(BuildContext context) async {
    final giftController = Provider.of<GiftController>(context, listen: false);

    // Fetch available gifts for the specific event
    final availableGifts = await giftController.getAllGifts();

    if (availableGifts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No available gifts to add.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Gifts to Add'),
          content: SizedBox(
            height: 250,
            width: 300,
            child: Consumer<GiftController>(
              builder: (context, giftlistController, child) {
                // Get the selected gifts for the event
                final selectedGifts = giftlistController.getSelectedGiftsForEvent(widget.eventId);

                return ListView.builder(
                  itemCount: availableGifts.length,
                  itemBuilder: (context, index) {
                    final gift = availableGifts[index];
                    return CheckboxListTile(
                      title: Text(gift.name),
                      subtitle: Text(gift.category),
                      value: selectedGifts.contains(gift),
                      onChanged: (bool? value) {
                        if (value == true) {
                          giftlistController.addGiftToSelectedList(widget.userId, widget.eventId, gift);
                        } else {
                          giftlistController.removeGiftFromSelectedList(widget.eventId, gift);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
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

