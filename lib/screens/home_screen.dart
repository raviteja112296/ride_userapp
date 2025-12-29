import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? currentRideId;
  String rideStatus = '';

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();

void cancelRide() async {
  if (currentRideId == null) return;

  try {
    await FirebaseFirestore.instance
        .collection('rides')
        .doc(currentRideId)
        .update({
      'status': 'cancelled',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ride cancelled")),
    );

    setState(() {
      currentRideId = null;
    });
  } catch (e) {
    print("Cancel error: $e");
  }
}

  /// BOOK RIDE
  Future<void> bookRide() async {
    String pickup = _pickupController.text.trim();
    String drop = _dropController.text.trim();

    if (pickup.isEmpty || drop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter both pickup and drop locations")),
      );
      return;
    }

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('rides').add({
        'userId': 'USER123',
        'pickup': pickup,
        'drop': drop,
        'status': 'requested',
        'driverId': '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        currentRideId = docRef.id;
        rideStatus = 'requested';
      });

      _pickupController.clear();
      _dropController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to book ride")),
      );
    }
  }

  /// LISTEN TO RIDE STATUS
  Widget rideStatusWidget() {
    if (currentRideId == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rides')
          .doc(currentRideId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!;
        final status = data['status'];

        if (status == 'accepted') {
          return Card(
            color: Colors.green.shade100,
            margin: const EdgeInsets.only(top: 20),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "✅ Driver Assigned",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        if (status == 'requested') {
          return Card(
            color: Colors.orange.shade100,
            margin: const EdgeInsets.only(top: 20),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "⏳ Waiting for driver...",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        if (status == 'completed') {
          return Card(
            color: Colors.blue.shade100,
            margin: const EdgeInsets.only(top: 20),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "🏁 Ride Completed",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
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
          children: [
            TextField(
              controller: _pickupController,
              decoration: InputDecoration(
                hintText: "Pickup Location",
                prefixIcon:
                    const Icon(Icons.my_location, color: Colors.deepPurple),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dropController,
              decoration: InputDecoration(
                hintText: "Drop Location",
                prefixIcon:
                    const Icon(Icons.location_on, color: Colors.deepPurple),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: bookRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text("Book Ride"),
            ),
            
            if (currentRideId != null)
  StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('rides')
        .doc(currentRideId)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox();

      final rideData = snapshot.data!;
      final status = rideData['status'];

      if (status != 'requested') return const SizedBox();

      return ElevatedButton(
        onPressed: cancelRide,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Cancel Ride",
          style: TextStyle(fontSize: 18),
        ),
      );
    },
  ),

            /// 👇 LIVE STATUS UI
            rideStatusWidget(),
          ],
        ),
      ),
    );
  }
}
