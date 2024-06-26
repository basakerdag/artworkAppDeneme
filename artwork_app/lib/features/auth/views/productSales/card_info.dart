import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardInfoPage extends StatefulWidget {
  @override
  _CardInfoPageState createState() => _CardInfoPageState();
}

class _CardInfoPageState extends State<CardInfoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  bool _orderPlaced = false;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with saving data
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

      // Create a unique ID for each payment information entry
      String paymentId = DateTime.now().millisecondsSinceEpoch.toString();

      userCollection.doc(userId).collection('inf').doc('payments').collection(paymentId).doc('payment').set({
        'cardNumber': _cardNumberController.text,
        'expiryDate': _expiryDateController.text,
        'cvv': _cvvController.text,
        'address': _addressController.text,
      }).then((value) {
        // Data saved successfully
        print('Payment information saved.');
        setState(() {
          _orderPlaced = true;
        });
      }).catchError((error) {
        // Error handling
        print('Error saving payment information: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kart Bilgileri',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Kart Numarası',
                  hintText: 'XXXX-XXXX-XXXX-XXXX',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kart numaranızı girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Son Kullanma Tarihi',
                  hintText: 'MM/YY',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen son kullanma tarihini girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen CVV girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adres',
                  hintText: 'Adresinizi girin',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adresinizi girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Ödemeyi Tamamla'),
              ),
              SizedBox(height: 20),
              if (_orderPlaced)
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Siparişiniz verildi. Bizi tercih ettiğiniz için teşekkür ederiz.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          setState(() {
                            _orderPlaced = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
