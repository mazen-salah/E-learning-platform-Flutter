// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tit_for_tat/shared/widgets/link_button.dart';

// Firestore collections
CollectionReference vouchersCollection =
    FirebaseFirestore.instance.collection('vouchers');
CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

// Firestore fields
const String isUsedField = 'isUsed';
const String valueField = 'value';
const String walletField = 'balance';

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
        const SnackBar(
            backgroundColor: Colors.red, content: Text('Invalid voucher code')),
      );
      return;
    }
    final isUsed = voucherData.data()!['isUsed'] ?? false;
    final int voucherValue = voucherData.data()!['value'] ?? 0;
    if (isUsed) {
      // Voucher already used
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.orange,
            content: Text('This voucher has already been used')),
      );
      return;
    }
    await _firestore.collection('vouchers').doc(voucherCode).update({
      'isUsed': true,
    });
    await _updateWalletBalance(_balance + voucherValue);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Voucher redeemed successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController voucherController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Voucher'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                      if (voucherController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Please enter a voucher code'),
                          ),
                        );
                        setState(() {
                          _isRedeeming = false;
                        });
                        return;
                      } else {
                        await _redeemVoucher(
                          voucherController.text,
                        );
                      }

                      setState(() {
                        _isRedeeming = false;
                      });
                    },
              child: _isRedeeming
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Center(child: Text('Redeem')),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black38,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("تواصل معنا للدفع",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    linkButton("whatsapp", "whatsapp", Icons.chat_outlined),
                    linkButton("phone", "phone", Icons.phone),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
