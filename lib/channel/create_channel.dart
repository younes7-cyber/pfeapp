import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:pfeapp/constants.dart';

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({Key? key}) : super(key: key);

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImageFile;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      _showSnackBar("Storage permission denied");
      return false;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage() async {
    if (await _requestStoragePermission()) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowCompression: true,
        );

        if (result != null && result.files.isNotEmpty) {
          setState(() {
            _selectedImageFile = File(result.files.single.path!);
          });
        }
      } catch (e) {
        _showSnackBar("Error picking image: $e");
      }
    }
  }

  Future<String> _uploadImageToSupabase() async {
    // Si aucune image n'est sélectionnée, retourner l'URL par défaut
    if (_selectedImageFile == null) {
      return s21; // URL par défaut (par exemple : un lien vers une image par défaut)
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final fileName =
          'channel/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload de l'image sur Supabase
      /*final response = await Supabase.instance.client.storage
          .from('pfeapp')
          .upload(fileName, _selectedImageFile!);

      // Vérification de la réponse de l'upload
         if (response.error != null) {
      debugPrint('Upload error: ${response.error!.message}');
      return s21; // En cas d'erreur, utiliser l'URL par défaut
    }*/

      // Récupération de l'URL publique
      final publicUrl = Supabase.instance.client.storage
          .from('pfeapp')
          .getPublicUrl(fileName);

      // Vérifier si l'URL publique est valide
      if (publicUrl.isNotEmpty) {
        debugPrint('Image uploaded successfully: $publicUrl');
        return publicUrl; // Retourner l'URL publique
      } else {
        debugPrint('Failed to get public URL.');
        return s21; // Utiliser l'URL par défaut si aucune URL publique n'est générée
      }
    } catch (e) {
      // Gestion des erreurs
      debugPrint('Error uploading image to Supabase: $e');
      return s21; // Retourner l'URL par défaut en cas d'erreur
    }
  }

  Future<void> _saveChannelData() async {
    final channelName = _nameController.text.trim();

    if (channelName.isEmpty) {
      _showSnackBar("Channel name cannot be empty");
      return;
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showSnackBar("No user logged in");
        return;
      }

      // Obtenir l'URL de l'image (soit uploadée, soit l'URL par défaut)
      final photoUrl = await _uploadImageToSupabase();

      final channelData = {
        'userId': currentUser.uid,
        'name': channelName,
        'photoUrl': photoUrl, // URL de l'image (ou URL par défaut)
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Sauvegarder les données dans Firestore
      await _firestore.collection('channels').add(channelData);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/podly', (route) => false,
            arguments: {'selectedIndex': 2});
      }
    } catch (e) {
      debugPrint("Channel save error: $e");
      _showSnackBar("Error saving channel: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Stack(
            children: [
              // Back Button
              Positioned(
                top: screenSize.height * 0.01,
                left: screenSize.width * 0.03,
                child: IconButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/podly', (route) => false,
                      arguments: {'selectedIndex': 2}),
                  icon: Image.network(
                    s18,
                    width: screenSize.width * 0.07,
                    height: screenSize.width * 0.07,
                  ),
                ),
              ),

              // Title
              Positioned(
                top: screenSize.height * 0.2,
                left: screenSize.width * 0.1,
                child: Text(
                  "Let's Create Your Channel",
                  style: TextStyle(
                      fontSize: screenSize.width * 0.065,
                      fontWeight: FontWeight.bold),
                ),
              ),

              // Channel Name Input
              Positioned(
                top: screenSize.height * 0.37,
                left: screenSize.width * 0.1,
                child: const Text(
                  "Name Channel",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: screenSize.height * 0.4,
                left: screenSize.width * 0.07,
                right: screenSize.width * 0.07,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),
                    hintText: "Enter Channel Name",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(screenSize.width * 0.028),
                      child: Image.network(
                        s29,
                        width: screenSize.width * 0.05,
                        height: screenSize.width * 0.05,
                      ),
                    ),
                    border: _customBorder(screenSize),
                    enabledBorder: _customBorder(screenSize),
                    focusedBorder: _customBorder(screenSize),
                  ),
                ),
              ),

              // Photo Selection
              Positioned(
                top: screenSize.height * 0.53,
                left: screenSize.width * 0.1,
                child: Row(
                  children: [
                    Image.network(
                      s25,
                      width: screenSize.width * 0.05,
                      height: screenSize.width * 0.05,
                    ),
                    const Text(
                      "   Photos",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: screenSize.height * 0.56,
                left: screenSize.width * 0.1,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: screenSize.width * 0.07,
                        height: screenSize.width * 0.07,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(screenSize.width * 0.05),
                        ),
                        child: Image.network(s26),
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.05),
                    Container(
                      width: screenSize.width * 0.7,
                      height: screenSize.width * 0.13,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.05),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: Text(
                          _selectedImageFile?.path ?? "No image selected",
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Done Button
              Positioned(
                top: screenSize.height * 0.7,
                left: screenSize.width * 0.15,
                child: Container(
                  height: screenSize.height * 0.075,
                  width: screenSize.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius:
                        BorderRadius.circular(screenSize.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed:
                        _saveChannelData, // Fixed: Added () to call the method
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for consistent border styling
  OutlineInputBorder _customBorder(Size screenSize) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(screenSize.width * 0.05)),
      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
    );
  }
}
