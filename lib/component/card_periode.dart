import 'package:flutter/material.dart';

class Frame188Widget extends StatelessWidget {
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 300,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(52, 52, 52, 0.08),
                offset: Offset(0, 0),
                blurRadius: 40,
              )
            ],
            color: Colors.white,
            border: Border.all(color: Color.fromRGBO(103, 97, 98, 1), width: 1),
          ),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Du',
                        style: TextStyle(
                          color: Color.fromRGBO(103, 97, 98, 0.56),
                          fontFamily: 'Inter',
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(103, 97, 98, 1), width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          '12/05/2024',
                          style: TextStyle(
                            color: Color.fromRGBO(103, 97, 98, 0.56),
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Au',
                        style: TextStyle(
                          color: Color.fromRGBO(103, 97, 98, 0.56),
                          fontFamily: 'Inter',
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(103, 97, 98, 1), width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          '14/02/203',
                          style: TextStyle(
                            color: Color.fromRGBO(103, 97, 98, 0.56),
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Inter',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color.fromRGBO(244, 151, 33, 1),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        'Valider',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
