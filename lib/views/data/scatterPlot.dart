import 'dart:async';
import 'package:flutter/material.dart';
import 'package:soleilenquete/widget/customDialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/data_service.dart';

class ScatterPlotPage extends StatefulWidget {
  @override
  _ScatterPlotPageState createState() => _ScatterPlotPageState();
}

class _ScatterPlotPageState extends State<ScatterPlotPage> {
  List<ScatterData> scatterData = [];
  bool isLoading = true;
  late TooltipBehavior _tooltipBehavior;
  TextEditingController searchController = TextEditingController();
  String? selectedNumero;
  bool isPointHighlighted = false;
  Timer? highlightTimer;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true, format: 'Point: point.x, Numéro: point.y');
    fetchData();
  }

  void fetchData() async {
    try {
      var data = await DataService().fetchAllData(context);
      List<ScatterData> points = [];

      for (var item in data) {
        if (item['moyenneali'] == null || item['moyenneviol'] == null) {
          continue;
        }

       double total = double.parse(item['moyenneali'].toString());
double totale = double.parse(item['moyenneviol'].toString());

        String numero = item['numero'].toString();
        String id = item['id'].toString();

        points.add(ScatterData(total, totale, numero, id));
      }

      setState(() {
        scatterData = points;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (e.toString().contains('Unauthorized') || e.toString().contains('403')) {
        _showSessionExpiredDialog();
      } else {
        print('Erreur: $e');
      }
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: 'Session Expirée',
        content: "Votre session a expiré. Veuillez vous reconnecter.",
        buttonText: "OK",
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    );
  }

  Future<void> _redirectToReact(String pointId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null) {
      final reactUrl =
          "https://app.enquetesoleil.com/child-detail/$pointId?token=$token";
      if (await canLaunch(reactUrl)) {
        await launch(reactUrl, forceWebView: false);
      } else {
        print("Impossible d'ouvrir l'URL");
      }
    } else {
      print("Token non trouvé");
    }
  }

  void _searchPoint(String numero) {
    setState(() {
      selectedNumero = numero;
      _startPointHighlighting();
    });
  }

  void _startPointHighlighting() {
    highlightTimer?.cancel();

    highlightTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (selectedNumero == null) {
        timer.cancel();
      } else {
        setState(() {
          isPointHighlighted = !isPointHighlighted;
        });
      }
    });
  }

  @override
  void dispose() {
    highlightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fond personnalisé pour le Scaffold
     
  appBar: AppBar(
  backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
 leading: GestureDetector(
  onTap: () async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Retour à la page précédente dans Flutter
    } else {
      // Redirection vers l'application React avec le token
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken'); // Récupérer le token

      if (token != null) {
        final reactUrl = "https://app.enquetesoleil.com/child?token=$token"; // URL avec le token
        if (await canLaunch(reactUrl)) {
          await launch(reactUrl, forceWebView: false); // Lancer l'URL
        } else {
          print("Impossible d'ouvrir l'URL");
        }
      } else {
        print("Token non trouvé");
      }
    }
  },
  child: Container(
    margin: EdgeInsets.all(8.0), // Espacement autour du cercle
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.grey[300], // Couleur de fond du cercle
    ),
    child: Icon(
      Icons.chevron_left,
      color: Colors.black, // Couleur de l'icône
      size: 28, // Taille de l'icône
    ),
  ),
),
  title: Center(
    child: SizedBox(
      width: 500, // Définir une largeur fixe pour la barre de recherche
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey), // Bordure grise
          borderRadius: BorderRadius.circular(50), // Coins arrondis
        ),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un numéro...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: TextStyle(color: Colors.black), // Texte en noir
          onSubmitted: _searchPoint,
        ),
      ),
    ),
  ),
),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(
                  title: AxisTitle(text: 'Alimentation/Pauvreté/Education'),
                  minimum: 0,
                  maximum: 5,
                  interval: 1,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Violence/Pauvreté/Cadre_vie'),
                  minimum: 0,
                  maximum: 5,
                  interval: 1,
                ),
                tooltipBehavior: _tooltipBehavior,
                series: <ScatterSeries<ScatterData, double>>[
                  ScatterSeries<ScatterData, double>(
                    dataSource: scatterData,
                    xValueMapper: (ScatterData data, _) => data.totale,
                    yValueMapper: (ScatterData data, _) => data.total,
                    pointColorMapper: (ScatterData data, _) {
                      if (data.numero == selectedNumero) {
                        return isPointHighlighted ? Colors.red : Colors.green;
                      }
                      return Colors.orange;
                    },
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      // tous les points ont la même taille (sauf couleur qui change au scintillement)
                      width: 10,
                      height: 10,
                    ),
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    onPointTap: (ChartPointDetails details) {
                      if (details.pointIndex != null) {
                        final clickedPoint = scatterData[details.pointIndex!];
                        _redirectToReact(clickedPoint.id);
                      }
                    },
                    enableTooltip: true,
                    dataLabelMapper: (ScatterData data, _) => 'Numéro: ${data.numero}',
                  ),
                ],
              ),
            ),
    );
  }
}

class ScatterData {
  final double total;
  final double totale;
  final String numero;
  final String id;

  ScatterData(this.total, this.totale, this.numero, this.id);
}
