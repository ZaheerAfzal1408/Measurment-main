import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:measuremate/Screens/results/store_details.dart';
import '../../constants.dart';

class DenimJeanMeasurementResult extends StatefulWidget {
  final Map<String, double> actualSizes;
  final String selectedSize;
  final String capturedImagePath;

  DenimJeanMeasurementResult({
    super.key,
    required this.actualSizes,
    required this.selectedSize,
    required this.capturedImagePath,
  });

  @override
  _DenimJeanMeasurementResultState createState() =>
      _DenimJeanMeasurementResultState();
}

class _DenimJeanMeasurementResultState
    extends State<DenimJeanMeasurementResult> {
  bool isInches = true;

  double inchesToCm(double inches) => inches * 2.54;
  double cmToInches(double cm) => cm / 2.54;

  @override
  Widget build(BuildContext context) {
    //uncomment this
    User user = FirebaseAuth.instance.currentUser!;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Measurement Results for Size ${widget.selectedSize}"),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Name",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isInches ? "Inches" : "Centimeters",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Display each measurement from actualSizes
                        ...widget.actualSizes.entries.map((entry) {
                          double value = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  isInches
                                      ? value.toStringAsFixed(2)
                                      : inchesToCm(value).toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
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
                            widget.actualSizes,
                            widget.selectedSize,
                            'Denim Jeans Sizes');

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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
