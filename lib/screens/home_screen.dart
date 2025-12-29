import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();

  void bookRide() async {
    String pickup = _pickupController.text.trim();
    String drop = _dropController.text.trim();

    if (pickup.isEmpty || drop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter both pickup and drop locations")),
      );
      return;
    }

    try {
      // Save ride in Firestore
      await FirebaseFirestore.instance.collection('rides').add({
        'userId': 'USER123', // replace with actual user id from auth later
        'pickup': pickup,
        'drop': drop,
        'status': 'requested',
        'driverId': '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Ride Booked"),
          content: Text("Pickup: $pickup\nDrop: $drop"),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      // Clear input fields
      _pickupController.clear();
      _dropController.clear();
    } catch (e) {
      print("Error booking ride: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to book ride")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Home"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pickupController,
              decoration: InputDecoration(
                hintText: "Pickup Location",
                prefixIcon: const Icon(Icons.my_location, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.deepPurple[50],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _dropController,
              decoration: InputDecoration(
                hintText: "Drop Location",
                prefixIcon: const Icon(Icons.location_on, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.deepPurple[50],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: bookRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Book Ride",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
