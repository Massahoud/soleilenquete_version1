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
        if (item['total'] == null || item['totale'] == null) {
          continue;
        }

        double total = item['total'].toDouble();
        double totale = item['totale'].toDouble();
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

      if (e.toString().contains('403')) {
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
  backgroundColor: Colors.white,
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
                  title: AxisTitle(text: 'Alimentation/Pauvreté'),
                  minimum: 0,
                  maximum: 5,
                  interval: 1,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Violence/Pauvreté'),
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
