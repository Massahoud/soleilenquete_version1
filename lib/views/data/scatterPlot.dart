import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../services/data_service.dart'; // Le service pour récupérer les données depuis l'API

class ScatterPlotPage extends StatefulWidget {
  @override
  _ScatterPlotPageState createState() => _ScatterPlotPageState();
}

class _ScatterPlotPageState extends State<ScatterPlotPage> {
  List<ScatterData> scatterData = []; // Liste des points à afficher
  bool isLoading = true;

  // Fonction pour récupérer les données et les formater
  void fetchData() async {
    try {
      // Récupérer les données de l'API
      var data = await DataService().fetchAllData(context);

      // Extraire les champs nécessaires (total, totale, numero)
      List<ScatterData> points = [];
      for (var item in data) {
        double total = item['totale'].toDouble();
        double totale = item['total'].toDouble();
        String numero = item['numero'].toString(); // Le numéro associé au point

        points.add(
            ScatterData(total, totale, numero)); // Ajouter le point au nuage
      }

      setState(() {
        scatterData = points; // Mettre à jour les points à afficher
        isLoading = false; // Changer l'état de chargement
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erreur: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Appeler la fonction pour récupérer les données lors du lancement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuage de Points')),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Afficher un indicateur de chargement
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(
                  title: AxisTitle(
                      text: 'Alimentation/Pauvreté'), // Titre de l'axe X
                  minimum: 0, // Valeur minimale sur l'axe X
                  maximum: 5, // Valeur maximale sur l'axe X
                  interval:
                      1, // Intervalle entre les graduations (0, 1, 2, 3, 4, 5)
                ),
                primaryYAxis: NumericAxis(
                  title:
                      AxisTitle(text: 'Violence/Pauvreté'), // Titre de l'axe Y
                  minimum: 0, // Valeur minimale sur l'axe Y
                  maximum: 5, // Valeur maximale sur l'axe Y
                  interval:
                      1, // Intervalle entre les graduations (0, 1, 2, 3, 4, 5)
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format:
                      'Total: point.x\nTotale: point.y\nNuméro: point.extra', // Afficher les valeurs de x, y et numéro
                  builder: (dynamic data, dynamic point, dynamic series,
                      int pointIndex, int seriesIndex) {
                    final ScatterData scatterData = data;
                    return Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.white,
                      constraints: BoxConstraints(
                        maxWidth: 200, // Largeur maximale
                        maxHeight: 120, // Hauteur maximale
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: ${scatterData.total}'),
                          Text('Totale: ${scatterData.totale}'),
                          Text('Numéro: ${scatterData.numero}'),
                        ],
                      ),
                    );
                  },
                ),
                series: <ScatterSeries<ScatterData, double>>[
                  // Changer de String à double
                  ScatterSeries<ScatterData, double>(
                    dataSource: scatterData,
                    xValueMapper: (ScatterData data, _) => data.total,
                    yValueMapper: (ScatterData data, _) => data.totale,
                    pointColorMapper: (ScatterData data, _) =>
                        Colors.blue, // Couleur des points
                    dataLabelSettings: DataLabelSettings(
                      isVisible:
                          false, // Désactiver l'affichage des étiquettes des points
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Modèle pour les points du nuage de points
class ScatterData {
  final double total;
  final double totale;
  final String numero;

  ScatterData(this.total, this.totale, this.numero);
}
