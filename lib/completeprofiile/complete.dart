import 'package:flutter/material.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class Completepage extends StatefulWidget {
  const Completepage({super.key});

  @override
  State<Completepage> createState() => _CompletepageState();
}

class _CompletepageState extends State<Completepage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Form validation error messages
  String? _firstNameError;
  String? _lastNameError;
  String? _ageError;
  String? _countryError;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      setState(() => isLoading = false);
    });
  }

  bool isLoading = true;
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

  String? _selectedImagePath;
  File? _selectedImageFile;

  // Supabase client instance

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<bool> requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }

  void _pickImage() async {
    if (await requestPermissions()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImagePath = result.files.single.path;
          _selectedImageFile = File(_selectedImagePath!);
        });
      }
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate first name
    if (_firstNameController.text.trim().isEmpty) {
      setState(() {
        _firstNameError = "First name must not be empty";
      });
      isValid = false;
    } else {
      setState(() {
        _firstNameError = null;
      });
    }

    // Validate last name
    if (_lastNameController.text.trim().isEmpty) {
      setState(() {
        _lastNameError = "Last name must not be empty";
      });
      isValid = false;
    } else {
      setState(() {
        _lastNameError = null;
      });
    }

    // Validate age
    if (_ageController.text.trim().isEmpty) {
      setState(() {
        _ageError = "Age must not be empty";
      });
      isValid = false;
    } else if (int.tryParse(_ageController.text.trim()) == null) {
      setState(() {
        _ageError = "Age must be numeric";
      });
      isValid = false;
    } else {
      setState(() {
        _ageError = null;
      });
    }

    // Validate country
    if (_countryController.text.trim().isEmpty) {
      setState(() {
        _countryError = "Country must not be empty";
      });
      isValid = false;
    } else {
      setState(() {
        _countryError = null;
      });
    }
    return isValid;
  }

  Future<String?> _uploadImageToSupabase() async {
    if (_selectedImageFile == null) return null;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final fileName =
          'profile/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload de l'image sur Supabase
      await Supabase.instance.client.storage
          .from('pfeapp')
          .upload(fileName, _selectedImageFile!);

      // Récupération de l'URL publique
      final publicUrl = Supabase.instance.client.storage
          .from('pfeapp')
          .getPublicUrl(fileName);

      // Make sure the URL is actually valid before returning it
      if (publicUrl.isNotEmpty) {
        return publicUrl;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveUserData() async {
    setState(() {});

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No authenticated user found")));
        setState(() {});
        return;
      }

      String photoUrl =
          "https://migwbqbtfzszopvhdzre.supabase.co/storage/v1/object/public/pfeapp/profile/output-onlinejpgtools%20(2).jpg";

      if (_selectedImageFile != null) {
        final uploadedUrl = await _uploadImageToSupabase();

        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          photoUrl = uploadedUrl; // Utilisation de l'URL de l'image uploadée
        } else {}
      } else {}

      // Création des données utilisateur
      final userData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'country': _countryController.text.trim(),
        'photoUrl': photoUrl, // Utilise l'URL finale
        'createdAt': FieldValue.serverTimestamp(),
      };
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      // Mettre à jour chaque document trouvé
      final batch = FirebaseFirestore.instance.batch();

      if (querySnapshot.docs.isEmpty) {
        return;
      }

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, userData);
      }

      // Exécuter le batch
      await batch.commit();
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(context, '/succes', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size s = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: isLoading
              ? const Annimationwidjet()
              : Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                  return Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white,
                      ),
                      child: Stack(
                        children: [
                          // Back button
                          Positioned(
                            top: s.height * 0.03,
                            left: s.width * 0.07,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/SignUp', (route) => false);
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s97 : s18,
                                width: s.width * 0.09,
                                height: s.width * 0.09,
                              ),
                            ),
                          ),
                          // Title
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

                          // First Name Field
                          Positioned(
                            top: s.height * 0.29,
                            left: s.width * 0.1,
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
                                _firstNameError != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _firstNameError!,
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Positioned(
                            top: s.height * 0.315,
                            left: s.width * 0.07,
                            right: s.width * 0.07,
                            child: SizedBox(
                              width: s.width - 60,
                              child: TextFormField(
                                controller: _firstNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "First name must not be empty";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _firstNameError = null;
                                  });
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  errorText: _firstNameError,
                                  filled: true,
                                  fillColor: const Color(0xFFD9D9D9),
                                  hintText: "Enter First Name",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(s.width * 0.028),
                                    child: Image.network(
                                      s22,
                                      width: s.width * 0.05,
                                      height: s.width * 0.05,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Last Name Field
                          Positioned(
                            top: s.height * 0.405,
                            left: s.width * 0.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Last Name",
                                  style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                _lastNameError != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _lastNameError!,
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Positioned(
                            top: s.height * 0.43,
                            left: s.width * 0.07,
                            right: s.width * 0.07,
                            child: SizedBox(
                              width: s.width - 60,
                              child: TextFormField(
                                controller: _lastNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Last name must not be empty";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _lastNameError = null;
                                  });
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  errorText: _lastNameError,
                                  filled: true,
                                  fillColor: const Color(0xFFD9D9D9),
                                  hintText: "Enter Last Name",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(s.width * 0.028),
                                    child: Image.network(
                                      s22,
                                      width: s.width * 0.05,
                                      height: s.width * 0.05,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Age Field
                          Positioned(
                            top: s.height * 0.52,
                            left: s.width * 0.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Age",
                                  style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                _ageError != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _ageError!,
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Positioned(
                            top: s.height * 0.545,
                            left: s.width * 0.07,
                            right: s.width * 0.07,
                            child: SizedBox(
                              width: s.width - 60,
                              child: TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (_ageController.text.trim().isEmpty) {
                                    return "Age must not be empty";
                                  } else if (int.tryParse(
                                          _ageController.text.trim()) ==
                                      null) {
                                    return "Age must be numeric";
                                  } else {
                                    setState(() {
                                      _ageError = null;
                                    });
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _ageError = null;
                                  });
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  errorText: _ageError,
                                  filled: true,
                                  fillColor: const Color(0xFFD9D9D9),
                                  hintText: "Enter Age",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(s.width * 0.028),
                                    child: Image.network(
                                      s23,
                                      width: s.width * 0.05,
                                      height: s.width * 0.05,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(s.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Country Field
                          Positioned(
                            top: s.height * 0.63,
                            left: s.width * 0.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Country",
                                  style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                _countryError != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _countryError!,
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Positioned(
                            top: s.height * 0.655,
                            left: s.width * 0.07,
                            right: s.width * 0.07,
                            child: _buildDropDownField(
                              controller: _countryController,
                              hint: "Select Country",
                              items: _listOfCountries,
                              title: "Countries",
                              errorText: _countryError,
                            ),
                          ),

                          // Photo Field
                          Positioned(
                            top: s.height * 0.75,
                            left: s.width * 0.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.network(
                                      s25,
                                      width: s.width * 0.05,
                                      height: s.width * 0.05,
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
                              ],
                            ),
                          ),
                          Positioned(
                            top: s.height * 0.78,
                            left: s.width * 0.1,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage, // Open file manager
                                  child: Container(
                                    width: s.width * 0.07,
                                    height: s.width * 0.07,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(s.width * 0.05),
                                    ),
                                    child: Image.network(s26),
                                  ),
                                ),
                                Container(
                                    width: s.width *
                                        0.05), // Space between image and text
                                Container(
                                  width: s.width * 0.7,
                                  height: s.width * 0.13,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9D9D9),
                                    borderRadius:
                                        BorderRadius.circular(s.width * 0.05),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _selectedImagePath ?? "",
                                    style: const TextStyle(color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Submit Button
                          Positioned(
                            top: s.height * 0.87,
                            left: s.width * 0.18,
                            child: Container(
                              height: s.height * 0.075,
                              width: s.width * 0.65,
                              decoration: BoxDecoration(
                                color: const Color(0xFF754CEF),
                                borderRadius:
                                    BorderRadius.circular(s.width * 0.05),
                              ),
                              child: MaterialButton(
                                onPressed: () {
                                  bool isValid = _validateForm();
                                  // Force a rebuild to show validation errors
                                  setState(() {});
                                  if (isValid) {
                                    _saveUserData();
                                  }
                                },
                                child: Text(
                                  "Done",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: s.width * 0.042),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    final Size s = MediaQuery.of(context).size;
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return SizedBox(
        width: s.width - 60,
        child: TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Country must not be empty";
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _countryError = null;
            });
          },
          style: const TextStyle(
            color: Colors.black,
          ),
          cursorColor: Colors.black,
          readOnly: true,
          decoration: InputDecoration(
            errorText: _countryError,
            filled: true,
            fillColor: const Color(0xFFD9D9D9),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Padding(
              padding: EdgeInsets.all(s.width * 0.028),
              child: Image.network(
                s24,
                width: s.width * 0.05,
                height: s.width * 0.05,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(s.width * 0.05)),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(s.width * 0.05)),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(s.width * 0.05)),
              borderSide: const BorderSide(
                color: Colors.lightBlue,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(s.width * 0.05)),
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
}
