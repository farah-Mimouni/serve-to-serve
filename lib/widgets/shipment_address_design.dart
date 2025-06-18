import 'package:flutter/material.dart';
import 'package:client/models/address.dart';
import 'package:client/splashScreen/splash_screen.dart';

class ShipmentAddressDesign extends StatelessWidget {
  final Address? model;

  const ShipmentAddressDesign({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            "Détails de livraison : ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 5),
            child: Table(
              children: [
                TableRow(
                  children: [
                    const Text(
                      "Nom",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(model!.name.toString()),
                  ],
                ),
                TableRow(
                  children: [
                    const Text(
                      "Numéro de téléphone",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(model!.phoneNumber!),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            model!.fullAddress!,
            textAlign: TextAlign.justify,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MySplashScreen()));
              },
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.greenAccent, Colors.greenAccent],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: const Center(
                  child: Text(
                    "Retour",
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
