import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:pfeapp/constants.dart';

class Createplaylistpage extends StatefulWidget {
  const Createplaylistpage({super.key});

  @override
  State<Createplaylistpage> createState() => _CreateplaylistpageState();
}

class _CreateplaylistpageState extends State<Createplaylistpage> {
  List<SelectedListItem<PlaylistItem>> play = [];
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _playlistController = TextEditingController();
  String? nameError;
  String? descError;
  String? _selectedImagePath;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedPlaylistId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      _loadPlaylists();
      await Future.delayed(const Duration(seconds: 1));
      setState(() => isLoading = false);
    });
  }

  bool isLoading = true;
  Future<void> _loadPlaylists() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser
          ?.uid; // Remplacez par la logique pour obtenir l'utilisateur actuel.
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('idUser', isEqualTo: currentUser)
          .get();

      // Créer une liste d'éléments avec `name` et `id`.
      final List<SelectedListItem<PlaylistItem>> fetchedPlaylists =
          querySnapshot.docs.map((doc) {
        final data = doc.data();
        final name = data['name'] ?? 'Unknown Playlist'; // Nom de la playlist
        final id = doc.id; // ID unique du document
        return SelectedListItem<PlaylistItem>(
          data: PlaylistItem(id: id, name: name),
        );
      }).toList();

      setState(() {
        play.addAll(fetchedPlaylists);
      });
      // ignore: empty_catches
    } catch (e) {}
  }

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
      return s104; // Retourner l'URL par défaut si aucune image n'est sélectionnée
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
        return publicUrl; // Retourner l'URL publique
      } else {
        return s21; // Retourner l'URL par défaut si aucune URL publique
      }
    } catch (e) {
      return s21; // Retourner l'URL par défaut en cas d'erreur
    }
  }

  bool _validateFields() {
    bool isValid = true;

    // Reset all errors first
    setState(() {
      nameError = null;
      descError = null;
    });

    // Check each field
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        nameError = "Name must not be empty";
      });
      isValid = false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        descError = "Description must not be empty";
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> _saveplaylistData() async {
    if (!_validateFields()) {
      // If validation fails, just return - errors are already displayed
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
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      // Obtenir l'URL de l'image (soit uploadée, soit l'URL par défaut)
      final photoUrl = await _uploadImageToSupabase();

      final playlistData = {
        'userId': currentUser.uid,
        'name': name,
        'description': description,
        'photoUrl': photoUrl, // URL de l'image (ou URL par défaut)
        'createdAt': FieldValue.serverTimestamp(),
        'podcast': 0,
        'save': 0,
      };

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('playlist')
          .add(playlistData);

      await docRef.update({'id': docRef.id});

      // Ajouter un podcast à la playlist si un ID de podcast est sélectionné
      if (_selectedPlaylistId != null && _selectedPlaylistId!.isNotEmpty) {
        await FirebaseFirestore.instance.collection('playinpod').add({
          'playlistId': docRef.id,
          'podcastId':
              _selectedPlaylistId, // Utilisation directe de la variable
          'date': FieldValue.serverTimestamp(),
        });

        // Incrémenter le champ "podcast" de la playlist concernée
        await FirebaseFirestore.instance
            .collection('playlist')
            .doc(docRef.id)
            .update({
          'podcast': FieldValue.increment(1),
        });
      }
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/succes3');
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while saving data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
            child: isLoading
                ? const Annimationwidjet()
                : Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: c.height * 0.01,
                            left: c.width * 0.03,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s97 : s18,
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
                                  fontSize: c.width * 0.065,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            top: c.height * 0.18,
                            left: c.width * 0.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name Playlist",
                                  style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                nameError != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          nameError!,
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Positioned(
                            top: c.height * 0.21,
                            left: c.width * 0.07,
                            right: c.width * 0.07,
                            child: SizedBox(
                              width: c.width - 60,
                              child: TextFormField(
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "name must not be empty";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    nameError = null;
                                  });
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFD9D9D9),
                                  errorText: nameError,
                                  hintText: "Enter Name Playlist",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(c.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(c.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(c.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(c.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: c.height * 0.31,
                            left: c.width * 0.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Descreption",
                                  style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                descError != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          descError!,
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Positioned(
                            top: c.height * 0.34,
                            left: c.width * 0.07,
                            right: c.width * 0.07,
                            child: SizedBox(
                              width: c.width - 60,
                              child: TextFormField(
                                controller: _descriptionController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "description must not be empty";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    descError = null;
                                  });
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFD9D9D9),
                                  errorText: descError,
                                  hintText: "Enter Description",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(c.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(c.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(c.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(c.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: c.height * 0.44,
                            left: c.width * 0.1,
                            child: Text(
                              "Add Podcast To A Playlist (Optionnel) ",
                              style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold),
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
                                      borderRadius:
                                          BorderRadius.circular(c.width * 0.05),
                                    ),
                                    child: Image.network(s26),
                                  ),
                                ),
                                Container(
                                    width: c.width *
                                        0.05), // Espace entre l'image et le texte
                                Container(
                                  width: c.width * 0.7,
                                  height: c.width *
                                      0.13, // Largeur ajustable pour afficher le chemin

                                  decoration: BoxDecoration(
                                      color: const Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.circular(
                                          c.width * 0.05)),
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
                                borderRadius:
                                    BorderRadius.circular(c.width * 0.05),
                              ),
                              child: MaterialButton(
                                onPressed: () async {
                                  try {
                                    await _saveplaylistData(); // Make sure to await the method
                                  } catch (e) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to create playlist: $e')),
                                    );
                                  }
                                },
                                child: Text(
                                  "Done",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: c.width * 0.042),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })));
  }

  Widget _buildDropDownField1({
    required TextEditingController controller,
    required String hint,
    required List<SelectedListItem<PlaylistItem>> items,
    required String title,
  }) {
    final Size c = MediaQuery.of(context).size;
    return isLoading
        ? const Annimationwidjet()
        : Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
            return SizedBox(
              width: MediaQuery.of(context).size.width - 60,
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: Colors.black,
                ),
                cursorColor: Colors.black,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.028),
                    child: Image.network(s33,
                        width: MediaQuery.of(context).size.width * 0.05,
                        height: MediaQuery.of(context).size.width * 0.05),
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
                      color: Colors.lightBlue,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(c.width * 0.05)),
                    borderSide: const BorderSide(
                      color: Colors.red,
                    ),
                  ),
                ),
                onTap: () {
                  DropDownState(
                    dropDown: DropDown(
                      dropDownBackgroundColor: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white,
                      isDismissible: true,
                      bottomSheetTitle: Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      data: items,
                      onSelected: (List<dynamic> selectedItems) {
                        if (selectedItems.isNotEmpty) {
                          final selectedItem = selectedItems.first
                              as SelectedListItem<PlaylistItem>;
                          final playlistItem = selectedItem.data;

                          setState(() {
                            _selectedPlaylistId =
                                playlistItem.id; // Stocke l'ID
                            _playlistController.text =
                                playlistItem.name; // Affiche le nom
                          });
                        }
                      },
                      enableMultipleSelection: false,
                    ),
                  ).showModal(context);
                },
              ),
            );
          });
  }
}

class PlaylistItem {
  final String id;
  final String name;

  PlaylistItem({required this.id, required this.name});
  @override
  String toString() => name; // Retourne le nom de la playlist
}
