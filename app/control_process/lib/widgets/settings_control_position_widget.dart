import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SettingsControlPositionWidget extends StatelessWidget {
  const SettingsControlPositionWidget({
    super.key,
    required this.kp,
    required this.ki,
    required this.kd,
    required this.onChangedKp,
    required this.onChangedKi,
    required this.onChangedKd,
    required this.isClosedLoop,
    required this.onChangedIsClosedLoop,
    required this.setPoint,
    required this.vmax,
    required this.onChangedSetPoint,
    required this.onChangedVMax,
    required this.sendMensage,
  });

  final double kp;
  final double ki;
  final double kd;
  final double setPoint;
  final double vmax;

  final bool isClosedLoop;

  final Function(double) onChangedKp;
  final Function(double) onChangedKi;
  final Function(double) onChangedKd;
  final Function(double) onChangedSetPoint;
  final Function(double) onChangedVMax;
  final Function(bool) onChangedIsClosedLoop;
  final Function() sendMensage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StaggeredGrid.extent(
        maxCrossAxisExtent:
            MediaQuery.of(context).size.width > 1024 ? 450 : 250,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        children: [
          StaggeredGridTile.extent(
            crossAxisCellCount: 10,
            mainAxisExtent: 50,
            child: Text(
              "Dados do Controlador",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 10,
            mainAxisExtent: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Malha Fechada",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  width: 8,
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
              initialValue: kp.toStringAsPrecision(3),
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
              initialValue: ki.toStringAsPrecision(3),
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
                labelText: "Ki:",
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
              initialValue: kd.toStringAsPrecision(3),
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
            crossAxisCellCount:
                MediaQuery.of(context).size.width > 1024 ? 1 : 2,
            mainAxisExtent: 120,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Velocidade Máxima:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(
                  height: 120,
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Slider(
                      value: vmax,
                      min: 40,
                      max: 100,
                      divisions: 50,
                      label: "${vmax.toStringAsFixed(2)}%",
                      onChanged: onChangedVMax,
                    ),
                  ),
                ),
              ],
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 1,
            mainAxisExtent: 50,
            child: ElevatedButton(
              onPressed: sendMensage,
              child: const Text("Atualizar"),
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 10,
            mainAxisExtent: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                      text: "Posição: ",
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        TextSpan(
                          text: setPoint.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ]),
                ),
                Slider(
                  value: setPoint,
                  max: 200,
                  // divisions: 5,
                  label: setPoint.toString(),
                  // onChangeStart: onChangedSetPoint,
                  onChanged: onChangedSetPoint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
