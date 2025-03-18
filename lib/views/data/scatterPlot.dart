import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    fetchData(); 
  }

  void fetchData() async {
    try {
      var data = await DataService().fetchAllData(context);
      List<ScatterData> points = [];

      for (var item in data) {
        double total = item['totale'].toDouble();
        double totale = item['total'].toDouble();
        String numero = item['numero'].toString();
        String id = item['id'].toString(); // Récupère l'ID unique de chaque point

        // Ajouter un point avec un ID unique
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
      print('Erreur: $e');
    }
  }

  Future<void> _redirectToReact(String pointId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null) {
      final reactUrl = "https://soleil-enquete-react.vercel.app/?token=$token/plus/$pointId"; 
      if (await canLaunch(reactUrl)) {
        await launch(reactUrl, forceWebView: false);
      } else {
        print("Impossible d'ouvrir l'URL");
      }
    } else {
      print("Token non trouvé");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuage de Points')),
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
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ScatterSeries<ScatterData, double>>[
                  ScatterSeries<ScatterData, double>(
                    dataSource: scatterData,
                    xValueMapper: (ScatterData data, _) => data.total,
                    yValueMapper: (ScatterData data, _) => data.totale,
                    pointColorMapper: (ScatterData data, _) => Colors.blue,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    onPointTap: (ChartPointDetails details) {
                      if (details.pointIndex != null) {
                        final clickedPoint = scatterData[details.pointIndex!];
                        _redirectToReact(clickedPoint.id); // Redirection avec l'ID
                      }
                    },
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
  final String id; // Ajout du champ ID unique

  ScatterData(this.total, this.totale, this.numero, this.id); // Passage de l'ID
}
