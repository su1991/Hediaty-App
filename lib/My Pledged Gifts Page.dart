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
                        title: Text(
                          gift.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'For: ${gift.friendName}\nEvent: ${gift.EventName}',
                        ),
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
                    ;
                  },
                );
              },
            );
          }
        },
      ),

    );
  }


}
