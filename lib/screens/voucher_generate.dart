import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'voucher_redeem.dart';

class VoucherGeneratePage extends StatefulWidget {
  const VoucherGeneratePage({super.key});

  @override
  State<VoucherGeneratePage> createState() => _VoucherGeneratePageState();
}

class _VoucherGeneratePageState extends State<VoucherGeneratePage> {
  final TextEditingController _valueController = TextEditingController();
  List<QueryDocumentSnapshot> _vouchers = [];

  @override
  void initState() {
    super.initState();

    vouchersCollection
        .where(isUsedField, isEqualTo: false)
        .get()
        .then((querySnapshot) {
      setState(() {
        _vouchers = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Voucher'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Enter voucher value:'),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Generate Voucher'),
                onPressed: () {
                  // Generate a new voucher
                  int value = int.tryParse(_valueController.text) ??
                      0; // The value of the voucher
                  String voucherId = vouchersCollection
                      .doc()
                      .id; // Generate a unique ID for the voucher

                  // Add the voucher to the vouchers collection in Firestore
                  vouchersCollection.doc(voucherId).set({
                    isUsedField: false,
                    valueField: value,
                  });

                  // Display a message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voucher generated successfully!'),
                    ),
                  );

                  setState(() {
                    _valueController.clear();
                    vouchersCollection
                        .where(isUsedField, isEqualTo: false)
                        .get()
                        .then((querySnapshot) {
                      setState(() {
                        _vouchers = querySnapshot.docs;
                      });
                    });
                  });
                },
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(height: 16),
              const Text('Non-used vouchers:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _vouchers.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_vouchers[index].exists) {
                      int value = _vouchers[index].get(valueField);
                      String voucherCode = _vouchers[index].id;
                      return ListTile(
                        title: Text('Voucher ${index + 1}:\n $voucherCode'),
                        subtitle: Text('Value: $value'),
                        trailing: IconButton(
                          icon: const Icon(Icons.content_copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: voucherCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Voucher code copied to clipboard!'),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
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
