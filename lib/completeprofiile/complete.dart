import 'package:flutter/material.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class Completepage extends StatefulWidget {
  const Completepage({super.key});

  @override
  State<Completepage> createState() => _CompletepageState();
}

class _CompletepageState extends State<Completepage> {
  final TextEditingController _countryController = TextEditingController();

  final List<SelectedListItem<String>> _listOfCountries = [
    SelectedListItem<String>(data: "Afghanistan"),
    SelectedListItem<String>(data: "Albania"),
    SelectedListItem<String>(data: "Algeria"),
    SelectedListItem<String>(data: "Andorra"),
    SelectedListItem<String>(data: "Angola"),
    SelectedListItem<String>(data: "Antigua and Barbuda"),
    SelectedListItem<String>(data: "Argentina"),
    SelectedListItem<String>(data: "Armenia"),
    SelectedListItem<String>(data: "Australia"),
    SelectedListItem<String>(data: "Austria"),
    SelectedListItem<String>(data: "Azerbaijan"),
    SelectedListItem<String>(data: "Bahamas"),
    SelectedListItem<String>(data: "Bahrain"),
    SelectedListItem<String>(data: "Bangladesh"),
    SelectedListItem<String>(data: "Barbados"),
    SelectedListItem<String>(data: "Belarus"),
    SelectedListItem<String>(data: "Belgium"),
    SelectedListItem<String>(data: "Belize"),
    SelectedListItem<String>(data: "Benin"),
    SelectedListItem<String>(data: "Bhutan"),
    SelectedListItem<String>(data: "Bolivia"),
    SelectedListItem<String>(data: "Bosnia and Herzegovina"),
    SelectedListItem<String>(data: "Botswana"),
    SelectedListItem<String>(data: "Brazil"),
    SelectedListItem<String>(data: "Brunei"),
    SelectedListItem<String>(data: "Bulgaria"),
    SelectedListItem<String>(data: "Burkina Faso"),
    SelectedListItem<String>(data: "Burundi"),
    SelectedListItem<String>(data: "Cabo Verde"),
    SelectedListItem<String>(data: "Cambodia"),
    SelectedListItem<String>(data: "Cameroon"),
    SelectedListItem<String>(data: "Canada"),
    SelectedListItem<String>(data: "Central African Republic"),
    SelectedListItem<String>(data: "Chad"),
    SelectedListItem<String>(data: "Chile"),
    SelectedListItem<String>(data: "China"),
    SelectedListItem<String>(data: "Colombia"),
    SelectedListItem<String>(data: "Comoros"),
    SelectedListItem<String>(data: "Congo (Congo-Brazzaville)"),
    SelectedListItem<String>(data: "Congo (Congo-Kinshasa)"),
    SelectedListItem<String>(data: "Costa Rica"),
    SelectedListItem<String>(data: "Croatia"),
    SelectedListItem<String>(data: "Cuba"),
    SelectedListItem<String>(data: "Cyprus"),
    SelectedListItem<String>(data: "Czech Republic"),
    SelectedListItem<String>(data: "Denmark"),
    SelectedListItem<String>(data: "Djibouti"),
    SelectedListItem<String>(data: "Dominica"),
    SelectedListItem<String>(data: "Dominican Republic"),
    SelectedListItem<String>(data: "Ecuador"),
    SelectedListItem<String>(data: "Egypt"),
    SelectedListItem<String>(data: "El Salvador"),
    SelectedListItem<String>(data: "Equatorial Guinea"),
    SelectedListItem<String>(data: "Eritrea"),
    SelectedListItem<String>(data: "Estonia"),
    SelectedListItem<String>(data: "Eswatini"),
    SelectedListItem<String>(data: "Ethiopia"),
    SelectedListItem<String>(data: "Fiji"),
    SelectedListItem<String>(data: "Finland"),
    SelectedListItem<String>(data: "France"),
    SelectedListItem<String>(data: "Gabon"),
    SelectedListItem<String>(data: "Gambia"),
    SelectedListItem<String>(data: "Georgia"),
    SelectedListItem<String>(data: "Germany"),
    SelectedListItem<String>(data: "Ghana"),
    SelectedListItem<String>(data: "Greece"),
    SelectedListItem<String>(data: "Grenada"),
    SelectedListItem<String>(data: "Guatemala"),
    SelectedListItem<String>(data: "Guinea"),
    SelectedListItem<String>(data: "Guinea-Bissau"),
    SelectedListItem<String>(data: "Guyana"),
    SelectedListItem<String>(data: "Haiti"),
    SelectedListItem<String>(data: "Honduras"),
    SelectedListItem<String>(data: "Hungary"),
    SelectedListItem<String>(data: "Iceland"),
    SelectedListItem<String>(data: "India"),
    SelectedListItem<String>(data: "Indonesia"),
    SelectedListItem<String>(data: "Iran"),
    SelectedListItem<String>(data: "Iraq"),
    SelectedListItem<String>(data: "Ireland"),
    SelectedListItem<String>(data: "Italy"),
    SelectedListItem<String>(data: "Jamaica"),
    SelectedListItem<String>(data: "Japan"),
    SelectedListItem<String>(data: "Jordan"),
    SelectedListItem<String>(data: "Kazakhstan"),
    SelectedListItem<String>(data: "Kenya"),
    SelectedListItem<String>(data: "Kiribati"),
    SelectedListItem<String>(data: "Kuwait"),
    SelectedListItem<String>(data: "Kyrgyzstan"),
    SelectedListItem<String>(data: "Laos"),
    SelectedListItem<String>(data: "Latvia"),
    SelectedListItem<String>(data: "Lebanon"),
    SelectedListItem<String>(data: "Lesotho"),
    SelectedListItem<String>(data: "Liberia"),
    SelectedListItem<String>(data: "Libya"),
    SelectedListItem<String>(data: "Liechtenstein"),
    SelectedListItem<String>(data: "Lithuania"),
    SelectedListItem<String>(data: "Luxembourg"),
    SelectedListItem<String>(data: "Madagascar"),
    SelectedListItem<String>(data: "Malawi"),
    SelectedListItem<String>(data: "Malaysia"),
    SelectedListItem<String>(data: "Maldives"),
    SelectedListItem<String>(data: "Mali"),
    SelectedListItem<String>(data: "Malta"),
    SelectedListItem<String>(data: "Mexico"),
    SelectedListItem<String>(data: "Moldova"),
    SelectedListItem<String>(data: "Monaco"),
    SelectedListItem<String>(data: "Mongolia"),
    SelectedListItem<String>(data: "Montenegro"),
    SelectedListItem<String>(data: "Morocco"),
    SelectedListItem<String>(data: "Mozambique"),
    SelectedListItem<String>(data: "Myanmar"),
    SelectedListItem<String>(data: "Namibia"),
    SelectedListItem<String>(data: "Nepal"),
    SelectedListItem<String>(data: "Netherlands"),
    SelectedListItem<String>(data: "New Zealand"),
    SelectedListItem<String>(data: "Nicaragua"),
    SelectedListItem<String>(data: "Niger"),
    SelectedListItem<String>(data: "Nigeria"),
    SelectedListItem<String>(data: "North Korea"),
    SelectedListItem<String>(data: "Norway"),
    SelectedListItem<String>(data: "Oman"),
    SelectedListItem<String>(data: "Pakistan"),
    SelectedListItem<String>(data: "Palestine"),
    SelectedListItem<String>(data: "Panama"),
    SelectedListItem<String>(data: "Papua New Guinea"),
    SelectedListItem<String>(data: "Paraguay"),
    SelectedListItem<String>(data: "Peru"),
    SelectedListItem<String>(data: "Philippines"),
    SelectedListItem<String>(data: "Poland"),
    SelectedListItem<String>(data: "Portugal"),
    SelectedListItem<String>(data: "Qatar"),
    SelectedListItem<String>(data: "Romania"),
    SelectedListItem<String>(data: "Russia"),
    SelectedListItem<String>(data: "Saudi Arabia"),
    SelectedListItem<String>(data: "South Africa"),
    SelectedListItem<String>(data: "Spain"),
    SelectedListItem<String>(data: "Sweden"),
    SelectedListItem<String>(data: "Switzerland"),
    SelectedListItem<String>(data: "United Kingdom"),
    SelectedListItem<String>(data: "United States"),
    SelectedListItem<String>(data: "Venezuela"),
    SelectedListItem<String>(data: "Vietnam"),
    SelectedListItem<String>(data: "Yemen"),
    SelectedListItem<String>(data: "Zambia"),
    SelectedListItem<String>(data: "Zimbabwe"),
  ];
  String? _selectedImagePath; // Variable pour stocker le chemin de l'image
  Future<bool> requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      // Montrer un dialogue si les permissions sont refusées
      if (context.mounted) {
        /*
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Permission nécessaire'),
              content: Text('L\'accès au stockage est nécessaire pour sélectionner des images.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
    */
      }
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
    final Size s = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                Positioned(
                  top: s.height * 0.03,
                  left: s.width * 0.07,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/SignUp', (route) => false);
                    },
                    icon: Image.asset(
                      "images/retour.png",
                      width: s.width * 0.09,
                      height: s.width * 0.09,
                    ),
                  ),
                ),
                Positioned(
                    top: s.height * 0.1,
                    left: s.width * 0.1,
                    child: Column(
                      children: [
                        Text(
                          "COMPLETE",
                          style: TextStyle(
                              fontSize: s.width * 0.09,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "YOUR",
                          style: TextStyle(
                              fontSize: s.width * 0.09,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "PROFILE",
                          style: TextStyle(
                              fontSize: s.width * 0.09,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )),
                Positioned(
                  top: s.height * 0.3,
                  left: s.width * 0.1,
                  child: const Text(
                    "First Name",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  top: s.height * 0.325,
                  left: s.width * 0.07,
                  right: s.width * 0.07,
                  child: SizedBox(
                    width: s.width - 60,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),

                        hintText: "Enter First Name",
                        hintStyle: const TextStyle(color: Colors.grey),
                        // Utilisation d'une image depuis les assets comme prefixIcon
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(s.width *
                              0.028), // Ajustez le padding selon vos besoins
                          child: Image.asset(
                            "images/person.png", // Remplacez par le chemin de votre icône
                            width: s.width *
                                0.05, // Ajustez la taille selon vos besoins
                            height: s.width * 0.05,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(s.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(s.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(s.width * 0.05)),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: s.height * 0.42,
                    left: s.width * 0.1,
                    child: const Text(
                      "Last Name",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )),
                Positioned(
                  top: s.height * 0.445,
                  left: s.width * 0.07,
                  right: s.width * 0.07,
                  child: SizedBox(
                    width: s.width - 60,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        hintText: "Enter Last Name",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(s.width * 0.028),
                          child: Image.asset(
                            "images/person.png",
                            width: s.width * 0.05,
                            height: s.width * 0.05,
                          ),
                        ),
                        // Correction de la syntaxe du suffixIcon

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(s.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(s.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(s.width * 0.05)),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: s.height * 0.53,
                    left: s.width * 0.1,
                    child: const Text(
                      "Age",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )),
                Positioned(
                  top: s.height * 0.555,
                  left: s.width * 0.07,
                  right: s.width * 0.07,
                  child: SizedBox(
                    width: s.width - 60,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        hintText: "Enter Age",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(s.width * 0.028),
                          child: Image.asset(
                            "images/age.png",
                            width: s.width * 0.05,
                            height: s.width * 0.05,
                          ),
                        ),
                        // Correction de la syntaxe du suffixIcon

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(s.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(s.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(s.width * 0.05)),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: s.height * 0.64,
                  left: s.width * 0.1,
                  child: const Text(
                    "Country",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  top: s.height * 0.665,
                  left: s.width * 0.07,
                  right: s.width * 0.07,
                  child: _buildDropDownField(
                    controller: _countryController,
                    hint: "Select Country",
                    items: _listOfCountries,
                    title: "Countries",
                  ),
                ),
                Positioned(
                  top: s.height * 0.75,
                  left: s.width * 0.1,
                  child: Row(
                    children: [
                      Image.asset(
                        "images/photo.png",
                        width: s.width * 0.05,
                        height: s.width * 0.05,
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
                  top: s.height * 0.78,
                  left: s.width * 0.1,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap:
                            _pickImage, // Appelle la fonction pour ouvrir le gestionnaire de fichiers
                        child: Container(
                          width: s.width * 0.07,
                          height: s.width * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(s.width * 0.05),
                          ),
                          child: Image.asset("images/add.png"),
                        ),
                      ),
                      Container(
                          width: s.width *
                              0.05), // Espace entre l'image et le texte
                      Container(
                        width: s.width * 0.7,
                        height: s.width *
                            0.13, // Largeur ajustable pour afficher le chemin

                        decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius:
                                BorderRadius.circular(s.width * 0.05)),
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
                  top: s.height * 0.87,
                  left: s.width * 0.18,
                  child: Container(
                    height: s.height * 0.075,
                    width: s.width * 0.65,
                    decoration: BoxDecoration(
                      color: const Color(0xFF754CEF),
                      borderRadius: BorderRadius.circular(s.width * 0.05),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/podly', (route) => false);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Colors.white, fontSize: s.width * 0.042),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
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
            child: Image.asset("images/map.png",
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
