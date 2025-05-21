import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:pfeapp/constants.dart';

class CreateChannelPage extends StatefulWidget {
  // ignore: use_super_parameters
  const CreateChannelPage({Key? key}) : super(key: key);

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImageFile;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ignore: non_constant_identifier_names
  late int CH;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is int) {
      CH = args;
    } else {
      CH = 0; // Valeur par défaut si aucun argument n'est passé
    }
  }

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
      return false;
    }
  }

  Future<void> _pickImage() async {
    if (await _requestStoragePermission()) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowCompression: true,
        );

        if (result != null && result.files.isNotEmpty) {
          if (mounted) {
            setState(() {
              _selectedImageFile = File(result.files.single.path!);
            });
          }
        }
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  Future<String> _uploadImageToSupabase() async {
    if (_selectedImageFile == null) {
      return s21; // Retourner l'URL par défaut si aucune image n'est sélectionnée
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final fileName =
          'channel/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Téléverser l'image sur Supabase
      await Supabase.instance.client.storage
          .from('pfeapp')
          .upload(fileName, _selectedImageFile!);

      // Récupération de l'URL publique
      final publicUrl = Supabase.instance.client.storage
          .from('pfeapp')
          .getPublicUrl(fileName);

      if (publicUrl.isNotEmpty) {
        return publicUrl; // Retourner l'URL publique
      } else {
        return s21; // Retourner l'URL par défaut si aucune URL publique
      }
    } catch (e) {
      return s21; // Retourner l'URL par défaut en cas d'erreur
    }
  }

  String? errorMessage;
  Future<void> _saveChannelData() async {
    final channelName = _nameController.text.trim();

    if (channelName.isEmpty) {
      if (mounted) {
        setState(() {
          errorMessage = "channel name canot be empty";
        });
      }
      return;
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }

      // Obtenir l'URL de l'image (soit uploadée, soit l'URL par défaut)
      final photoUrl = await _uploadImageToSupabase();

      final channelData = {
        'userId': currentUser.uid,
        'name': channelName,
        'photoUrl': photoUrl, // URL de l'image (ou URL par défaut)
        'followers': 0,
        'following': 0,
        'report': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('channels').add(channelData);
      await docRef
          .update({'id': docRef.id}); // Récupérer l'ID généré par Firestore

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/sucess1',
          (route) => false,
        );
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => isLoading = true);
      }
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Annimationwidjet()
            : Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
                return Container(
                  decoration: BoxDecoration(
                    color:
                        themeProvider.isDarkMode ? Colors.black : Colors.white,
                  ),
                  child: Stack(
                    children: [
                      // Back Button
                      Positioned(
                        top: screenSize.height * 0.01,
                        left: screenSize.width * 0.03,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Image.network(
                            themeProvider.isDarkMode ? s97 : s18,
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

                      // Title
                      Positioned(
                        top: screenSize.height * 0.37,
                        left: screenSize.width * 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "First Name",
                              style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            errorMessage != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      errorMessage!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      Positioned(
                        top: screenSize.height * 0.4,
                        left: screenSize.width * 0.07,
                        right: screenSize.width * 0.07,
                        child: TextFormField(
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name cannot be empty';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                errorMessage = null;
                              });
                            }
                          },
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),
                            hintText: "Enter Channel Name",
                            errorText: errorMessage,
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(screenSize.width * 0.028),
                              child: Image.network(
                                s29,
                                width: screenSize.width * 0.05,
                                height: screenSize.width * 0.05,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(screenSize.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(screenSize.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(screenSize.width * 0.05)),
                              borderSide: const BorderSide(
                                color: Colors.lightBlue,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(screenSize.width * 0.05)),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
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
                            Text(
                              "   Photos (Optionnel)",
                              style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold),
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
                                  borderRadius: BorderRadius.circular(
                                      screenSize.width * 0.05),
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
                                borderRadius: BorderRadius.circular(
                                    screenSize.width * 0.05),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: Text(
                                  _selectedImageFile?.path ?? "",
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
                );
              }),
      ),
    );
  }
}
