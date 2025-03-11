import 'package:flutter/material.dart';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';

class Modif1page extends StatefulWidget {
  const Modif1page({super.key});

  @override
  State<Modif1page> createState() => _Modif1pageState();
}

class _Modif1pageState extends State<Modif1page> {
  late int n;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is int) {
      n = args;
    } else {
      n = 0; // Valeur par défaut si aucun argument n'est passé
    }
  }

  final List<SelectedListItem<String>> play = [
    SelectedListItem<String>(data: "Education"),
    SelectedListItem<String>(data: "Needs a freinds"),
    SelectedListItem<String>(data: "Nesdds a freinds"),
    SelectedListItem<String>(data: "Music"),
  ];
  final TextEditingController _playController = TextEditingController();
  final List<SelectedListItem<String>> pod = [
    SelectedListItem<String>(data: "Education"),
    SelectedListItem<String>(data: "Needs a freinds"),
    SelectedListItem<String>(data: "Nesdds a freinds"),
    SelectedListItem<String>(data: "Music"),
  ];
  final TextEditingController _playController1 = TextEditingController();

  bool _obscureText2 = true;
  @override
  Widget build(BuildContext context) {
    final Size i = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            if (n == 2) ...[
              Positioned(
                top: i.height * 0.01,
                left: i.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "images/retour.png",
                    width: i.width * 0.07,
                    height: i.width * 0.07,
                  ),
                ),
              ),
              Positioned(
                  top: i.height * 0.02,
                  left: i.width * 0.15,
                  child: Text(
                    "Change Name",
                    style: TextStyle(
                        fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                  )),
              Positioned(
                  top: i.height * 0.1,
                  left: i.width * 0.05,
                  child: Container(
                    width: i.width,
                    child: Text(
                      "You Can Change Your Username And Use The Real Name For Esasy Utilisation ",
                      style: TextStyle(color: Colors.grey),
                      maxLines: 2,
                    ),
                  )),
              Positioned(
                top: i.height * 0.22,
                left: i.width * 0.1,
                child: const Text(
                  "Username",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: i.height * 0.2525,
                left: i.width * 0.07,
                right: i.width * 0.07,
                child: SizedBox(
                  width: i.width - 60,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),

                      hintText: "Enter New Username",
                      hintStyle: const TextStyle(color: Colors.grey),
                      // Utilisation d'une image depuis les assets comme prefixIcon
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(i.width *
                            0.028), // Ajustez le padding selon vos besoins
                        child: Image.asset(
                          "images/person.png", // Remplacez par le chemin de votre icône
                          width: i.width *
                              0.05, // Ajustez la taille selon vos besoins
                          height: i.width * 0.05,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: i.height * 0.36,
                left: i.width * 0.18,
                child: Container(
                  height: i.height * 0.075,
                  width: i.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Implement login logic
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white, fontSize: i.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
            if (n == 3) ...[
              Positioned(
                top: i.height * 0.01,
                left: i.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "images/retour.png",
                    width: i.width * 0.07,
                    height: i.width * 0.07,
                  ),
                ),
              ),
              Positioned(
                  top: i.height * 0.02,
                  left: i.width * 0.15,
                  child: Text(
                    "Change Email",
                    style: TextStyle(
                        fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                  )),
              Positioned(
                  top: i.height * 0.1,
                  left: i.width * 0.05,
                  child: Container(
                    width: i.width,
                    child: Text(
                      "You Can Change Your Email If You Don't Remeber Or You Don't Use The Corrently Adress Email",
                      style: TextStyle(color: Colors.grey),
                      maxLines: 2,
                    ),
                  )),
              Positioned(
                top: i.height * 0.22,
                left: i.width * 0.1,
                child: const Text(
                  "Email",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: i.height * 0.2525,
                left: i.width * 0.07,
                right: i.width * 0.07,
                child: SizedBox(
                  width: i.width - 60,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),

                      hintText: "Enter New Email",
                      hintStyle: const TextStyle(color: Colors.grey),
                      // Utilisation d'une image depuis les assets comme prefixIcon
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(i.width *
                            0.028), // Ajustez le padding selon vos besoins
                        child: Image.asset(
                          "images/gmail.png", // Remplacez par le chemin de votre icône
                          width: i.width *
                              0.05, // Ajustez la taille selon vos besoins
                          height: i.width * 0.05,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: i.height * 0.36,
                left: i.width * 0.18,
                child: Container(
                  height: i.height * 0.075,
                  width: i.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Implement login logic
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white, fontSize: i.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
            if (n == 4) ...[
              Positioned(
                top: i.height * 0.01,
                left: i.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "images/retour.png",
                    width: i.width * 0.07,
                    height: i.width * 0.07,
                  ),
                ),
              ),
              Positioned(
                  top: i.height * 0.02,
                  left: i.width * 0.15,
                  child: Text(
                    "Change Motpass",
                    style: TextStyle(
                        fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                  )),
              Positioned(
                  top: i.height * 0.1,
                  left: i.width * 0.05,
                  child: Container(
                    width: i.width,
                    child: Text(
                      "You Can Change Your Motpass If You Don't Remeber Or Your Corrently Motpass Is Easy To Know ",
                      style: TextStyle(color: Colors.grey),
                      maxLines: 2,
                    ),
                  )),
              Positioned(
                top: i.height * 0.22,
                left: i.width * 0.1,
                child: const Text(
                  "Motpass",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: i.height * 0.2525,
                left: i.width * 0.07,
                right: i.width * 0.07,
                child: SizedBox(
                  width: i.width - 60,
                  child: TextField(
                    obscureText: _obscureText2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),
                      hintText: "Enter New Password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(i.width * 0.028),
                        child: Image.asset(
                          "images/look.png",
                          width: i.width * 0.05,
                          height: 0.05,
                        ),
                      ),
                      // Correction de la syntaxe du suffixIcon
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText2 = !_obscureText2;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(i.width * 0.028),
                          child: Image.asset(
                            "images/view.png",
                            width: i.width * 0.05,
                            height: i.width * 0.05,
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: i.height * 0.36,
                left: i.width * 0.18,
                child: Container(
                  height: i.height * 0.075,
                  width: i.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Implement login logic
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white, fontSize: i.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
            if (n == 5) ...[
              Positioned(
                top: i.height * 0.01,
                left: i.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    /*     Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/your',
                      (route) => false,
                    );*/
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "images/retour.png",
                    width: i.width * 0.07,
                    height: i.width * 0.07,
                  ),
                ),
              ),
              Positioned(
                  top: i.height * 0.02,
                  left: i.width * 0.15,
                  child: Text(
                    "Change Name Channel",
                    style: TextStyle(
                        fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                  )),
              Positioned(
                  top: i.height * 0.1,
                  left: i.width * 0.05,
                  child: Container(
                    width: i.width,
                    child: Text(
                      "You Can Change Your Name Channel And Use The Real Name For Esasy Utilisation ",
                      style: TextStyle(color: Colors.grey),
                      maxLines: 2,
                    ),
                  )),
              Positioned(
                top: i.height * 0.22,
                left: i.width * 0.1,
                child: const Text(
                  "Name Channel",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: i.height * 0.2525,
                left: i.width * 0.07,
                right: i.width * 0.07,
                child: SizedBox(
                  width: i.width - 60,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),

                      hintText: "Enter New Nam Channel",
                      hintStyle: const TextStyle(color: Colors.grey),
                      // Utilisation d'une image depuis les assets comme prefixIcon
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(i.width *
                            0.028), // Ajustez le padding selon vos besoins
                        child: Image.asset(
                          "images/cha.png", // Remplacez par le chemin de votre icône
                          width: i.width *
                              0.05, // Ajustez la taille selon vos besoins
                          height: i.width * 0.05,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(i.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: i.height * 0.36,
                left: i.width * 0.18,
                child: Container(
                  height: i.height * 0.075,
                  width: i.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Implement login logic
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white, fontSize: i.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
            if (n == 6) ...[
              Positioned(
                top: i.height * 0.01,
                left: i.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "images/retour.png",
                    width: i.width * 0.07,
                    height: i.width * 0.07,
                  ),
                ),
              ),
              Positioned(
                  top: i.height * 0.02,
                  left: i.width * 0.15,
                  child: Text(
                    "Add To A playlist",
                    style: TextStyle(
                        fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                  )),
              Positioned(
                  top: i.height * 0.1,
                  left: i.width * 0.05,
                  child: Container(
                    width: i.width,
                    child: Text(
                      "You Can  Add More Podcast To A Playlist For The Esealy Receivit ",
                      style: TextStyle(color: Colors.grey),
                      maxLines: 2,
                    ),
                  )),
              Positioned(
                top: i.height * 0.22,
                left: i.width * 0.1,
                child: const Text(
                  "",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: i.height * 0.22,
                left: i.width * 0.1,
                child: const Text(
                  "Name Playlist ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: i.height * 0.2525,
                left: i.width * 0.07,
                right: i.width * 0.07,
                child: _buildDropDownField1(
                  controller: _playController,
                  hint: "Select Playlist",
                  items: play,
                  title: "Playlist",
                ),
              ),
              Positioned(
                top: i.height * 0.36,
                left: i.width * 0.18,
                child: Container(
                  height: i.height * 0.075,
                  width: i.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Implement login logic
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white, fontSize: i.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
            if (n == 7) ...[
              Positioned(
                top: i.height * 0.01,
                left: i.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "images/retour.png",
                    width: i.width * 0.07,
                    height: i.width * 0.07,
                  ),
                ),
              ),
              Positioned(
                  top: i.height * 0.02,
                  left: i.width * 0.15,
                  child: Text(
                    "Add To A playlist",
                    style: TextStyle(
                        fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                  )),
              Positioned(
                  top: i.height * 0.1,
                  left: i.width * 0.05,
                  child: Container(
                    width: i.width,
                    child: Text(
                      "You Can  Add More Podcast To A Playlist For The Esealy Receivit ",
                      style: TextStyle(color: Colors.grey),
                      maxLines: 2,
                    ),
                  )),
              Positioned(
                top: i.height * 0.22,
                left: i.width * 0.1,
                child: const Text(
                  "Name Podcast ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: i.height * 0.2525,
                left: i.width * 0.07,
                right: i.width * 0.07,
                child: _buildDropDownField2(
                  controller: _playController1,
                  hint: "Select Podcast",
                  items: pod,
                  title: "Podcast",
                ),
              ),
              Positioned(
                top: i.height * 0.36,
                left: i.width * 0.18,
                child: Container(
                  height: i.height * 0.075,
                  width: i.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Implement login logic
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white, fontSize: i.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
            if (n == 8) ...[
              Positioned(
                top: i.height * 0.01,
                left: i.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "images/retour.png",
                    width: i.width * 0.07,
                    height: i.width * 0.07,
                  ),
                ),
              ),
              Positioned(
                  top: i.height * 0.02,
                  left: i.width * 0.15,
                  child: Text(
                    "Delete From playlist",
                    style: TextStyle(
                        fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                  )),
              Positioned(
                  top: i.height * 0.1,
                  left: i.width * 0.05,
                  child: Container(
                    width: i.width,
                    child: Text(
                      "You Can  Delete More Podcast From Playlist For The Esealy Receivit ",
                      style: TextStyle(color: Colors.grey),
                      maxLines: 2,
                    ),
                  )),
              Positioned(
                top: i.height * 0.22,
                left: i.width * 0.1,
                child: const Text(
                  "Name Podcast ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: i.height * 0.2525,
                left: i.width * 0.07,
                right: i.width * 0.07,
                child: _buildDropDownField2(
                  controller: _playController1,
                  hint: "Select Podcast",
                  items: pod,
                  title: "Podcast",
                ),
              ),
              Positioned(
                top: i.height * 0.36,
                left: i.width * 0.18,
                child: Container(
                  height: i.height * 0.075,
                  width: i.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Implement login logic
                    },
                    child: Text(
                      "Delete",
                      style: TextStyle(
                          color: Colors.white, fontSize: i.width * 0.042),
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

  Widget _buildDropDownField2({
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
            child: Image.asset("images/podcast.png",
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
