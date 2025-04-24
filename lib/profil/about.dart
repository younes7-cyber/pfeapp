/*import 'package:flutter/material.dart';
import 'package:pfeapp/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class Aboutpage extends StatefulWidget {
  const Aboutpage({super.key});

  @override
  State<Aboutpage> createState() => _AboutpageState();
}

class _AboutpageState extends State<Aboutpage> {
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d\'ouvrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size i = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              top: i.height * 0.01,
              left: i.width * 0.03,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.network(
                  s18,
                  width: i.width * 0.07,
                  height: i.width * 0.07,
                ),
              ),
            ),
            Positioned(
                top: i.height * 0.02,
                left: i.width * 0.15,
                child: Text(
                  "About Us",
                  style: TextStyle(
                      fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: i.height * 0.12,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      _launchUrl('https://www.facebook.com/share/1HDx37aSDH/');
                    },
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.1,
                          width: i.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(s16),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.02),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Join Our Channel In Facebook",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                top: i.height * 0.28,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      _launchUrl(
                          'https://www.instagram.com/younesyounes2777?igsh=MXdwNmZkY2swcjN5bw==');
                    },
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.1,
                          width: i.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(s83),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.02),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Join Our Channel In Instagram",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                top: i.height * 0.44,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      _launchUrl('https://t.me/Younesbensliman');
                    },
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.1,
                          width: i.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(s84),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.02),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Join Our Channel In Telegramme",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                top: i.height * 0.6,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.08,
                          width: i.width * 0.08,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(s35),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.03),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Send A report If You Need Help",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      )),
    );
  }
}
*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ajout pour Firestore

class Aboutpage extends StatefulWidget {
  const Aboutpage({super.key});

  @override
  State<Aboutpage> createState() => _AboutpageState();
}

class _AboutpageState extends State<Aboutpage> {
  // Contrôleur pour le champ de texte
  final TextEditingController _reportController = TextEditingController();

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d\'ouvrir $url');
    }
  }

  // Fonction pour envoyer le rapport à Firestore
  Future<void> _sendReport(String reportText) async {
    final user = FirebaseAuth.instance.currentUser?.uid;
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'date': Timestamp.now(),
        'text': reportText,
        'userss': user,
      });

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapport envoyé avec succès')),
      );
    } catch (e) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi: $e')),
      );
    }
  }

  // Fonction pour afficher le dialogue de rapport
  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Envoyer un rapport'),
          content: TextField(
            controller: _reportController,
            decoration: const InputDecoration(
              hintText: 'Décrivez votre problème ici...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
                _reportController.clear(); // Vider le champ
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_reportController.text.trim().isNotEmpty) {
                  _sendReport(_reportController.text);
                  Navigator.of(context).pop(); // Fermer le dialogue
                  _reportController.clear(); // Vider le champ
                } else {
                  // Message si le champ est vide
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez écrire un message')),
                  );
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Libérer le contrôleur quand la page est détruite
    _reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size i = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              top: i.height * 0.01,
              left: i.width * 0.03,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.network(
                  s18,
                  width: i.width * 0.07,
                  height: i.width * 0.07,
                ),
              ),
            ),
            Positioned(
                top: i.height * 0.02,
                left: i.width * 0.15,
                child: Text(
                  "About Us",
                  style: TextStyle(
                      fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: i.height * 0.12,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      _launchUrl('https://www.facebook.com/share/1HDx37aSDH/');
                    },
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.1,
                          width: i.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(s16),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.02),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Join Our Channel In Facebook",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                top: i.height * 0.28,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      _launchUrl(
                          'https://www.instagram.com/younesyounes2777?igsh=MXdwNmZkY2swcjN5bw==');
                    },
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.1,
                          width: i.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(s83),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.02),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Join Our Channel In Instagram",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                top: i.height * 0.44,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      _launchUrl('https://t.me/Younesbensliman');
                    },
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.1,
                          width: i.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(s84),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.02),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Join Our Channel In Telegramme",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                top: i.height * 0.6,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      _showReportDialog(); // Afficher le dialogue de rapport
                    },
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.08,
                          width: i.width * 0.08,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(s35),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.03),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Send A report If You Need Help",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      )),
    );
  }
}
