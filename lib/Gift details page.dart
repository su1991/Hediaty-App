import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package

import 'package:mbileprogrammingproject/controlles/giftdetailscontroller.dart';
import 'package:mbileprogrammingproject/models/giftdetailsmodel.dart';
import 'package:mbileprogrammingproject/controlles/maincontroller.dart'; // Use the correct import

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
  int eventId = 0;

  List<Gift> _gifts = [];
  File? _image;  // Variable to store the selected image

  void _loadGifts() async
  {
    final gifts = await _giftController.getAllGifts();
    setState(() {
      _gifts = gifts.cast<Gift>();
    });
  }

  void _submitGift() async {
    if (_formKey.currentState!.validate()) {
      print('Form validated successfully. Preparing gift object.');

      final gift = Gift(
        id: null,
        name: giftName,
        description: description,
        category: category,
        price: price,
        status: isPledged ? 'Pledged' : 'Available',
        eventId: eventId, // Ensure eventId is set correctly
      );

      final result = await _giftController.saveGift(gift);
      if (result != -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gift saved to database!')),
        );
        _loadGifts(); // Reload the list after saving
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save gift.')),
        );
      }
    }
  }





  Future<void> _pickImage() async
  {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null)
    {
      setState(()
      {
        _image = File(pickedFile.path); // Store the selected image
      });
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Form for gift details
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Gift Name field
                    AbsorbPointer(
                      absorbing: isPledged,  // Disable if pledged
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Gift Name', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a gift name';
                          }
                          return null;
                        },
                        onChanged: (value)
                        {
                          setState(()
                          {
                            giftName = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Description field
                    AbsorbPointer(
                      absorbing: isPledged,  // Disable if pledged
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                          {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        onChanged: (value)
                        {
                          setState(()
                          {
                            description = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Category dropdown
                    AbsorbPointer(
                      absorbing: isPledged,  // Disable if pledged
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: ['Electronics', 'Books', 'Clothing', 'Toys', 'Accessories', 'Furniture']
                            .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                            .toList(),
                        onChanged: (value)
                        {
                          setState(() {
                            category = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty)
                          {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Price field
                    AbsorbPointer(
                      absorbing: isPledged,  // Disable if pledged
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value)
                        {
                          if (value == null || value.isEmpty)
                          {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null)
                          {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (value)
                        {
                          setState(()
                          {
                            price = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Status Switch
                    Row(
                      children: [
                        Text('Status: '),
                        Switch(
                          value: isPledged,
                          onChanged: (value)
                          {
                            setState(() {
                              isPledged = value;
                            });
                          },
                        ),
                        Text(isPledged ? 'Pledged' : 'Available'),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitGift,
                      child: Text('Submit'),
                    ),
                    SizedBox(height: 16),
                    // Image Upload Button
                    ElevatedButton(
                      onPressed: isPledged ? null : _pickImage,  // Disable button if pledged
                      child: Text('Upload Image'),
                    ),
                    if (_image != null) ...[
                      SizedBox(height: 16),
                      Image.file(_image!),  // Display the selected image
                    ],
                    SizedBox(height: 16),
                  ],
                ),
              ),
              // List of gifts

            ],
          ),
        ),
      ),
    );
  }
}
