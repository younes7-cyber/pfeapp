import 'package:flutter/material.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class Createpodcastpage extends StatefulWidget {
  const Createpodcastpage({super.key});

  @override
  State<Createpodcastpage> createState() => _CreatepodcastpageState();
}

class _CreatepodcastpageState extends State<Createpodcastpage> {
  final TextEditingController _catController = TextEditingController();
  final TextEditingController _playController = TextEditingController();
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
  final List<SelectedListItem<String>> play = [
    SelectedListItem<String>(data: "Education"),
    SelectedListItem<String>(data: "Needs a freinds"),
    SelectedListItem<String>(data: "Nesdds a freinds"),
    SelectedListItem<String>(data: "Music"),
  ];
  String? _selectedAudioPath;
  String? _selectedImagePath; // Variable pour stocker le chemin de l'image
  Future<bool> requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      // Montrer un dialogue si les permissions sont refusées
      if (context.mounted) {}
      return false;
    }
  }

  void _pickImage() async {
    // Vérifier les permissions avant d'ouvrir le picker
    if (await requestPermissions()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImagePath = result.files.single.path;
        });
      }
    }
  }

  void _pickAudio() async {
    // Vérifier les permissions avant d'ouvrir le picker
    if (await requestPermissions()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

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

  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            if (y == 2) ...[
              SizedBox(
                  height: c.height * 0.06,
                  child: Stack(children: [
                    Positioned(
                      top: c.height * 0.01,
                      left: c.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          "images/retour.png",
                          width: c.width * 0.07,
                          height: c.width * 0.07,
                        ),
                      ),
                    ),
                  ])),
              SizedBox(
                height: c.height * 0.06,
                child: Text(
                  "Let's Upload Your Podcast",
                  style: TextStyle(
                      fontSize: c.width * 0.065, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: c.height * 0.75,
                child: Stack(
                  children: [
                    Positioned(
                      top: c.height * 0.01,
                      left: c.width * 0.1,
                      child: const Text(
                        "Name Podcast",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.05,
                      left: c.width * 0.07,
                      right: c.width * 0.07,
                      child: SizedBox(
                        width: c.width - 60,
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),

                            hintText: "Enter Name Podcast",
                            hintStyle: const TextStyle(color: Colors.grey),
                            // Utilisation d'une image depuis les assets comme prefixIcon
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(c.width *
                                  0.028), // Ajustez le padding selon vos besoins
                              child: Image.asset(
                                "images/podcast.png", // Remplacez par le chemin de votre icône
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
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.15,
                      left: c.width * 0.1,
                      child: const Text(
                        "Descreption",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.19,
                      left: c.width * 0.07,
                      right: c.width * 0.07,
                      child: SizedBox(
                        width: c.width - 60,
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),

                            hintText: "Enter Decreption",
                            hintStyle: const TextStyle(color: Colors.grey),
                            // Utilisation d'une image depuis les assets comme prefixIcon
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(c.width *
                                  0.028), // Ajustez le padding selon vos besoins
                              child: Image.asset(
                                "images/desc.png", // Remplacez par le chemin de votre icône
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
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.3,
                      left: c.width * 0.1,
                      child: const Text(
                        "Catigory Of Podcast",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.34,
                      left: c.width * 0.07,
                      right: c.width * 0.07,
                      child: Row(children: [
                        _buildDropDownField(
                          controller: _catController,
                          hint: "Select Category",
                          items: _listOfCat,
                          title: "Category",
                        ),
                      ]),
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
                      top: c.height * 0.48,
                      left: c.width * 0.07,
                      right: c.width * 0.07,
                      child: _buildDropDownField1(
                        controller: _playController,
                        hint: "Select Playlist",
                        items: play,
                        title: "Playlist",
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.59,
                      right: c.width * 0.2,
                      child: Row(
                        children: [
                          Image.asset(
                            "images/photo.png",
                            width: c.width * 0.05,
                            height: c.width * 0.05,
                          ),
                          const Text(
                            "   Photos",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.63,
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
                              child: Image.asset("images/add.png"),
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
                      top: c.height * 0.59,
                      left: c.width * 0.1,
                      child: Row(
                        children: [
                          Image.asset(
                            "images/podcast.png",
                            width: c.width * 0.05,
                            height: c.width * 0.05,
                          ),
                          const Text(
                            "   File Podcast",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.63,
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
                              child: Image.asset("images/add.png"),
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
                  ],
                ),
              ),
              SizedBox(
                child: Container(
                  height: c.height * 0.075,
                  width: c.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(c.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
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
              SizedBox(
                  height: c.height * 0.06,
                  child: Stack(children: [
                    Positioned(
                      top: c.height * 0.01,
                      left: c.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          "images/retour.png",
                          width: c.width * 0.07,
                          height: c.width * 0.07,
                        ),
                      ),
                    ),
                  ])),
              SizedBox(
                height: c.height * 0.06,
                child: Text(
                  "Let's Upload Your Podcast",
                  style: TextStyle(
                      fontSize: c.width * 0.065, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: c.height * 0.75,
                child: Stack(
                  children: [
                    Positioned(
                      top: c.height * 0.01,
                      left: c.width * 0.1,
                      child: const Text(
                        "Name Podcast",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.05,
                      left: c.width * 0.07,
                      right: c.width * 0.07,
                      child: SizedBox(
                        width: c.width - 60,
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),

                            hintText: "Enter Name Podcast",
                            hintStyle: const TextStyle(color: Colors.grey),
                            // Utilisation d'une image depuis les assets comme prefixIcon
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(c.width *
                                  0.028), // Ajustez le padding selon vos besoins
                              child: Image.asset(
                                "images/podcast.png", // Remplacez par le chemin de votre icône
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
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.15,
                      left: c.width * 0.1,
                      child: const Text(
                        "Descreption",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.19,
                      left: c.width * 0.07,
                      right: c.width * 0.07,
                      child: SizedBox(
                        width: c.width - 60,
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),

                            hintText: "Enter Decreption",
                            hintStyle: const TextStyle(color: Colors.grey),
                            // Utilisation d'une image depuis les assets comme prefixIcon
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(c.width *
                                  0.028), // Ajustez le padding selon vos besoins
                              child: Image.asset(
                                "images/desc.png", // Remplacez par le chemin de votre icône
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
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.3,
                      left: c.width * 0.1,
                      child: const Text(
                        "Catigory Of Podcast",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.34,
                      left: c.width * 0.07,
                      right: c.width * 0.07,
                      child: Row(children: [
                        _buildDropDownField(
                          controller: _catController,
                          hint: "Select Category",
                          items: _listOfCat,
                          title: "Category",
                        ),
                      ]),
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
                      top: c.height * 0.48,
                      left: c.width * 0.07,
                      right: c.width * 0.07,
                      child: _buildDropDownField1(
                        controller: _playController,
                        hint: "Select Playlist",
                        items: play,
                        title: "Playlist",
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.59,
                      right: c.width * 0.2,
                      child: Row(
                        children: [
                          Image.asset(
                            "images/photo.png",
                            width: c.width * 0.05,
                            height: c.width * 0.05,
                          ),
                          const Text(
                            "   Photos",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.63,
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
                              child: Image.asset("images/add.png"),
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
                      top: c.height * 0.59,
                      left: c.width * 0.1,
                      child: Row(
                        children: [
                          Image.asset(
                            "images/podcast.png",
                            width: c.width * 0.05,
                            height: c.width * 0.05,
                          ),
                          const Text(
                            "   File Podcast",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: c.height * 0.63,
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
                              child: Image.asset("images/add.png"),
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
                  ],
                ),
              ),
              SizedBox(
                child: Container(
                  height: c.height * 0.075,
                  width: c.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(c.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
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
          ],
        ),
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
            child: Image.asset("images/cate.png",
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
            child: Image.asset("images/playl.png",
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
