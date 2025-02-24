import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../services/data_service.dart'; // Le service pour récupérer les données depuis l'API

class ScatterPlotPage extends StatefulWidget {
  @override
  _ScatterPlotPageState createState() => _ScatterPlotPageState();
}

class _ScatterPlotPageState extends State<ScatterPlotPage> {
  List<ScatterData> scatterData = []; 
  bool isLoading = true;

  
  void fetchData() async {
    try {
     
      var data = await DataService().fetchAllData(context);

      
      List<ScatterData> points = [];
      for (var item in data) {
        double total = item['totale'].toDouble();
        double totale = item['total'].toDouble();
        String numero = item['numero'].toString();

        points.add(
            ScatterData(total, totale, numero)); 
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

  @override
  void initState() {
    super.initState();
    fetchData(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuage de Points')),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) 
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(
                  title: AxisTitle(
                      text: 'Alimentation/Pauvreté'),
                  minimum: 0,
                  maximum: 5, 
                  interval:
                      1, 
                ),
                primaryYAxis: NumericAxis(
                  title:
                      AxisTitle(text: 'Violence/Pauvreté'), 
                  minimum: 0, 
                  maximum: 5, 
                  interval:
                      1, 
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format:
                      'Total: point.x\nTotale: point.y\nNuméro: point.extra', 
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
                 
                  ScatterSeries<ScatterData, double>(
                    dataSource: scatterData,
                    xValueMapper: (ScatterData data, _) => data.total,
                    yValueMapper: (ScatterData data, _) => data.totale,
                    pointColorMapper: (ScatterData data, _) =>
                        Colors.blue,
                    dataLabelSettings: DataLabelSettings(
                      isVisible:
                          false, 
                    ),
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

  ScatterData(this.total, this.totale, this.numero);
}
