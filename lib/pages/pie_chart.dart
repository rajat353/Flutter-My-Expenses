import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';

const List<Color> colorList = [
  Color(0xFFDBDBDB),
  Color(0xFF007ED6),
  Color(0xFF52D726),
  Color(0xFFFF7300),
  Color(0xFFa05195),
  Color(0xFFAADEA7),
  Color(0xFFC20606),
  Color(0xFFFFEC00),
];

class PieChartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Chart'),
          ),
          body: PieChart(
            dataMap: model.categoryMap(),
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 30.0,
            chartRadius: MediaQuery.of(context).size.width / 1.5,
            showChartValuesInPercentage: false,
            showChartValuesOutside: true,
            chartValueBackgroundColor: Colors.grey[200],
            colorList: colorList,
            legendPosition: LegendPosition.bottom,
            decimalPlaces: 2,
            showChartValueLabel: true,
            chartValueStyle: defaultChartValueStyle.copyWith(
              color: Colors.blueGrey[900].withOpacity(0.9),
            ),
            chartType: ChartType.disc,
          ));
    });
  }
}
