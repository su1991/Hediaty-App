import 'dart:io';
import 'package:flutter/material.dart';

import 'package:mbileprogrammingproject/controlles/giftdetailscontroller.dart';
import 'package:mbileprogrammingproject/models/giftdetailsmodel.dart'; // Use the correct import

void main()
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gift Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GiftDetailsPage(),
    );
  }
}

class GiftDetailsPage extends StatefulWidget
{
  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage>
{
  final GiftController _giftController = GiftController();
  final _formKey = GlobalKey<FormState>();

  String giftName = '';
  String description = '';
  String category = '';
  double price = 0.0;
  bool isPledged = false;

  List<Gift> _gifts = [];

  void _loadGifts() async
  {
    final gifts = await _giftController.getAllGifts();
    setState(() {
      _gifts = gifts.cast<Gift>();
    });
  }

  void _submitGift() async
  {
    if (_formKey.currentState!.validate()) {
      final gift = Gift
        (
        name: giftName,
        description: description,
        category: category,
        price: price,
        status: isPledged ? 'Pledged' : 'Available',
        eventId: 2,
      );
      await _giftController.saveGift(gift);
      _loadGifts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift Submitted!')),
      );
    }
  }

  @override
  void initState()
  {
    super.initState();
    _loadGifts();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: Text('Gift Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Gift Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gift name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    giftName = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Category'),
                items: ['Electronics', 'Books', 'Clothing', 'Toys', 'Accessories', 'Furniture']
                    .map((category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    price = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              Row(
                children: [
                  Text('Status: '),
                  Switch(
                    value: isPledged,
                    onChanged: (value) {
                      setState(() {
                        isPledged = value;
                      });
                    },
                  ),
                  Text(isPledged ? 'Pledged' : 'Available'),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitGift,
                child: Text('Submit'),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _gifts.length,
                  itemBuilder: (context, index) {
                    final gift = _gifts[index];
                    return ListTile(
                      title: Text(gift.name),
                      subtitle: Text(gift.category),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
