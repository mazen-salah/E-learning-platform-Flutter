// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

// Firestore collections
CollectionReference vouchersCollection =
    FirebaseFirestore.instance.collection('vouchers');
CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

// Firestore fields
const String isUsedField = 'isUsed';
const String valueField = 'value';
const String walletField = 'balance';

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

    // Fetch all non-used vouchers from Firestore
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
                // A divider to separate the button and the list of vouchers

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

class VoucherRedeemPage extends StatefulWidget {
  const VoucherRedeemPage({Key? key}) : super(key: key);

  @override
  State<VoucherRedeemPage> createState() => _VoucherRedeemPageState();
}

class _VoucherRedeemPageState extends State<VoucherRedeemPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _balance = 0;
  bool _isRedeeming = false;

  @override
  void initState() {
    super.initState();
    _getWalletBalance();
  }

  Future<void> _getWalletBalance() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    final walletData =
        await _firestore.collection('wallets').doc(user.uid).get();
    if (!walletData.exists) {
      return;
    }
    setState(() {
      _balance = walletData.data()!['balance'] ?? 0;
    });
  }

  Future<void> _updateWalletBalance(int newBalance) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await _firestore.collection('wallets').doc(user.uid).update({
      'balance': newBalance,
    });
    setState(() {
      _balance = newBalance;
    });
  }

  Future<void> _redeemVoucher(String voucherCode) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    final voucherData =
        await _firestore.collection('vouchers').doc(voucherCode).get();
    if (!voucherData.exists) {
      // Voucher code not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid voucher code')),
      );
      return;
    }
    final isUsed = voucherData.data()!['isUsed'] ?? false;
    final int voucherValue = voucherData.data()!['value'] ?? 0;
    if (isUsed) {
      // Voucher already used
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This voucher has already been used')),
      );
      return;
    }
    await _firestore.collection('vouchers').doc(voucherCode).update({
      'isUsed': true,
    });
    await _updateWalletBalance(_balance + voucherValue);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voucher redeemed successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController voucherController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Voucher'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your wallet balance:',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$_balance LE',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const Text(
              'Enter voucher code:',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: 200,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a voucher code';
                  }
                  return null;
                },
                controller: voucherController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Voucher code',
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _isRedeeming
                  ? null
                  : () async {
                      setState(() {
                        _isRedeeming = true;
                      });
                      await _redeemVoucher(
                        voucherController.text,
                      );

                      setState(() {
                        _isRedeeming = false;
                      });
                    },
              child: _isRedeeming
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Redeem'),
            ),
          ],
        ),
      ),
    );
  }
}
