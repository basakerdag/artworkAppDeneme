import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  late TextEditingController companyController;
  late TextEditingController missionController;
  late TextEditingController visionController;

  @override
  void initState() {
    super.initState();
    companyController = TextEditingController();
    missionController = TextEditingController();
    visionController = TextEditingController();
  }

  @override
  void dispose() {
    companyController.dispose();
    missionController.dispose();
    visionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/artwork-app-a4879.appspot.com/o/images%2Fmor.webp?alt=media&token=4694594c-5ac4-42b4-9883-dc3d95d2e3d7'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32),
                Text(
                  'Added Values:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _buildAddedValuesList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: currentUserUid == 'XS0BdY1k6vcAyVWA1jWdljyGnoh1'
          ? FloatingActionButton(
              onPressed: () {
                _showAddValueDialog(context);
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _showAddValueDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Values'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Our Company', companyController),
              _buildTextField('Mission', missionController),
              _buildTextField('Vision', visionController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addValuesToFirebase();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Enter $labelText value',
        labelText: labelText,
      ),
    );
  }

  void _addValuesToFirebase() {
    FirebaseFirestore.instance.collection('aboutUs').add({
      'companyValue': companyController.text.trim(),
      'missionValue': missionController.text.trim(),
      'visionValue': visionController.text.trim(),
      'timestamp': Timestamp.now(),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Values added successfully.'),
        ),
      );
    }).catchError((error) {
      print('Error adding values: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding values.'),
        ),
      );
    });

    // Temizleme işlemi
    companyController.clear();
    missionController.clear();
    visionController.clear();
  }

  Widget _buildAddedValuesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('aboutUs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data?.docs ?? [];

        return ListView.builder(
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final valueData = data[index].data() as Map<String, dynamic>;
            final companyValue = valueData['companyValue'] ?? '';
            final missionValue = valueData['missionValue'] ?? '';
            final visionValue = valueData['visionValue'] ?? '';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  'Our Company: $companyValue',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mission: $missionValue',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Vision: $visionValue',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: currentUserUid == 'XS0BdY1k6vcAyVWA1jWdljyGnoh1'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _deleteValue(data[index].id);
                            },
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon:
  Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: () {
                              _showEditValueDialog(context, data[index].id, valueData);
                            },
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showEditValueDialog(BuildContext context, String docId, Map<String, dynamic> valueData) async {
    companyController.text = valueData['companyValue'] ?? '';
    missionController.text = valueData['missionValue'] ?? '';
    visionController.text = valueData['visionValue'] ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Values'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Our Company', companyController),
              _buildTextField('Mission', missionController),
              _buildTextField('Vision', visionController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateValuesInFirebase(docId);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateValuesInFirebase(String docId) {
    FirebaseFirestore.instance.collection('aboutUs').doc(docId).update({
      'companyValue': companyController.text.trim(),
      'missionValue': missionController.text.trim(),
      'visionValue': visionController.text.trim(),
      'timestamp': Timestamp.now(),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Values updated successfully.'),
        ),
      );
    }).catchError((error) {
      print('Error updating values: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating values.'),
        ),
      );
    });

    // Temizleme işlemi
    companyController.clear();
    missionController.clear();
    visionController.clear();
  }

  void _deleteValue(String docId) {
    FirebaseFirestore.instance.collection('aboutUs').doc(docId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Value deleted successfully.'),
        ),
      );
    }).catchError((error) {
      print('Error deleting value: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting value.'),
        ),
      );
    });
  }
}
