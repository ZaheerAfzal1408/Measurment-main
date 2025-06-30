import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:measuremate/Screens/results/store_details.dart';
import 'package:measuremate/components/firebase_storage.dart';
import 'package:measuremate/components/save_to';
import '../../constants.dart';

class SweatshirtMeasurementResult extends StatefulWidget {
  final Map<String, double?> actualSize;
  final String selectedSize;
  final String capturedImagePath;

  SweatshirtMeasurementResult({
    super.key,
    required this.actualSize,
    required this.selectedSize,
    required this.capturedImagePath,
  });

  @override
  _SweatshirtMeasurementResultState createState() =>
      _SweatshirtMeasurementResultState();
}

class _SweatshirtMeasurementResultState
    extends State<SweatshirtMeasurementResult> {
  bool isInches = true;
  final double measuredSize = 29.0;

  // Conversion functions for inches and cm
  double inchesToCm(double inches) => inches * 2.54;
  double cmToInches(double cm) => cm / 2.54;

//   // Function to upload image to Firebase Storage
//   Future<String> uploadImage(File imageFile) async {
//     try {
//       // Create a reference to the storage location
//       Reference storageReference = FirebaseStorage.instance.ref().child('user_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

//       // Upload the image file
//       UploadTask uploadTask = storageReference.putFile(imageFile);

//       // Wait for the upload to complete and get the download URL
//       TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
//       String downloadURL = await taskSnapshot.ref.getDownloadURL();

//       return downloadURL;
//     } catch (e) {
//       throw Exception('Error uploading image: $e');
//     }
//   }

//   // Function to store data in Firestore
//  storeMeasurementData(String imageUrl, String username, String email, double actualSize, String selectedSize) async {
//     try {
//       // Get the current user
//       User? user = FirebaseAuth.instance.currentUser;

//       if (user != null) {
//         // Store the data in Firestore under the 'users' collection
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'username': username,
//           'email': email,
//           'selectedSize': selectedSize,
//           'actualSize': actualSize,
//           'imageUrl': imageUrl,  // Store the image URL here
//           'createdAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true)); // Merge data if user already exists

//         print("User data saved successfully.");
//       } else {
//         print("No user is logged in.");
//       }
//     } catch (e) {
//       print("Error storing data: $e");
//     }
//   }

  @override
  Widget build(BuildContext context) {
    final double difference = 0;
    // (measuredSize - widget.actualSize).abs();
    final double accuracy = 0;
    // 100 - (difference / widget.actualSize * 100);
    //uncomment this
    User user = FirebaseAuth.instance.currentUser!;
    //
    final List<Map<String, dynamic>> measurements = widget.actualSize.entries.map((entry) {
      final name = entry.key;
      final value = entry.value ?? 0.0;
      return {
        'name': name,
        'measurementInches': cmToInches(value),
        'measurementCm': value,
      };
    }).toList();


    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Results for Size ${widget.selectedSize}",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: kPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      File(widget.capturedImagePath),
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ToggleButtons(
                            isSelected: [isInches, !isInches],
                            onPressed: (index) {
                              setState(() {
                                isInches = index == 0;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            selectedColor: Colors.white,
                            fillColor: kPrimaryColor,
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text("Inches"),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text("Centimeters"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      children: [
                        // Table Header
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Name",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Inches",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Centimeters",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        ...measurements.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry['name'],
                                    style: const TextStyle(fontSize: 16)),
                                Text(
                                  isInches
                                      ? entry['measurementInches']
                                          .toStringAsFixed(2)
                                      : entry['measurementCm']
                                          .toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  isInches
                                      ? entry['measurementCm']
                                          .toStringAsFixed(2)
                                      : entry['measurementInches']
                                          .toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            // Upload image
                            File imageFile = File(widget.capturedImagePath);
                            // String imageUrl = await uploadImage(imageFile);
                            saveImageToGallery(imageFile.path);

                            // Store data in Firestore
                            //uncomment this
                            await storeMeasurementData(
                                imageFile.path,
                                user.uid,
                                user.email!,
                                widget.actualSize,
                                widget.selectedSize,
                                'Sweatshirt Sizes');

                            Navigator.pop(context);
                          } catch (e) {
                            print("Error: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Back"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> getCurrentUserData() async {
  try {
    // Get the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      // Fetch the user data from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Retrieve data from the document
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        String username = userData['username'] ?? "No username";
        String email = userData['email'] ?? "No email";
        String selectedSize = userData['selectedSize'] ?? "No selected size";
        String imageUrl = userData['imageUrl'] ?? "No image URL";

        // Output the retrieved data
        print("Username: $username");
        print("Email: $email");
        print("Selected Size: $selectedSize");
        print("Image URL: $imageUrl");
      } else {
        print("User document not found.");
      }
    } else {
      print("No user is logged in.");
    }
  } catch (e) {
    print("Error fetching user data: $e");
  }
}
