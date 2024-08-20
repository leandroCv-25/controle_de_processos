import 'package:control_process/model/device_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StatePositionWidget extends StatelessWidget {
  const StatePositionWidget({
    super.key,
    required this.states,
  });

  final List<DeviceState> states;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              "Último estado",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          if (states.isEmpty)
            StaggeredGridTile.extent(
              crossAxisCellCount: 10,
              mainAxisExtent: 50,
              child: Text(
                "Ainda não realizamos nenhuma operação.",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          if (states.isNotEmpty)
            StaggeredGridTile.extent(
              crossAxisCellCount: 1,
              mainAxisExtent: 50,
              child: RichText(
                text: TextSpan(
                  text: "Posição: ",
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    TextSpan(
                      text: (states.last.position).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: " mm",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          if (states.isNotEmpty)
            StaggeredGridTile.extent(
              crossAxisCellCount: 1,
              mainAxisExtent: 50,
              child: RichText(
                text: TextSpan(
                  text: "Erro: ",
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    TextSpan(
                      text: (states.last.error).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: " mm",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          if (states.isNotEmpty)
            StaggeredGridTile.extent(
              crossAxisCellCount: 1,
              mainAxisExtent: 50,
              child: RichText(
                text: TextSpan(
                  text: "Output: ",
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    TextSpan(
                      text: (states.last.output).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: " %",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          if (states.isNotEmpty)
            StaggeredGridTile.extent(
              crossAxisCellCount: 1,
              mainAxisExtent: 50,
              child: RichText(
                text: TextSpan(
                  text: "Velocidade: ",
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    TextSpan(
                      text: (states.last.speed).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: " mm/s",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
