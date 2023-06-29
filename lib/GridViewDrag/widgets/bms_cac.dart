import 'package:drag_drop/GridViewDrag/cubit/drag_drop_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void bmsCAC({
  required BuildContext mainContext,
  required double crossAxisCount,
}) {
  showModalBottomSheet(
    context: mainContext,
    builder: (builder) {
      double cAC = crossAxisCount;

      return StatefulBuilder(builder: (sContext, nesState) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Cross Axis Count",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                max: 50,
                min: 20,
                value: cAC.toDouble(),
                label: cAC.toString(),
                divisions: 30,
                onChanged: (value) {
                  crossAxisCount = value;
                  cAC = value;
                  nesState(() {});
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(builder);
                  BlocProvider.of<DragDropCubit>(mainContext)
                      .newDimensions(cAC.toInt());
                },
                child: const Text("Save"),
              ),
            ],
          ),
        );
      });
    },
  );
}
