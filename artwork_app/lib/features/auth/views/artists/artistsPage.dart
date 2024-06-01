import 'package:artwork_app/features/auth/views/artists/artistsDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtistsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artists Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('artists').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final List<DocumentSnapshot> artists = snapshot.data!.docs;

          return ListView.separated(
            itemCount: artists.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (context, index) => _buildArtistItem(context, artists[index]),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildArtistItem(BuildContext context, DocumentSnapshot artistSnapshot) {
    final artist = artistSnapshot.data() as Map<String, dynamic>;
    final String artistName = artist['artistName'] ?? '';
    final String country = artist['country'] ?? '';
    final String information = artist['information'] ?? '';
    final String artistPhotoName = artist['artistPhotoName'] ?? '';
    final String artworkName = artist['artworkName'] ?? '';
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return ListTile(
      title: Text(
        artistName,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        country,
        style: TextStyle(color: Colors.white),
      ),
      trailing: currentUserUid == 'XS0BdY1k6vcAyVWA1jWdljyGnoh1'
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    _deleteArtist(context, artistSnapshot.id);
                  },
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.edit),
                  color: Colors.blue,
                  onPressed: () {
                    _editArtist(context, artistSnapshot);
                  },
                ),
              ],
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDetailPage(
              artistName: artistName,
              country: country,
              artistPhotoName: artistPhotoName,
              information: information,
              artworkName: artworkName,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid != null && currentUserUid == 'XS0BdY1k6vcAyVWA1jWdljyGnoh1') {
      return FloatingActionButton(
        onPressed: () {
          _addNewArtist(context);
        },
        child: Icon(Icons.add),
      );
    } else {
      return Container();
    }
  }

  void _addNewArtist(BuildContext context) {
    String artistName = '';
    String country = '';
    String information = '';
    String artistPhotoName = '';
    String artworkName = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Artist'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Artist Name'),
                onChanged: (value) {
                  artistName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Country'),
                onChanged: (value) {
                  country = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Information'),
                onChanged: (value) {
                  information = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Artist Photo Name'),
                onChanged: (value) {
                  artistPhotoName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Artwork Name'),
                onChanged: (value) {
                  artworkName = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (artistName.isNotEmpty && country.isNotEmpty && information.isNotEmpty && artistPhotoName.isNotEmpty && artworkName.isNotEmpty) {
                _uploadArtistToFirestore(context, artistName, country, information , artistPhotoName, artworkName);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter all the details.'),
                  ),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _uploadArtistToFirestore(BuildContext context, String artistName, String country, String information, String artistPhotoName, String artworkName) async {
    try {
      await FirebaseFirestore.instance.collection('artists').add({
        'artistName': artistName,
        'country': country,
        'information': information,
        'artistPhotoName': artistPhotoName,
        'artworkName': artworkName,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Artist added successfully.'),
        ),
      );
    } catch (e) {
      print('Error adding artist: $e');
    }
  }

  void _editArtist(BuildContext context, DocumentSnapshot artistSnapshot) {
    final artist = artistSnapshot.data() as Map<String, dynamic>;
    String artistName = artist['artistName'] ?? '';
    String country = artist['country'] ?? '';
    String information = artist['information'] ?? '';
    String artistPhotoName = artist['artistPhotoName'] ?? '';
    String artworkName = artist['artworkName'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Artist'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Artist Name'),
                controller: TextEditingController(text: artistName),
                onChanged: (value) {
                  artistName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Country'),
                controller: TextEditingController(text: country),
                onChanged: (value) {
                  country = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Information'),
                controller: TextEditingController(text: information),
                onChanged: (value) {
                  information = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Artist Photo Name'),
                controller: TextEditingController(text: artistPhotoName),
                onChanged: (value) {
                  artistPhotoName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Artwork Name'),
                controller: TextEditingController(text: artworkName),
                onChanged: (value) {
                  artworkName = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (artistName.isNotEmpty && country.isNotEmpty && information.isNotEmpty && artistPhotoName.isNotEmpty && artworkName.isNotEmpty) {
                _updateArtist(context, artistSnapshot.id, artistName, country, information, artistPhotoName, artworkName);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter all the details.'),
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateArtist(BuildContext context, String artistId, String artistName, String country, String information, String artistPhotoName, String artworkName) async {
    try {
      await FirebaseFirestore.instance.collection('artists').doc(artistId).update({
        'artistName': artistName,
        'country': country,
        'information': information,
        'artistPhotoName': artistPhotoName,
        'artworkName': artworkName,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Artist updated successfully.'),
        ),
      );
    } catch (e) {
      print('Error updating artist: $e');
    }
  }

  void _deleteArtist(BuildContext context, String artistId) async {
    try {
      await FirebaseFirestore.instance.collection('artists').doc(artistId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Artist deleted successfully.'),
        ),
      );
    } catch (e) {
      print('Error deleting artist: $e');
    }
  }
}

