import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ajout pour Firestore

class Privipage extends StatefulWidget {
  const Privipage({super.key});

  @override
  State<Privipage> createState() => _PrivipageState();
}

class _PrivipageState extends State<Privipage> {
  late int n = 1;
  Future<void> _delete1() async {
    try {
      final user = FirebaseAuth.instance.currentUser?.uid;
      // 1. Rechercher les documents à supprimer dans playinpod
      final snapshot = await FirebaseFirestore.instance
          .collection('search')
          .where('userId', isEqualTo: user)
          .get();

      // 2. Supprimer chaque document trouvé
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting from playinpod or updating playlist: $e');
    }
  }

  Future<void> _delete2() async {
    try {
      final user = FirebaseAuth.instance.currentUser?.uid;
      // 1. Rechercher les documents à supprimer dans playinpod
      final snapshot = await FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: user)
          .get();

      // 2. Supprimer chaque document trouvé
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting from playinpod or updating playlist: $e');
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this?"),
          actions: [
            TextButton(
              child: const Text("No", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text("Yes", style: TextStyle(color: Color(0xFF754CEF))),
              onPressed: () {
                Navigator.of(context).pop();
                _delete1();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog1() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this?"),
          actions: [
            TextButton(
              child: const Text("No", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text("Yes", style: TextStyle(color: Color(0xFF754CEF))),
              onPressed: () {
                Navigator.of(context).pop();
                _delete2();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size e = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              top: e.height * 0.01,
              left: e.width * 0.03,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.network(
                  s18,
                  width: e.width * 0.07,
                  height: e.width * 0.07,
                ),
              ),
            ),
            Positioned(
                top: e.height * 0.1,
                left: e.width * 0.07,
                child: Text(
                  "Information Personal",
                  style: TextStyle(
                      fontSize: e.width * 0.05, fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: e.height * 0.185,
                left: e.width * 0.07,
                child: Text(
                  "Motpass",
                  style: TextStyle(
                      fontSize: e.width * 0.04,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: e.height * 0.15,
                left: e.width * 0.3,
                child: Text(
                  "........",
                  style: TextStyle(
                    fontSize: e.width * 0.1,
                  ),
                )),
            Positioned(
              top: e.height * 0.17,
              right: e.width * 0.01,
              child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/modif1',
                      arguments: {'n': 4},
                    );
                  },
                  child: Text(
                    ">",
                    style: TextStyle(
                        fontSize: e.width * 0.06, color: Colors.black),
                  )),
            ),
            Positioned(
                top: e.height * 0.25,
                left: e.width * 0.07,
                right: e.width * 0.07,
                child: Container(
                  width: e.width * 0.8,
                  height: e.height * 0.002, // Épaisseur de la ligne
                  color: Colors.grey[400],
                )),
            Positioned(
                top: e.height * 0.3,
                left: e.width * 0.07,
                child: Text(
                  "Activity",
                  style: TextStyle(
                      fontSize: e.width * 0.05, fontWeight: FontWeight.bold),
                )),
            Positioned(
              top: e.height * 0.37,
              left: e.width * 0.07,
              child: Container(
                  child: GestureDetector(
                      onTap: () {
                        _showDialog();
                      },
                      child: Row(children: [
                        Image.network(
                          s89,
                          width: e.width * 0.05,
                          height: e.height * 0.05,
                        ),
                        SizedBox(
                          width: e.width * 0.03,
                        ),
                        Text(
                          "Delete All Recently Search",
                          style: TextStyle(
                              fontSize: e.width * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                      ]))),
            ),
            Positioned(
              top: e.height * 0.44,
              left: e.width * 0.07,
              child: Container(
                  child: GestureDetector(
                      onTap: () {
                        _showDialog1();
                      },
                      child: Row(children: [
                        Image.network(
                          s14,
                          width: e.width * 0.05,
                          height: e.height * 0.05,
                        ),
                        SizedBox(
                          width: e.width * 0.03,
                        ),
                        Text(
                          "Delete All Podcast Viewed",
                          style: TextStyle(
                              fontSize: e.width * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                      ]))),
            ),
            Positioned(
                top: e.height * 0.55,
                left: e.width * 0.07,
                right: e.width * 0.07,
                child: Container(
                  width: e.width * 0.8,
                  height: e.height * 0.002, // Épaisseur de la ligne
                  color: Colors.grey[400],
                )),
            Positioned(
              top: e.height * 0.63,
              left: e.width * 0.04,
              child: Image.asset(
                "images/delete.png",
                width: e.width * 0.06,
                height: e.width * 0.06,
              ),
            ),
            Positioned(
              top: e.height * 0.63,
              left: e.width * 0.15,
              child: Text(
                "Delete User",
                style: TextStyle(
                    fontSize: e.width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
