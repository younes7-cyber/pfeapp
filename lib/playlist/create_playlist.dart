import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:pfeapp/constants.dart';

class Createplaylistpage extends StatefulWidget {
  const Createplaylistpage({super.key});

  @override
  State<Createplaylistpage> createState() => _CreateplaylistpageState();
}

class _CreateplaylistpageState extends State<Createplaylistpage> {
  final List<SelectedListItem<String>> play = [
    SelectedListItem<String>(data: "Education"),
    SelectedListItem<String>(data: "Needs a freinds"),
    SelectedListItem<String>(data: "Nesdds a freinds"),
    SelectedListItem<String>(data: "Music"),
  ];
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _playlistController = TextEditingController();
  String? _selectedImagePath;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _playlistController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _pickImage() async {
    if (await _requestPermission()) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImagePath = result.files.single.path;
        });
      }
    }
  }

  late int o;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is int) {
      o = args;
    } else {
      o = 0; // Valeur par défaut si aucun argument n'est passé
    }
  }

  Future<String> _uploadImageToSupabase() async {
    if (_selectedImagePath == null) {
      return s21; // Retourner l'URL par défaut si aucune image n'est sélectionnée
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final fileName =
          'playlist/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Convertir le chemin de l'image en un fichier
      final file = File(_selectedImagePath!);

      // Téléverser l'image sur Supabase
      await Supabase.instance.client.storage
          .from('pfeapp')
          .upload(fileName, file);

      // Récupérer l'URL publique
      final publicUrl = Supabase.instance.client.storage
          .from('pfeapp')
          .getPublicUrl(fileName);

      if (publicUrl.isNotEmpty) {
        debugPrint('Image uploaded successfully: $publicUrl');
        return publicUrl; // Retourner l'URL publique
      } else {
        debugPrint('Failed to get public URL.');
        return s21; // Retourner l'URL par défaut si aucune URL publique
      }
    } catch (e) {
      debugPrint('Error uploading image to Supabase: $e');
      return s21; // Retourner l'URL par défaut en cas d'erreur
    }
  }

  Future<void> _saveplaylistData() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final playlist = _playlistController.text.trim();
    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields.')),
        );
        return;
      }

      // Obtenir l'URL de l'image (soit uploadée, soit l'URL par défaut)
      final photoUrl = await _uploadImageToSupabase();

      final playlistData = {
        'userId': currentUser.uid,
        'name': name,
        'description': description,
        'photoUrl': photoUrl, // URL de l'image (ou URL par défaut)
        'createdAt': FieldValue.serverTimestamp(),
        'podcast': playlist.isNotEmpty ? playlist : null,
      };

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('playlist')
          .add(playlistData);

      await docRef.update({'id': docRef.id});
    } catch (e) {
      debugPrint("Channel save error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            if (o == 2) ...[
              Positioned(
                top: c.height * 0.01,
                left: c.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.network(
                    s18,
                    width: c.width * 0.07,
                    height: c.width * 0.07,
                  ),
                ),
              ),
              Positioned(
                top: c.height * 0.1,
                left: c.width * 0.1,
                child: Text(
                  "Let's Create Your Playlist",
                  style: TextStyle(
                      fontSize: c.width * 0.065, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: c.height * 0.18,
                left: c.width * 0.1,
                child: const Text(
                  "Name Playlist",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: c.height * 0.21,
                left: c.width * 0.07,
                right: c.width * 0.07,
                child: SizedBox(
                  width: c.width - 60,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),

                      hintText: "Enter Name Playlist",
                      hintStyle: const TextStyle(color: Colors.grey),
                      // Utilisation d'une image depuis les assets comme prefixIcon
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(c.width *
                            0.028), // Ajustez le padding selon vos besoins
                        child: Image.network(
                          s30, // Remplacez par le chemin de votre icône
                          width: c.width *
                              0.05, // Ajustez la taille selon vos besoins
                          height: c.width * 0.05,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: c.height * 0.31,
                left: c.width * 0.1,
                child: const Text(
                  "Descreption",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: c.height * 0.34,
                left: c.width * 0.07,
                right: c.width * 0.07,
                child: SizedBox(
                  width: c.width - 60,
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),

                      hintText: "Enter Decreption",
                      hintStyle: const TextStyle(color: Colors.grey),
                      // Utilisation d'une image depuis les assets comme prefixIcon
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(c.width *
                            0.028), // Ajustez le padding selon vos besoins
                        child: Image.network(
                          s31, // Remplacez par le chemin de votre icône
                          width: c.width *
                              0.05, // Ajustez la taille selon vos besoins
                          height: c.width * 0.05,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: c.height * 0.44,
                left: c.width * 0.1,
                child: const Text(
                  "Add Podcast To A Playlist ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: c.height * 0.47,
                left: c.width * 0.07,
                right: c.width * 0.07,
                child: _buildDropDownField1(
                  controller: _playlistController,
                  hint: "Select Podcast",
                  items: play,
                  title: "Podcast",
                ),
              ),
              Positioned(
                top: c.height * 0.57,
                left: c.width * 0.1,
                child: Row(
                  children: [
                    Image.network(
                      s25,
                      width: c.width * 0.05,
                      height: c.width * 0.05,
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
                top: c.height * 0.6,
                left: c.width * 0.1,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap:
                          _pickImage, // Appelle la fonction pour ouvrir le gestionnaire de fichiers
                      child: Container(
                        width: c.width * 0.07,
                        height: c.width * 0.07,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(c.width * 0.05),
                        ),
                        child: Image.network(s26),
                      ),
                    ),
                    Container(
                        width:
                            c.width * 0.05), // Espace entre l'image et le texte
                    Container(
                      width: c.width * 0.7,
                      height: c.width *
                          0.13, // Largeur ajustable pour afficher le chemin

                      decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(c.width * 0.05)),
                      child: Text(
                        _selectedImagePath ?? "",
                        style: const TextStyle(
                            color: Colors.black,
                            backgroundColor: Color(0xFFD9D9D9)),
                        overflow: TextOverflow
                            .ellipsis, // Coupe le texte si trop long
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: c.height * 0.75,
                left: c.width * 0.15,
                child: Container(
                  height: c.height * 0.075,
                  width: c.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(c.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      try {
                        await _saveplaylistData(); // Make sure to await the method
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/podly', (route) => false);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to create playlist: $e')),
                        );
                      }
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.white, fontSize: c.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
            if (o == 3) ...[
              Positioned(
                top: c.height * 0.01,
                left: c.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.network(
                    s18,
                    width: c.width * 0.07,
                    height: c.width * 0.07,
                  ),
                ),
              ),
              Positioned(
                top: c.height * 0.1,
                left: c.width * 0.1,
                child: Text(
                  "Let's Create Your Playlist",
                  style: TextStyle(
                      fontSize: c.width * 0.065, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: c.height * 0.18,
                left: c.width * 0.1,
                child: const Text(
                  "Name Playlist",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: c.height * 0.21,
                left: c.width * 0.07,
                right: c.width * 0.07,
                child: SizedBox(
                  width: c.width - 60,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),

                      hintText: "Enter Name Playlist",
                      hintStyle: const TextStyle(color: Colors.grey),
                      // Utilisation d'une image depuis les assets comme prefixIcon
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(c.width *
                            0.028), // Ajustez le padding selon vos besoins
                        child: Image.network(
                          s30, // Remplacez par le chemin de votre icône
                          width: c.width *
                              0.05, // Ajustez la taille selon vos besoins
                          height: c.width * 0.05,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: c.height * 0.31,
                left: c.width * 0.1,
                child: const Text(
                  "Descreption",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: c.height * 0.34,
                left: c.width * 0.07,
                right: c.width * 0.07,
                child: SizedBox(
                  width: c.width - 60,
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),

                      hintText: "Enter Decreption",
                      hintStyle: const TextStyle(color: Colors.grey),
                      // Utilisation d'une image depuis les assets comme prefixIcon
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(c.width *
                            0.028), // Ajustez le padding selon vos besoins
                        child: Image.network(
                          s31, // Remplacez par le chemin de votre icône
                          width: c.width *
                              0.05, // Ajustez la taille selon vos besoins
                          height: c.width * 0.05,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(c.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: c.height * 0.44,
                left: c.width * 0.1,
                child: const Text(
                  "Add Podcast To A Playlist ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: c.height * 0.47,
                left: c.width * 0.07,
                right: c.width * 0.07,
                child: _buildDropDownField1(
                  controller: _playlistController,
                  hint: "Select Podcast",
                  items: play,
                  title: "Podcast",
                ),
              ),
              Positioned(
                top: c.height * 0.57,
                left: c.width * 0.1,
                child: Row(
                  children: [
                    Image.network(
                      s25,
                      width: c.width * 0.05,
                      height: c.width * 0.05,
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
                top: c.height * 0.6,
                left: c.width * 0.1,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap:
                          _pickImage, // Appelle la fonction pour ouvrir le gestionnaire de fichiers
                      child: Container(
                        width: c.width * 0.07,
                        height: c.width * 0.07,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(c.width * 0.05),
                        ),
                        child: Image.network(s26),
                      ),
                    ),
                    Container(
                        width:
                            c.width * 0.05), // Espace entre l'image et le texte
                    Container(
                      width: c.width * 0.7,
                      height: c.width *
                          0.13, // Largeur ajustable pour afficher le chemin

                      decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(c.width * 0.05)),
                      child: Text(
                        _selectedImagePath ?? "",
                        style: const TextStyle(
                            color: Colors.black,
                            backgroundColor: Color(0xFFD9D9D9)),
                        overflow: TextOverflow
                            .ellipsis, // Coupe le texte si trop long
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: c.height * 0.75,
                left: c.width * 0.15,
                child: Container(
                  height: c.height * 0.075,
                  width: c.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(c.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      try {
                        await _saveplaylistData(); // Make sure to await the method
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/podly', (route) => false);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to create playlist: $e')),
                        );
                      }
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.white, fontSize: c.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      )),
    );
  }

  Widget _buildDropDownField1({
    required TextEditingController controller,
    required String hint,
    required List<SelectedListItem<String>> items,
    required String title,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.028),
            child: Image.network(s30,
                width: MediaQuery.of(context).size.width * 0.05,
                height: MediaQuery.of(context).size.width * 0.05),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width * 0.05)),
            borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width * 0.05)),
            borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width * 0.05)),
            borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
          ),
        ),
        onTap: () {
          DropDownState(
            dropDown: DropDown(
              dropDownBackgroundColor: Colors.white,
              isDismissible: true,
              bottomSheetTitle: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              data: items,
              onSelected: (List<dynamic> selectedItems) {
                if (selectedItems.isNotEmpty) {
                  final selectedItem =
                      selectedItems.first as SelectedListItem<String>;
                  setState(() {
                    controller.text = selectedItem.data;
                  });
                }
              },
              enableMultipleSelection: false,
            ),
          ).showModal(context);
        },
      ),
    );
  }
}
