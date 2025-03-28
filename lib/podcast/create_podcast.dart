import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:pfeapp/constants.dart';

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
    SelectedListItem<String>(data: "tv/Films"),
    SelectedListItem<String>(data: "Music"),
    SelectedListItem<String>(data: "Books"),
    SelectedListItem<String>(data: "Culture"),
    SelectedListItem<String>(data: "Self"),
    SelectedListItem<String>(data: "Marketing"),
    SelectedListItem<String>(data: "Sport"),
    SelectedListItem<String>(data: "Gaming"),
    SelectedListItem<String>(data: "Food"),
    SelectedListItem<String>(data: "Travel"),
    SelectedListItem<String>(data: "Relegion"),
    SelectedListItem<String>(data: "Art"),
    SelectedListItem<String>(data: "Sciences"),
  ];
  List<SelectedListItem<PlaylistItem>> play = [];
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _playlistController = TextEditingController();
  String?
      _selectedPlaylistId; // Variable pour stocker l'ID de la playlist sélectionnée

  String? _selectedAudioPath;
  String? _selectedImagePath;
  @override
  void initState() {
    super.initState();
    _loadPlaylists();
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
    } catch (e) {
      print('Error loading playlists: $e');
    }
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

  Future<String> _uploadFileToSupabase(String path, String folder) async {
    if (path.isEmpty) {
      debugPrint("No file selected for upload.");
      return ''; // Retourne une chaîne vide si aucun fichier n'est fourni
    }

    try {
      // Générer un nom unique pour le fichier
      final userId = FirebaseAuth.instance.currentUser?.uid ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final fileName =
          '$folder/${userId}_${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      final file = File(path);

      // Téléverser le fichier sur Supabase
      await Supabase.instance.client.storage
          .from('pfeapp')
          .upload(fileName, file);

      // Récupérer l'URL publique
      final publicUrl = Supabase.instance.client.storage
          .from('pfeapp')
          .getPublicUrl(fileName);

      if (publicUrl.isNotEmpty) {
        debugPrint('File uploaded successfully: $publicUrl');
        return publicUrl; // Retourner l'URL publique si disponible
      } else {
        debugPrint('Failed to generate public URL for the file.');
        return ''; // Retourner une chaîne vide si l'URL publique ne peut être générée
      }
    } catch (e) {
      debugPrint('Error uploading file to Supabase: $e');
      return ''; // Retourner une chaîne vide en cas d'erreur
    }
  }

  Future<void> _createPodcast() async {
    // Récupération des valeurs saisies par l'utilisateur
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _categoryController.text.trim();

    // Validation des champs obligatoires
    if (name.isEmpty ||
        description.isEmpty ||
        category.isEmpty ||
        _selectedAudioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    try {
      // Récupérer l'utilisateur actuel
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid ?? '';

      // Téléverser la photo (ou utiliser l'URL par défaut)
      final photoUrl = _selectedImagePath != null
          ? await _uploadFileToSupabase(_selectedImagePath!, 'podcast/photo')
          : 'https://migwbqbtfzszopvhdzre.supabase.co/storage/v1/object/public/pfeapp/profile/ano.jpg';

      // Téléverser le fichier audio
      final audioUrl = await _uploadFileToSupabase(
        _selectedAudioPath!,
        'podcast/audio',
      );

      // Vérifier si le téléversement audio a échoué
      if (audioUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Audio upload failed. Please try again.')),
        );
        return;
      }

      // Préparer les données à enregistrer dans Firestore
      final podcastData = {
        'idUser': userId, // Enregistrement de l'ID utilisateur
        'name': name,
        'description': description,
        'category': category,
        'urlFile': audioUrl, // URL du fichier audio
        'urlPhoto': photoUrl, // URL de la photo
        'dateCreation': FieldValue.serverTimestamp(), // Timestamp de création
      };

      // Ajouter les données dans Firestore
      //  await _firestore.collection('podcast').add(podcastData);
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('podcasts')
          .add(podcastData);

      await docRef
          .update({'id': docRef.id}); // Ajoute l'ID au document lui-même
      if (_selectedPlaylistId != null && _selectedPlaylistId!.isNotEmpty) {
        await FirebaseFirestore.instance.collection('playinpod').add({
          'podcastId': docRef.id,
          'playlistId':
              _selectedPlaylistId, // Utilisation directe de la variable
        });
      }
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podcast created successfully!')),
      );

      // Retourner à l'écran précédent
      Navigator.pop(context);
    } catch (e) {
      // Gestion des erreurs
      debugPrint('Error creating podcast: $e');
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
          child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(children: [
          if (y == 2) ...[
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
              top: c.height * 0.07,
              left: c.width * 0.1,
              child: Text(
                "Let's Upload Your Podcast",
                style: TextStyle(
                    fontSize: c.width * 0.065, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              top: c.height * 0.15,
              left: c.width * 0.1,
              child: const Text(
                "Name Podcast",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              top: c.height * 0.18,
              left: c.width * 0.07,
              right: c.width * 0.07,
              child: SizedBox(
                width: c.width - 60,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),

                    hintText: "Enter Name Podcast",
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
              top: c.height * 0.28,
              left: c.width * 0.1,
              child: const Text(
                "Descreption",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              top: c.height * 0.31,
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
              top: c.height * 0.41,
              left: c.width * 0.1,
              child: const Text(
                "Catigory Of Podcast",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                ),
              ]),
            ),
            Positioned(
              top: c.height * 0.54,
              left: c.width * 0.1,
              child: const Text(
                "Add Podcast To A Playlist ",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
              right: c.width * 0.2,
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
                        borderRadius: BorderRadius.circular(c.width * 0.05),
                      ),
                      child: Image.network(s26),
                    ),
                  ),
                  Container(
                      width:
                          c.width * 0.01), // Espace entre l'image et le texte
                  Container(
                    width: c.width * 0.35,
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
                      overflow:
                          TextOverflow.ellipsis, // Coupe le texte si trop long
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
                  const Text(
                    "   File Podcast",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
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
                        borderRadius: BorderRadius.circular(c.width * 0.05),
                      ),
                      child: Image.network(s26),
                    ),
                  ),
                  Container(
                      width:
                          c.width * 0.01), // Espace entre l'image et le texte
                  Container(
                    width: c.width * 0.35,
                    height: c.width *
                        0.13, // Largeur ajustable pour afficher le chemin

                    decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(c.width * 0.05)),
                    child: Text(
                      _selectedAudioPath ?? "",
                      style: const TextStyle(
                          color: Colors.black,
                          backgroundColor: Color(0xFFD9D9D9)),
                      overflow:
                          TextOverflow.ellipsis, // Coupe le texte si trop long
                    ),
                  ),
                ],
              ),
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
                  onPressed: () async {
                    await _createPodcast(); // Assurez-vous que la fonction est exécutée
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/podly', (route) => false);
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
          if (y == 3) ...[
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
              top: c.height * 0.07,
              left: c.width * 0.1,
              child: Text(
                "Let's Upload Your Podcast",
                style: TextStyle(
                    fontSize: c.width * 0.065, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              top: c.height * 0.15,
              left: c.width * 0.1,
              child: const Text(
                "Name Podcast",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              top: c.height * 0.18,
              left: c.width * 0.07,
              right: c.width * 0.07,
              child: SizedBox(
                width: c.width - 60,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),

                    hintText: "Enter Name Podcast",
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
              top: c.height * 0.28,
              left: c.width * 0.1,
              child: const Text(
                "Descreption",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              top: c.height * 0.31,
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
              top: c.height * 0.41,
              left: c.width * 0.1,
              child: const Text(
                "Catigory Of Podcast",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                ),
              ]),
            ),
            Positioned(
              top: c.height * 0.54,
              left: c.width * 0.1,
              child: const Text(
                "Add Podcast To A Playlist ",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
              right: c.width * 0.2,
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
                        borderRadius: BorderRadius.circular(c.width * 0.05),
                      ),
                      child: Image.network(s26),
                    ),
                  ),
                  Container(
                      width:
                          c.width * 0.01), // Espace entre l'image et le texte
                  Container(
                    width: c.width * 0.35,
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
                      overflow:
                          TextOverflow.ellipsis, // Coupe le texte si trop long
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
                  const Text(
                    "   File Podcast",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
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
                        borderRadius: BorderRadius.circular(c.width * 0.05),
                      ),
                      child: Image.network(s26),
                    ),
                  ),
                  Container(
                      width:
                          c.width * 0.01), // Espace entre l'image et le texte
                  Container(
                    width: c.width * 0.35,
                    height: c.width *
                        0.13, // Largeur ajustable pour afficher le chemin

                    decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(c.width * 0.05)),
                    child: Text(
                      _selectedAudioPath ?? "",
                      style: const TextStyle(
                          color: Colors.black,
                          backgroundColor: Color(0xFFD9D9D9)),
                      overflow:
                          TextOverflow.ellipsis, // Coupe le texte si trop long
                    ),
                  ),
                ],
              ),
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
                  onPressed: () async {
                    await _createPodcast(); // Assurez-vous que la fonction est exécutée
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/podly', (route) => false);
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
        ]),
      )),
    );
  }

  Widget _buildDropDownField({
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
            child: Image.network(s32,
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

  Widget _buildDropDownField1({
    required TextEditingController controller,
    required String hint,
    required List<SelectedListItem<PlaylistItem>> items,
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
            child: Image.network(s33,
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
                      selectedItems.first as SelectedListItem<PlaylistItem>;
                  final playlistItem = selectedItem.data;

                  setState(() {
                    _selectedPlaylistId =
                        playlistItem.id; // Stocke l'ID sélectionné
                    _playlistController.text =
                        playlistItem.name; // Affiche uniquement le nom
                  });

                  print('Selected Playlist ID: ${playlistItem.id}');
                  print('Selected Playlist Name: ${playlistItem.name}');
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

class PlaylistItem {
  final String id;
  final String name;

  PlaylistItem({required this.id, required this.name});
}
