// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntentData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stripe Payment"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: (() async {
                await makePayment();
              }),
              child: Container(
                height: 50,
                width: 200,
                decoration: const BoxDecoration(color: Colors.green),
                child: const Center(
                  child: Text("Pay"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

// MAke Payment Function
//-------------------------------------------------------------------------//
  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent("20", "USD");
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!["clint_secret"],
        style: ThemeMode.dark,
        merchantDisplayName: "ANSh",
      ));
    } catch (e) {
      debugPrint("exception${e.toString()}");
    }
  }

// payment sheet
//---------------------------------------------------------------------------//
  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntentData!["clint_secret"],
        confirmPayment: true,
      ));
      setState(() {
        paymentIntentData = null;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar((const SnackBar(
        content: Text("Paid successfully"),
      )));
    } on StripeException catch (e) {
      debugPrint(e.toString());
      showDialog(
          context: context,
          builder: ((context) {
            return const AlertDialog(
              content: Text("Cancelled"),
            );
          }));
    }
  }

//---------------------------------------------------------------------------//
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        "amount": calculateAmount(amount),
        "currency": currency,
        "payment_method_types[]": "card"
      };

      var responce = await http.post(
          Uri.parse("ENTER THE URL PROVIDED BY STRIPE HERE"),
          body: body,
          headers: {
            "Authorization": "bearer ENTER_YOUR_SECRET_KEY_HERE_OF_STRIPE",
            "Content-Type": "application/x-www-form-urlencoded"
          });

      return jsonDecode(responce.body.toString());
    } catch (e) {
      debugPrint("exception${e.toString()}");
    }
  }

//calculate Amount function
//-------------------------------------------------------------------------//

  calculateAmount(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }
}
