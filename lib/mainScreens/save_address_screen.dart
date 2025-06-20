import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:client/global/global.dart';
import 'package:client/models/address.dart';
import 'package:client/widgets/simple_Appbar.dart';
import 'package:client/widgets/text_field.dart';

class SaveAddressScreen extends StatelessWidget {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _flatNumber = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _completeAddress = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  List<Placemark>? placemarks;
  Position? position;

  String completeAddress = '';
  getUserLocationAddress() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    placemarks =
        await placemarkFromCoordinates(position!.latitude, position!.longitude);

    Placemark pMarks = placemarks![0];
    completeAddress =
        '${pMarks.subThoroughfare} ${pMarks.thoroughfare},${pMarks.subLocality} ${pMarks.locality},${pMarks.subAdministrativeArea}, ${pMarks.administrativeArea} ${pMarks.postalCode},${pMarks.country}';
    // _locationController.text = completeAddress;

    String fullAddress =
        '${pMarks.subThoroughfare} ${pMarks.thoroughfare}, ${pMarks.subLocality} ${pMarks.locality}, ${pMarks.subAdministrativeArea}, ${pMarks.administrativeArea} ${pMarks.postalCode}, ${pMarks.country} ';

    _locationController.text = fullAddress;
    _flatNumber.text =
        '${pMarks.subThoroughfare} ${pMarks.thoroughfare}, ${pMarks.subLocality} ${pMarks.locality}, ';

    _city.text =
        '${pMarks.subAdministrativeArea}, ${pMarks.administrativeArea} ,${pMarks.postalCode}';
    _state.text = '${pMarks.country}';

    _completeAddress.text = fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: "save to serve",
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //save address info
          if (formKey.currentState!.validate()) {
            final model = Address(
              name: _name.text.trim(),
              state: _state.text.trim(),
              fullAddress: _completeAddress.text.trim(),
              phoneNumber: _phoneNumber.text.trim(),
              flatNumber: _flatNumber.text.trim(),
              city: _city.text.trim(),
              lat: position!.latitude.toString(),
              lng: position!.longitude.toString(),
              // locationController: _locationController.text.trim(),
            ).toJson();

            FirebaseFirestore.instance
                .collection("users")
                .doc(sharedPreferences!.getString("uid"))
                .collection("userAddress")
                .doc(DateTime.now().millisecondsSinceEpoch.toString())
                .set(model)
                .then((value) {
              Fluttertoast.showToast(
                  msg: "La nouvelle adresse a été enregistrée");

              formKey.currentState!.reset();
            });
          }
        },
        label: const Text("Enregistrer maintenant"),
        icon: const Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 6,
            ),
            const Align(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Enregistrer une nouvelle adresse :",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.person_pin_circle,
                color: Colors.black,
                size: 35,
              ),
              title: Container(
                width: 250,
                child: const TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  // controller: _locationController,
                  decoration: InputDecoration(
                      hintText: "Quelle est votre adresse ?",
                      hintStyle: TextStyle(color: Colors.black)),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              onPressed: () {
                //get current location
                getUserLocationAddress();
              },
              icon: const Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.cyan)))),
              label: const Text(
                "Get my address",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  MyTextField(
                    hint: "nom",
                    controller: _name,
                  ),
                  MyTextField(
                    hint: "Numéro de téléphone",
                    controller: _phoneNumber,
                  ),
                  MyTextField(
                    hint: "Ville",
                    controller: _city,
                  ),
                  MyTextField(
                    hint: " Région",
                    controller: _state,
                  ),
                  MyTextField(
                    hint: "Adresse",
                    controller: _flatNumber,
                  ),
                  MyTextField(
                    hint: "Adresse complète",
                    controller: _completeAddress,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
