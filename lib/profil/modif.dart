import 'package:flutter/material.dart';

class Modifpage extends StatefulWidget {
  const Modifpage({super.key});

  @override
  State<Modifpage> createState() => _ModifpageState();
}

class _ModifpageState extends State<Modifpage> {
  late int n = 1;
  late int q;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is int) {
      q = args;
    } else {
      q = 0; // Valeur par défaut si aucun argument n'est passé
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size e = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              if (q == 2) ...[
                Positioned(
                  top: e.height * 0.01,
                  left: e.width * 0.03,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/podly', (route) => false,
                          arguments: {'selectedIndex': 4});
                    },
                    icon: Image.asset(
                      "images/retour.png",
                      width: e.width * 0.07,
                      height: e.width * 0.07,
                    ),
                  ),
                ),
                Positioned(
                    top: e.height * 0.02,
                    left: e.width * 0.15,
                    child: Text(
                      "Profile",
                      style: TextStyle(
                          fontSize: e.width * 0.06,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.08,
                    left: e.width * 0.38,
                    child: Container(
                      width: e.width * 0.25,
                      height: e.width * 0.25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                      child: ClipOval(
                        child: Image.asset(
                          "images/person.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
                Positioned(
                    top: e.height * 0.166,
                    left: e.width * 0.55,
                    child: Container(
                      width: e.width * 0.09,
                      height: e.width * 0.09,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                    )),
                Positioned(
                    top: e.height * 0.171,
                    left: e.width * 0.56,
                    child: Container(
                      width: e.width * 0.07,
                      height: e.width * 0.07,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                      child: Image.asset("images/add.png"),
                    )),
                Positioned(
                    top: e.height * 0.25,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
                Positioned(
                    top: e.height * 0.3,
                    left: e.width * 0.07,
                    child: Text(
                      "Profile Information",
                      style: TextStyle(
                          fontSize: e.width * 0.05,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.37,
                    left: e.width * 0.07,
                    child: Text(
                      "Username",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.37,
                    left: e.width * 0.35,
                    child: Text(
                      "Younes Benslimane",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                  top: e.height * 0.355,
                  right: e.width * 0.01,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/modif1',
                          arguments: 2, // Passe la valeur de r comme argument
                        );
                      },
                      child: Text(
                        ">",
                        style: TextStyle(
                            fontSize: e.width * 0.06, color: Colors.black),
                      )),
                ),
                Positioned(
                    top: e.height * 0.45,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
                Positioned(
                    top: e.height * 0.47,
                    left: e.width * 0.07,
                    child: Text(
                      "Personal Information",
                      style: TextStyle(
                          fontSize: e.width * 0.05,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.54,
                    left: e.width * 0.07,
                    child: Text(
                      "User Id",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.54,
                    left: e.width * 0.35,
                    child: Text(
                      "23435",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                  top: e.height * 0.52,
                  right: e.width * 0.01,
                  child: TextButton(
                      onPressed: () {},
                      child: Image.asset(
                        "images/copier.png",
                        width: e.width * 0.05,
                        height: e.height * 0.05,
                      )),
                ),
                Positioned(
                    top: e.height * 0.6,
                    left: e.width * 0.07,
                    child: Text(
                      "Email",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.6,
                    left: e.width * 0.35,
                    child: Text(
                      "younesbens3100@gmail.com",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                  top: e.height * 0.585,
                  right: e.width * 0.01,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/modif1',
                          arguments: 3, // Passe la valeur de r comme argument
                        );
                      },
                      child: Text(
                        ">",
                        style: TextStyle(
                            fontSize: e.width * 0.06, color: Colors.black),
                      )),
                ),
                Positioned(
                    top: e.height * 0.66,
                    left: e.width * 0.07,
                    child: Text(
                      "Motpass",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.66,
                    left: e.width * 0.35,
                    child: Text(
                      "younes31",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                  top: e.height * 0.645,
                  right: e.width * 0.01,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/modif1',
                          arguments: 4, // Passe la valeur de r comme argument
                        );
                      },
                      child: Text(
                        ">",
                        style: TextStyle(
                            fontSize: e.width * 0.06, color: Colors.black),
                      )),
                ),
                Positioned(
                    top: e.height * 0.72,
                    left: e.width * 0.07,
                    child: Text(
                      "Country",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.72,
                    left: e.width * 0.35,
                    child: Text(
                      "Algeria",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                    top: e.height * 0.78,
                    left: e.width * 0.07,
                    child: Text(
                      "Age",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.78,
                    left: e.width * 0.35,
                    child: Text(
                      "20",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                    top: e.height * 0.83,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
                Positioned(
                  top: e.height * 0.86,
                  left: e.width * 0.04,
                  child: Image.asset(
                    "images/delete.png",
                    width: e.width * 0.06,
                    height: e.width * 0.06,
                  ),
                ),
                Positioned(
                  top: e.height * 0.86,
                  left: e.width * 0.15,
                  child: Text(
                    "Delete User",
                    style: TextStyle(
                        fontSize: e.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ],
              if (q == 3) ...[
                Positioned(
                  top: e.height * 0.01,
                  left: e.width * 0.03,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/your',
                        (route) => false,
                      );
                    },
                    icon: Image.asset(
                      "images/retour.png",
                      width: e.width * 0.07,
                      height: e.width * 0.07,
                    ),
                  ),
                ),
                Positioned(
                    top: e.height * 0.02,
                    left: e.width * 0.15,
                    child: Text(
                      "Channel",
                      style: TextStyle(
                          fontSize: e.width * 0.06,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.08,
                    left: e.width * 0.38,
                    child: Container(
                      width: e.width * 0.25,
                      height: e.width * 0.25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                      child: ClipOval(
                        child: Image.asset(
                          "images/person.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
                Positioned(
                    top: e.height * 0.166,
                    left: e.width * 0.55,
                    child: Container(
                      width: e.width * 0.09,
                      height: e.width * 0.09,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                    )),
                Positioned(
                    top: e.height * 0.171,
                    left: e.width * 0.56,
                    child: Container(
                      width: e.width * 0.07,
                      height: e.width * 0.07,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                      child: Image.asset("images/add.png"),
                    )),
                Positioned(
                    top: e.height * 0.25,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
                Positioned(
                    top: e.height * 0.3,
                    left: e.width * 0.07,
                    child: Text(
                      "Channel Information",
                      style: TextStyle(
                          fontSize: e.width * 0.05,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.37,
                    left: e.width * 0.07,
                    child: Text(
                      "Namechannel",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.37,
                    left: e.width * 0.35,
                    child: Text(
                      "Younes Benslimane",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                  top: e.height * 0.355,
                  right: e.width * 0.01,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/modif1',
                          arguments: 5, // Passe la valeur de r comme argument
                        );
                      },
                      child: Text(
                        ">",
                        style: TextStyle(
                            fontSize: e.width * 0.06, color: Colors.black),
                      )),
                ),
                Positioned(
                    top: e.height * 0.45,
                    left: e.width * 0.07,
                    child: Text(
                      "Channel Id",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.45,
                    left: e.width * 0.35,
                    child: Text(
                      "23435",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                  top: e.height * 0.43,
                  right: e.width * 0.01,
                  child: TextButton(
                      onPressed: () {},
                      child: Image.asset(
                        "images/copier.png",
                        width: e.width * 0.05,
                        height: e.height * 0.05,
                      )),
                ),
                Positioned(
                    top: e.height * 0.55,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
                Positioned(
                  top: e.height * 0.6,
                  left: e.width * 0.04,
                  child: Image.asset(
                    "images/delete.png",
                    width: e.width * 0.06,
                    height: e.width * 0.06,
                  ),
                ),
                Positioned(
                  top: e.height * 0.6,
                  left: e.width * 0.15,
                  child: Text(
                    "Delete Channel",
                    style: TextStyle(
                        fontSize: e.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ],
              if (q == 4) ...[
                Positioned(
                  top: e.height * 0.01,
                  left: e.width * 0.03,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/your',
                        (route) => false,
                      );
                    },
                    icon: Image.asset(
                      "images/retour.png",
                      width: e.width * 0.07,
                      height: e.width * 0.07,
                    ),
                  ),
                ),
                Positioned(
                    top: e.height * 0.02,
                    left: e.width * 0.15,
                    child: Text(
                      "Podcast",
                      style: TextStyle(
                          fontSize: e.width * 0.06,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.08,
                    left: e.width * 0.38,
                    child: Container(
                      width: e.width * 0.25,
                      height: e.width * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(e.width * 0.04),
                        image: DecorationImage(
                          image: AssetImage('images/person.jpg'),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Gérer l'erreur si l'image ne se charge pas
                            print('Erreur de chargement de l\'image');
                          },
                        ),
                        color: Colors.grey[
                            300], // Couleur de secours si l'image ne charge pas
                      ),
                    )),
                Positioned(
                    top: e.height * 0.166,
                    left: e.width * 0.55,
                    child: Container(
                      width: e.width * 0.09,
                      height: e.width * 0.09,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                    )),
                Positioned(
                    top: e.height * 0.171,
                    left: e.width * 0.56,
                    child: Container(
                      width: e.width * 0.07,
                      height: e.width * 0.07,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                      child: Image.asset("images/add.png"),
                    )),
                Positioned(
                    top: e.height * 0.25,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
                Positioned(
                    top: e.height * 0.3,
                    left: e.width * 0.07,
                    child: Text(
                      "Podcast Information",
                      style: TextStyle(
                          fontSize: e.width * 0.05,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.37,
                    left: e.width * 0.07,
                    child: Text(
                      "Namepodcast",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.37,
                    left: e.width * 0.35,
                    child: Text(
                      "Art Of Messi",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                    top: e.height * 0.43,
                    left: e.width * 0.07,
                    child: Text(
                      "Podcast Id",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.43,
                    left: e.width * 0.35,
                    child: Text(
                      "23435",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                  top: e.height * 0.41,
                  right: e.width * 0.01,
                  child: TextButton(
                      onPressed: () {},
                      child: Image.asset(
                        "images/copier.png",
                        width: e.width * 0.05,
                        height: e.height * 0.05,
                      )),
                ),
                Positioned(
                    top: e.height * 0.49,
                    left: e.width * 0.07,
                    child: Text(
                      "Description",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.49,
                    left: e.width * 0.35,
                    child: Text(
                      "Messi At 19 The Golden Boy  ",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                    top: e.height * 0.55,
                    left: e.width * 0.07,
                    child: Text(
                      "Category",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.55,
                    left: e.width * 0.35,
                    child: Text(
                      "Sport",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                    top: e.height * 0.61,
                    left: e.width * 0.07,
                    child: Text(
                      "Playlist",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.61,
                    left: e.width * 0.35,
                    child: Text(
                      "Barcelona 2007",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                    top: e.height * 0.66,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
                Positioned(
                    top: e.height * 0.675,
                    left: e.width * 0.04,
                    child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/modif1', arguments: 6);
                        },
                        child: Text(
                          "Add To A Playlist",
                          style: TextStyle(
                              fontSize: e.width * 0.04,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ))),
                Positioned(
                  top: e.height * 0.75,
                  left: e.width * 0.07,
                  child: Text(
                    "Delete From A playlist",
                    style: TextStyle(
                        fontSize: e.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
                Positioned(
                  top: e.height * 0.81,
                  left: e.width * 0.04,
                  child: Image.asset(
                    "images/delete.png",
                    width: e.width * 0.06,
                    height: e.width * 0.06,
                  ),
                ),
                Positioned(
                  top: e.height * 0.81,
                  left: e.width * 0.15,
                  child: Text(
                    "Delete Podcast",
                    style: TextStyle(
                        fontSize: e.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
                Positioned(
                    top: e.height * 0.86,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
              ],
              if (q == 5) ...[
                Positioned(
                  top: e.height * 0.01,
                  left: e.width * 0.03,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/your',
                        (route) => false,
                      );
                    },
                    icon: Image.asset(
                      "images/retour.png",
                      width: e.width * 0.07,
                      height: e.width * 0.07,
                    ),
                  ),
                ),
                Positioned(
                    top: e.height * 0.02,
                    left: e.width * 0.15,
                    child: Text(
                      "Playlist",
                      style: TextStyle(
                          fontSize: e.width * 0.06,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.08,
                    left: e.width * 0.38,
                    child: Container(
                      width: e.width * 0.25,
                      height: e.width * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(e.width * 0.04),
                        image: DecorationImage(
                          image: AssetImage('images/person.jpg'),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Gérer l'erreur si l'image ne se charge pas
                            print('Erreur de chargement de l\'image');
                          },
                        ),
                        color: Colors.grey[
                            300], // Couleur de secours si l'image ne charge pas
                      ),
                    )),
                Positioned(
                    top: e.height * 0.166,
                    left: e.width * 0.55,
                    child: Container(
                      width: e.width * 0.09,
                      height: e.width * 0.09,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                    )),
                Positioned(
                    top: e.height * 0.171,
                    left: e.width * 0.56,
                    child: Container(
                      width: e.width * 0.07,
                      height: e.width * 0.07,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(e.width * 0.2)),
                      child: Image.asset("images/add.png"),
                    )),
                Positioned(
                    top: e.height * 0.25,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
                Positioned(
                    top: e.height * 0.3,
                    left: e.width * 0.07,
                    child: Text(
                      "Playlist Information",
                      style: TextStyle(
                          fontSize: e.width * 0.05,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.37,
                    left: e.width * 0.07,
                    child: Text(
                      "Nameplaylist",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.37,
                    left: e.width * 0.35,
                    child: Text(
                      " TAHIA barca ",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                    top: e.height * 0.43,
                    left: e.width * 0.07,
                    child: Text(
                      "Playlist Id",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.43,
                    left: e.width * 0.35,
                    child: Text(
                      "23435",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                  top: e.height * 0.41,
                  right: e.width * 0.01,
                  child: TextButton(
                      onPressed: () {},
                      child: Image.asset(
                        "images/copier.png",
                        width: e.width * 0.05,
                        height: e.height * 0.05,
                      )),
                ),
                Positioned(
                    top: e.height * 0.49,
                    left: e.width * 0.07,
                    child: Text(
                      "Description",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.49,
                    left: e.width * 0.35,
                    child: Text(
                      "Messi At 19 The Golden Boy  ",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                    top: e.height * 0.55,
                    left: e.width * 0.07,
                    child: Text(
                      "Nbrpodcast",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                    top: e.height * 0.55,
                    left: e.width * 0.35,
                    child: Text(
                      "20",
                      style: TextStyle(
                        fontSize: e.width * 0.04,
                      ),
                    )),
                Positioned(
                    top: e.height * 0.62,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
                Positioned(
                    top: e.height * 0.64,
                    left: e.width * 0.04,
                    child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/modif1', arguments: 7);
                        },
                        child: Text(
                          "Add More Podcast",
                          style: TextStyle(
                              fontSize: e.width * 0.04,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ))),
                Positioned(
                  top: e.height * 0.69,
                  left: e.width * 0.04,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/modif1', arguments: 8);
                    },
                    child: Text(
                      "Delete From Podcast ",
                      style: TextStyle(
                          fontSize: e.width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                ),
                Positioned(
                  top: e.height * 0.77,
                  left: e.width * 0.04,
                  child: Image.asset(
                    "images/delete.png",
                    width: e.width * 0.06,
                    height: e.width * 0.06,
                  ),
                ),
                Positioned(
                  top: e.height * 0.77,
                  left: e.width * 0.15,
                  child: Text(
                    "Delete Playlist",
                    style: TextStyle(
                        fontSize: e.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
                Positioned(
                    top: e.height * 0.83,
                    left: e.width * 0.07,
                    right: e.width * 0.07,
                    child: Container(
                      width: e.width * 0.8,
                      height: e.height * 0.002, // Épaisseur de la ligne
                      color: Colors.grey[400],
                    )),
              ],
            ],
          )),
    ));
  }
}
