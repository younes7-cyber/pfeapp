import 'package:flutter/material.dart';

class Aboutpage extends StatefulWidget {
  const Aboutpage({super.key});

  @override
  State<Aboutpage> createState() => _AboutpageState();
}

class _AboutpageState extends State<Aboutpage> {
  @override
  Widget build(BuildContext context) {
    final Size i = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
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
                  "About Us",
                  style: TextStyle(
                      fontSize: i.width * 0.06, fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: i.height * 0.12,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.1,
                          width: i.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: AssetImage("images/facebook.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.02),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Join Our Channel In Facebook",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                top: i.height * 0.28,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.1,
                          width: i.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: AssetImage("images/insta.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.02),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Join Our Channel In Instagram",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                top: i.height * 0.44,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.1,
                          width: i.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: AssetImage("images/telegrame.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.02),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Join Our Channel In Telegramme",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                top: i.height * 0.6,
                left: i.width * 0.06, // Adjusted to center the container
                child: Container(
                  margin: EdgeInsets.all(i.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(i.width * 0.05),
                    border: Border.all(color: Colors.black12),
                  ),
                  width:
                      i.width * 0.8, // Full width of the screen minus margins
                  height: i.width * 0.3,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        SizedBox(width: i.width * 0.03),
                        Container(
                          height: i.width * 0.08,
                          width: i.width * 0.08,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(i.width * 0.04),
                            image: DecorationImage(
                              image: AssetImage("images/modif1.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: i.width * 0.03),
                        SizedBox(
                          width: i.width * 0.6,
                          child: Text(
                            "Send A report If You Need Help",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: i.width * 0.04,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      )),
    );
  }
}
