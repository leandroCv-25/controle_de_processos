import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SettingsControlPosition extends StatelessWidget {
  const SettingsControlPosition({
    super.key,
    required this.kp,
    required this.ki,
    required this.kd,
    required this.onChangedKp,
    required this.onChangedKi,
    required this.onChangedKd,
    required this.isClosedLoop,
    required this.onChangedIsClosedLoop,
  });

  final double kp;
  final double ki;
  final double kd;

  final bool isClosedLoop;

  final Function(double) onChangedKp;
  final Function(double) onChangedKi;
  final Function(double) onChangedKd;
  final Function(bool) onChangedIsClosedLoop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StaggeredGrid.extent(
        maxCrossAxisExtent:
            MediaQuery.of(context).size.width > 1024 ? 600 : 250,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        children: [
          StaggeredGridTile.extent(
            crossAxisCellCount: 2,
            mainAxisExtent: 50,
            child: Text(
              "Dados do Controlador",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 1,
            mainAxisExtent: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Malha Fechada",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                Switch(
                  onChanged: onChangedIsClosedLoop,
                  value: isClosedLoop,
                ),
              ],
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 1,
            mainAxisExtent: 50,
            child: TextFormField(
              enabled: isClosedLoop,
              style: Theme.of(context).textTheme.bodyMedium,
              strutStyle: StrutStyle.fromTextStyle(
                Theme.of(context).textTheme.bodyMedium!,
              ),
              initialValue: kp.toString(),
              onChanged: (value) {
                double? ganho = double.tryParse(value);
                if (ganho == null) {
                  onChangedKp(0);
                } else {
                  onChangedKp(ganho);
                }
              },
              keyboardType: const TextInputType.numberWithOptions(),
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: "Kp:",
              ),
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 1,
            mainAxisExtent: 50,
            child: TextFormField(
              enabled: isClosedLoop,
              style: Theme.of(context).textTheme.bodyMedium,
              strutStyle: StrutStyle.fromTextStyle(
                Theme.of(context).textTheme.bodyMedium!,
              ),
              initialValue: ki.toString(),
              onChanged: (value) {
                double? ganho = double.tryParse(value);
                if (ganho == null) {
                  onChangedKi(0);
                } else {
                  onChangedKi(ganho);
                }
              },
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Kd:",
              ),
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 1,
            mainAxisExtent: 50,
            child: TextFormField(
              enabled: isClosedLoop,
              style: Theme.of(context).textTheme.bodyMedium,
              strutStyle: StrutStyle.fromTextStyle(
                Theme.of(context).textTheme.bodyMedium!,
              ),
              initialValue: kd.toString(),
              onChanged: (value) {
                double? ganho = double.tryParse(value);
                if (ganho == null) {
                  onChangedKd(0);
                } else {
                  onChangedKd(ganho);
                }
              },
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Kd:",
              ),
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 3,
            mainAxisExtent: 80,
            child: Column(
              children: [
                Text(
                  "Posição",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Slider(
                  value: 150,
                  max: 200,
                  divisions: 5,
                  label: 150.toString(),
                  onChanged: (double value) {},
                ),
              ],
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 3,
            mainAxisExtent: 80,
            child: Column(
              children: [
                Text(
                  "Velocidade Máxima",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Slider(
                  value: 100,
                  max: 100,
                  divisions: 5,
                  label: 100.toString(),
                  onChanged: (double value) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
