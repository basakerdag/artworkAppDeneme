import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final String productName;
  final String productArtist;
  final String productDescription;
  final String qrCodeUrl;
  final String imageName;
  final double imageWidth;
  final double imageHeight;
  final double price;

  const ProductDetailPage({
    Key? key,
    required this.productName,
    required this.productArtist,
    required this.productDescription,
    required this.qrCodeUrl,
    required this.imageName,
    required this.imageWidth,
    required this.imageHeight,
    required this.price,
    required void Function() sendNotification, // Değişiklik burada yapıldı
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addToCart() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      // Firestore'a veri ekleme
      await _firestore.collection('users').doc(userId).collection('shop').add({
        'photoName': widget.imageName,
        'productName': widget.productName,
        'price': widget.price,
      });

      // Snackbar ile mesaj gösterme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ürün sepetinize eklendi'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı girişi yapılmamış'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addToFavorites() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      // Firestore'a veri ekleme
      await _firestore.collection('users').doc(userId).collection('fav').add({
        'photoName': widget.imageName,
        'productName': widget.productName,
        'price': widget.price,
      });

      // Snackbar ile mesaj gösterme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ürün favorilerinize eklendi'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı girişi yapılmamış'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    widget.productName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  Text(
                    '* * ${widget.productArtist} * *',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.pink,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _addToCart,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.shopping_cart, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      '${widget.price.toString()} \$',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Image.asset(
                  'assets/images/${widget.imageName}',
                  fit: BoxFit.cover,
                  width: widget.imageWidth,
                  height: widget.imageHeight,
                ),
              ],
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _addToFavorites,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Favorilere eklemek ister misiniz?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.favorite, color: Colors.white),
                  ],
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
