import 'package:flutter/material.dart';

class Group228Widget extends StatelessWidget {
  const Group228Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1120,
      height: 24,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 480,
            child: Text(
              'Rôle(s)',
              style: TextStyle(
                color: Color.fromRGBO(103, 97, 98, 1),
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.normal,
                height: 1.5,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0, // Petite marge 
            child: Text(
              'ID',
              style: TextStyle(
                color: Color.fromRGBO(103, 97, 98, 1),
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.normal,
                height: 1.5,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Utilisateur',
                  style: TextStyle(
                    color: Color.fromRGBO(103, 97, 98, 1),
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 1.5,
                        left: 4.5,
                        child: Image.asset('assets/images/vector.svg'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 780,
            child: Text(
              'Groupe(s)',
              style: TextStyle(
                color: Color.fromRGBO(103, 97, 98, 1),
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.normal,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}