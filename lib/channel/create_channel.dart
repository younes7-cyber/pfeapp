import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class CreateChannelpage extends StatefulWidget {
  const CreateChannelpage({super.key});

  @override
  State<CreateChannelpage> createState() => _CreateChannelpageState();
}

class _CreateChannelpageState extends State<CreateChannelpage> {
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
            SizedBox(
                height: c.height * 0.15,
                child: Stack(children: [
                  Positioned(
                    top: c.height * 0.01,
                    left: c.width * 0.03,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/podly', (route) => false,
                            arguments: {'selectedIndex': 2});
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
              height: c.height * 0.1,
              child: Text(
                "Let's Create Your Channel",
                style: TextStyle(
                    fontSize: c.width * 0.065, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: c.height * 0.45,
              child: Stack(
                children: [
                  Positioned(
                    top: c.height * 0.07,
                    left: c.width * 0.1,
                    child: const Text(
                      "Name Channel",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    top: c.height * 0.12,
                    left: c.width * 0.07,
                    right: c.width * 0.07,
                    child: SizedBox(
                      width: c.width - 60,
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFD9D9D9),

                          hintText: "Enter Name Channel",
                          hintStyle: const TextStyle(color: Colors.grey),
                          // Utilisation d'une image depuis les assets comme prefixIcon
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(c.width *
                                0.028), // Ajustez le padding selon vos besoins
                            child: Image.asset(
                              "images/cha.png", // Remplacez par le chemin de votre icône
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
                    top: c.height * 0.25,
                    left: c.width * 0.1,
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
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: c.height * 0.3,
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
                            child: Image.asset("images/add.png"),
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
        ),
      )),
    );
  }
}
