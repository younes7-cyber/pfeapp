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
import 'package:nyx_converter/nyx_converter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class Createpodcastpage extends StatefulWidget {
  const Createpodcastpage({super.key});

  @override
  State<Createpodcastpage> createState() => _CreatepodcastpageState();
}

class _CreatepodcastpageState extends State<Createpodcastpage> {
  final List<SelectedListItem<String>> _listOfCat = [
    SelectedListItem<String>(data: "Education"),
    SelectedListItem<String>(data: "History"),
    SelectedListItem<String>(data: "Comedie"),
    SelectedListItem<String>(data: "Tv&Films"),
    SelectedListItem<String>(data: "Music"),
    SelectedListItem<String>(data: "Books"),
    SelectedListItem<String>(data: "Culture"),
    SelectedListItem<String>(data: "Self"),
    SelectedListItem<String>(data: "Marketing"),
    SelectedListItem<String>(data: "Sport"),
    SelectedListItem<String>(data: "Gaming"),
    SelectedListItem<String>(data: "Food"),
    SelectedListItem<String>(data: "Travel"),
    SelectedListItem<String>(data: "Religion"),
    SelectedListItem<String>(data: "Art"),
    SelectedListItem<String>(data: "Sciences"),
  ];
  List<SelectedListItem<PlaylistItem>> play = [];
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _playlistController = TextEditingController();
  String? nameError;
  String? descError;
  String? categoryError;
  String? fileError;
  String?
      _selectedPlaylistId; // Variable pour stocker l'ID de la playlist sélectionnée

  String? _selectedAudioPath;
  String? _selectedImagePath;
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
// Fonction pour obtenir la durée d’un fichier audio
  Future<Duration> _getAudioDuration(String filePath) async {
    try {
      final player = AudioPlayer();
      await player.setFilePath(filePath);
      Duration? duration = player.duration;
      await player.dispose();
      return duration ?? Duration.zero;
    } catch (e) {
      return Duration.zero;
    }
  }

  Future<void> _loadPlaylists() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser
          ?.uid; // Remplacez par la logique pour obtenir l'utilisateur actuel.
      final querySnapshot = await FirebaseFirestore.instance
          .collection('playlist')
          .where('userId', isEqualTo: currentUser)
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
    _categoryController.dispose();
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

  Future<void> _pickAudio() async {
    if (await _requestPermission()) {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedAudioPath = result.files.single.path;
        });
      }
    }
  }

  late int y;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is int) {
      y = args;
    } else {
      y = 0; // Valeur par défaut si aucun argument n'est passé
    }
  }

  Future<String> _uploadFileToSupabase(String path, String folder,
      {bool isAudio = false}) async {
    if (path.isEmpty) {
      return '';
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ??
          DateTime.now().millisecondsSinceEpoch.toString();

      String filePath = path;
      String fileName = path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      // For audio files, check and convert to MP3 if needed
      if (isAudio) {
        if (fileExtension != 'mp3') {
          try {
            // Create a sanitized filename without special characters
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final sanitizedFileName = 'audio_$timestamp.mp3';

            // Get temp directory for storing the converted file
            final tempDir = await getTemporaryDirectory();

            // Make sure temp directory exists
            if (!await Directory(tempDir.path).exists()) {
              await Directory(tempDir.path).create(recursive: true);
            }

            final outputPath = '${tempDir.path}/$sanitizedFileName';

            // Convert the audio to MP3 using NyxConverter
            final converter = NyxConverter;
            final conversionResult = await converter.convertTo(
              filePath,
              outputPath,
              container: NyxContainer.mp3,
            );

            if (conversionResult) {
              filePath = outputPath;
              fileName = sanitizedFileName;
              fileExtension = 'mp3';
            } else {}
          } catch (e) {
            // Continue with original file if conversion fails but sanitize the filename
          }
        }

        // Create a sanitized filename with no special characters for Supabase
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final sanitizedFileName = 'audio_${userId}_$timestamp.$fileExtension'
            .replaceAll(RegExp(r'[^a-zA-Z0-9._]'), '_');
        final finalFileName = '$folder/$sanitizedFileName';

        final file = File(filePath);

        if (await file.exists()) {
          // Read file as bytes
          final fileBytes = await file.readAsBytes();

          // Upload to Supabase
          await Supabase.instance.client.storage
              .from('pfeapp')
              .uploadBinary(finalFileName, fileBytes);

          // Get public URL
          final publicUrl = Supabase.instance.client.storage
              .from('pfeapp')
              .getPublicUrl(finalFileName);

          if (publicUrl.isNotEmpty) {
            return publicUrl;
          } else {
            return '';
          }
        } else {
          return '';
        }
      } else {
        // For images or other files - also sanitize filenames
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final sanitizedFileName = 'image_${userId}_$timestamp.$fileExtension'
            .replaceAll(RegExp(r'[^a-zA-Z0-9._]'), '_');
        final finalFileName = '$folder/$sanitizedFileName';

        final file = File(filePath);

        if (await file.exists()) {
          await Supabase.instance.client.storage
              .from('pfeapp')
              .upload(finalFileName, file);

          final publicUrl = Supabase.instance.client.storage
              .from('pfeapp')
              .getPublicUrl(finalFileName);

          if (publicUrl.isNotEmpty) {
            return publicUrl;
          } else {
            return '';
          }
        } else {
          return '';
        }
      }
    } catch (e) {
      return '';
    }
  }

  bool _validateFields() {
    bool isValid = true;

    // Reset all errors first
    setState(() {
      nameError = null;
      descError = null;
      categoryError = null;
      fileError = null;
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

    if (_categoryController.text.trim().isEmpty) {
      setState(() {
        categoryError = "Category must not be empty";
      });
      isValid = false;
    }

    if (_selectedAudioPath == null) {
      setState(() {
        fileError = "Audio file must not be empty";
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> _createPodcast() async {
    // Validation des champs obligatoires
    if (!_validateFields()) {
      // If validation fails, just return - errors are already displayed
      return;
    }

    try {
      // Récupérer l'utilisateur actuel
      final currentUser = FirebaseAuth.instance.currentUser?.uid;
      //final userId = currentUser?.uid ??
      // Show loading indicator
      setState(() {
        isLoading = true;
      });

      // Téléverser la photo (ou utiliser l'URL par défaut)
      final photoUrl = _selectedImagePath != null
          ? await _uploadFileToSupabase(_selectedImagePath!, 'podcast/photo')
          : 'https://migwbqbtfzszopvhdzre.supabase.co/storage/v1/object/public/pfeapp/podcast/photo/11583113_4788501.jpg';

      // Téléverser le fichier audio (converti en MP3 si nécessaire)
      final audioUrl = await _uploadFileToSupabase(
        _selectedAudioPath!,
        'podcast/audio',
        isAudio: true,
      );

      // Vérifier si le téléversement audio a échoué
      if (audioUrl.isEmpty) {
        setState(() {
          isLoading = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Audio upload failed. Please try again.')),
        );
        return;
      }

      // 🔥 Obtenir la durée de l'audio
      final duration = await _getAudioDuration(_selectedAudioPath!);
      final formattedDuration =
          "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";

      // Récupération des valeurs saisies par l'utilisateur
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final category = _categoryController.text.trim();

      // Préparer les données à enregistrer dans Firestore
      final podcastData = {
        'idUser': currentUser,
        'name': name,
        'description': description,
        'category': category,
        'urlFile': audioUrl,
        'urlPhoto': photoUrl,
        'dateCreation': FieldValue.serverTimestamp(),
        'vue': 0,
        'likes': 0,
        'unlikes': 0,
        'comments': 0,
        'save': 0,
        'report': 0,
        'duration': formattedDuration,
      };

      // Ajouter les données dans Firestore
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('podcasts')
          .add(podcastData);

      await docRef
          .update({'id': docRef.id}); // Ajoute l'ID au document lui-même

      // Add to playlist if selected
      if (_selectedPlaylistId != null && _selectedPlaylistId!.isNotEmpty) {
        await FirebaseFirestore.instance.collection('playinpod').add({
          'podcastId': docRef.id,
          'playlistId': _selectedPlaylistId,
          'date': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('playlist')
            .doc(_selectedPlaylistId)
            .update({
          'podcast': FieldValue.increment(1),
        });
      }

      // Hide loading indicator
      setState(() {
        isLoading = false;
      });

      // Navigate to success page
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/succes2');
    } catch (e) {
      // Hide loading indicator
      setState(() {
        isLoading = false;
      });

      // Gestion des erreurs

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error creating podcast. Please try again.')),
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
                    child: Stack(children: [
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
                        top: c.height * 0.07,
                        left: c.width * 0.1,
                        child: Text(
                          "Let's Upload Your Podcast",
                          style: TextStyle(
                              fontSize: c.width * 0.065,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        top: c.height * 0.15,
                        left: c.width * 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name Podcast",
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
                        top: c.height * 0.18,
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
                              hintText: "Enter Name Podcast",
                              hintStyle: const TextStyle(color: Colors.grey),
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
                                borderSide:
                                    const BorderSide(color: Color(0xFFD9D9D9)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(c.width * 0.05)),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD9D9D9)),
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
                        top: c.height * 0.28,
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
                        top: c.height * 0.31,
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
                              hintStyle: const TextStyle(color: Colors.grey),
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
                                borderSide:
                                    const BorderSide(color: Color(0xFFD9D9D9)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(c.width * 0.05)),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD9D9D9)),
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
                        top: c.height * 0.41,
                        left: c.width * 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Category Of Podcast",
                              style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            categoryError != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      categoryError!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      Positioned(
                        top: c.height * 0.44,
                        left: c.width * 0.07,
                        right: c.width * 0.07,
                        child: Row(children: [
                          _buildDropDownField(
                            controller: _categoryController,
                            hint: "Select Category",
                            items: _listOfCat,
                            title: "Category",
                            errorText: categoryError,
                          ),
                        ]),
                      ),
                      Positioned(
                        top: c.height * 0.54,
                        left: c.width * 0.1,
                        child: Text(
                          "Add Podcast To A Playlist (Optionnel)",
                          style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        top: c.height * 0.57,
                        left: c.width * 0.07,
                        right: c.width * 0.07,
                        child: _buildDropDownField1(
                          controller: _playlistController,
                          hint: "Select Playlist",
                          items: play,
                          title: "Playlist",
                        ),
                      ),
                      Positioned(
                        top: c.height * 0.67,
                        right: c.width * 0.05,
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
                        top: c.height * 0.7,
                        right: c.width * 0.02,
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
                                    0.01), // Espace entre l'image et le texte
                            Container(
                              width: c.width * 0.35,
                              height: c.width *
                                  0.13, // Largeur ajustable pour afficher le chemin

                              decoration: BoxDecoration(
                                  color: const Color(0xFFD9D9D9),
                                  borderRadius:
                                      BorderRadius.circular(c.width * 0.05)),
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
                        top: c.height * 0.67,
                        left: c.width * 0.1,
                        child: Row(
                          children: [
                            Image.network(
                              s30,
                              width: c.width * 0.05,
                              height: c.width * 0.05,
                            ),
                            Text(
                              "   File Podcast",
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
                        top: c.height * 0.7,
                        left: c.width * 0.1,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap:
                                  _pickAudio, // Appelle la fonction pour ouvrir le gestionnaire de fichiers
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
                                    0.01), // Espace entre l'image et le texte
                            Container(
                              width: c.width * 0.35,
                              height: c.width *
                                  0.13, // Largeur ajustable pour afficher le chemin

                              decoration: BoxDecoration(
                                  color: const Color(0xFFD9D9D9),
                                  borderRadius:
                                      BorderRadius.circular(c.width * 0.05)),
                              child: Text(
                                _selectedAudioPath ?? "",
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
                        top: c.height * 0.76,
                        left: c.width * 0.1,
                        child: fileError != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  fileError!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              )
                            : const SizedBox(),
                      ),
                      Positioned(
                        top: c.height * 0.82,
                        left: c.width * 0.15,
                        child: Container(
                          height: c.height * 0.075,
                          width: c.width * 0.65,
                          decoration: BoxDecoration(
                            color: const Color(0xFF754CEF),
                            borderRadius: BorderRadius.circular(c.width * 0.05),
                          ),
                          child: MaterialButton(
                            onPressed: _createPodcast,
                            child: Text(
                              "Done",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: c.width * 0.042),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  );
                })),
    );
  }

  Widget _buildDropDownField({
    required TextEditingController controller,
    required String hint,
    required List<SelectedListItem<String>> items,
    required String title,
    String? errorText,
  }) {
    final Size c = MediaQuery.of(context).size;
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return SizedBox(
        width: MediaQuery.of(context).size.width - 60,
        child: TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "category must not be empty";
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              categoryError = null;
            });
          },
          style: const TextStyle(
            color: Colors.black,
          ),
          cursorColor: Colors.black,
          readOnly: true,
          decoration: InputDecoration(
            errorText: categoryError,
            filled: true,
            fillColor: const Color(0xFFD9D9D9),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Padding(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.width * 0.028),
              child: Image.network(s32,
                  width: MediaQuery.of(context).size.width * 0.05,
                  height: MediaQuery.of(context).size.width * 0.05),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(c.width * 0.05)),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(c.width * 0.05)),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(c.width * 0.05)),
              borderSide: const BorderSide(
                color: Colors.lightBlue,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(c.width * 0.05)),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
          ),
          onTap: () {
            DropDownState(
              dropDown: DropDown(
                dropDownBackgroundColor:
                    themeProvider.isDarkMode ? Colors.black : Colors.white,
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
    });
  }

  Widget _buildDropDownField1({
    required TextEditingController controller,
    required String hint,
    required List<SelectedListItem<PlaylistItem>> items,
    required String title,
  }) {
    final Size c = MediaQuery.of(context).size;
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
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
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.width * 0.028),
              child: Image.network(s33,
                  width: MediaQuery.of(context).size.width * 0.05,
                  height: MediaQuery.of(context).size.width * 0.05),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(c.width * 0.05)),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(c.width * 0.05)),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(c.width * 0.05)),
              borderSide: const BorderSide(
                color: Colors.lightBlue,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(c.width * 0.05)),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
          ),
          onTap: () {
            DropDownState(
              dropDown: DropDown(
                dropDownBackgroundColor:
                    themeProvider.isDarkMode ? Colors.black : Colors.white,
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
                        selectedItems.first as SelectedListItem<PlaylistItem>;
                    final playlistItem = selectedItem.data;

                    setState(() {
                      _selectedPlaylistId = playlistItem.id; // Stocke l'ID
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
