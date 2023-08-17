import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class MyCustomWidget extends StatefulWidget {
  @override
  State<MyCustomWidget> createState() => _MyCustomWidgetState();
}

class _MyCustomWidgetState extends State<MyCustomWidget> {
  final TextEditingController _controller = TextEditingController();
  var getResult = 'QR Code Result';
  String userPhoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clean Iraq Scanner'),
          centerTitle: true,
          backgroundColor: Colors.green.shade500,
          shadowColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  scanQRCode();
                },
                child: const Text('Scan QR'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SelectableText(getResult),
              const SizedBox(
                height: 20.0,
              ),
              Visibility(
                visible: getResult == "This Is New User" ? true : false,
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: "Enter Admin name"),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        postData(userPhoneNumber, _controller.text);
                      },
                      child: const Text("sign up new user"),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;
      List<String> fields = qrCode.split('&');
      getData(fields[1]);
    } on PlatformException {
      getResult = 'Failed to scan QR Code.';
    }
  }

  void getData(String qrNumber) async {
    var url = Uri.parse(
        'https://clean-iraq-bottles.murtadha-altameemi2156.workers.dev/?phone=$qrNumber');
    var response = await http.get(url);
    final responseData = jsonDecode(response.body);
    responseData['Phone'] == null
        ? setState(() {
            getResult = 'This Is New User';
            userPhoneNumber = qrNumber;
          })
        : setState(() {
            getResult = 'you were here before';
          });
  }

  void postData(String phoneNumber, String admin) async {
    final url = Uri.parse(
        'https://clean-iraq-bottles.murtadha-altameemi2156.workers.dev/?phone=$userPhoneNumber&givenBy=$admin');
    final response = await http.post(
      url,
      body: jsonEncode(
        <String, dynamic>{
          'Phone': phoneNumber,
          'Given By': admin,
          'Created': DateTime.now().toString()
        },
      ),
    );
    if (response.statusCode == 200) {
      debugPrint('POST request successful');
      setState(() {
        getResult="$phoneNumber was added Sccessfully";
      });
    }
  }
}
