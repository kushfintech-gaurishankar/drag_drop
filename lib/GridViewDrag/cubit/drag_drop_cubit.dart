import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/coordinate_model.dart';
import '../model/seat_model.dart';

part 'drag_drop_state.dart';

class DragDropCubit extends Cubit<DragDropState> {
  final BuildContext context;
  final List<String> seatTypes = [
    "S1",
    "S2",
    "S3",
    "S4",
    "S5",
    "S6",
    "S7",
    "S8",
    "S9",
    "S10"
  ];
  List<SeatModel> seats = [];

  final int crossAxisCount = 25;

  late final double sHeight;
  late final double sWidth;
  late final int gridGap;
  late final double containerSize;
  late final double seatTypeS;
  late final double pdAll;
  late final double pdBottom;
  late final double gridWidth;
  late final Box gridBox;
  late double gridHeight;
  late int mainAxisCount;

  DragDropCubit(this.context) : super(DragDropInitial()) {
    sHeight = MediaQuery.of(context).size.height;
    sWidth = MediaQuery.of(context).size.width;

    // Grid Spacing, Draggable Container size, Seat types container height
    gridGap = (sWidth ~/ crossAxisCount);
    containerSize = gridGap * 2;
    seatTypeS = gridGap * 3;

    // Padding for the container to have perfect grid alignment
    pdAll = (sWidth % gridGap) / 2;
    double gridHeightWithBottom = sHeight - seatTypeS - pdAll;
    pdBottom = gridHeightWithBottom % gridGap;

    // Grid Size
    gridHeight = gridHeightWithBottom - pdBottom;
    gridWidth = sWidth - pdAll * 2;
    mainAxisCount = gridHeight ~/ gridGap;
  }

  DragDrop get _getState => DragDrop(
        crossAxisCount: crossAxisCount,
        mainAxisCount: mainAxisCount,
        gridGap: gridGap,
        containerSize: containerSize,
        seatTypeS: seatTypeS,
        pdAll: pdAll,
        pdBottom: pdBottom,
        seatTypes: seatTypes,
        seats: seats,
      );

  widgetAlignment() {
    emit(_getState);
  }

  checkSeatExist() async {
    // Saved widgets data
    gridBox = await Hive.openBox("Grid");
    String? seatsData = gridBox.get("seats");
    String? dimensions = gridBox.get("dimensions");

    if (seatsData != null) {
      List<dynamic> list = jsonDecode(seatsData) as List;
      seats = list.map((e) => SeatModel.fromJson(e)).toList();

      // Previous Screen dimensions
      Map<String, dynamic> gD = jsonDecode(dimensions!);
      int prevGG = gD["gridGap"];
      int prevMAC = gD["mainAxisCount"];

      if (prevGG != gridGap || prevMAC != mainAxisCount) {
        List<SeatModel> newSeats = seats.map((e) {
          late double nDx;
          late double nDy;

          if (prevMAC > mainAxisCount) {
            mainAxisCount = prevMAC;
            gridHeight = (mainAxisCount * gridGap).toDouble();
          }

          nDx = (e.coordinate.dx / prevGG) * gridGap;
          nDy = (e.coordinate.dy / prevGG) * gridGap;

          return SeatModel(
            name: e.name,
            coordinate: CoordinateModel(
              dx: nDx,
              dy: nDy,
            ),
          );
        }).toList();

        seats = newSeats;
      }
    }

    emit(_getState);

    await gridBox.put(
        "seats", jsonEncode(seats.map((e) => e.toJson()).toList()));

    await gridBox.put(
      "dimensions",
      jsonEncode({
        "gridGap": gridGap,
        "mainAxisCount": mainAxisCount,
      }),
    );

    // gridBox.clear();
  }

  addWidget({required String name, required DraggableDetails details}) async {
    // Checking if the dragged widget touches the grid area or not
    if (details.offset.dy + containerSize < seatTypeS + pdAll) return;

    double newLeft =
        details.offset.dx - pdAll; // New x coordinate of the dragged Widget
    double maxLeft = sWidth -
        containerSize -
        pdAll * 2; // The max x coordinate to which it can be moved
    double left = max(
        0, min(maxLeft, newLeft)); // final x coordinate inside the grid view

    double newTop = details.offset.dy - seatTypeS - pdAll;
    double maxTop = sHeight - seatTypeS - containerSize - pdAll - pdBottom;
    double top = max(0, min(maxTop, newTop));

    // Checking if the dragged widget collides with other widgets inside the grid area or not
    for (int i = 0; i < seats.length; i++) {
      CoordinateModel cdn = seats[i].coordinate;

      bool xExist = cdn.dx <= left && left < cdn.dx + containerSize ||
          left <= cdn.dx && cdn.dx < left + containerSize;
      bool yExist = cdn.dy <= top && top < cdn.dy + containerSize ||
          top <= cdn.dy && cdn.dy < top + containerSize;

      if (xExist && yExist) return;
    }

    // Alignment of widget along with the grid lines
    left = left - (left % gridGap);
    top = top - (top % gridGap);

    if ((top + containerSize) ~/ gridGap == mainAxisCount) {
      mainAxisCount++;
      gridHeight = (mainAxisCount * gridGap).toDouble();

      await gridBox.put(
        "dimensions",
        jsonEncode({
          "gridGap": gridGap,
          "mainAxisCount": mainAxisCount,
        }),
      );
    }

    List<SeatModel> seatModels = seats.toList();

    seatModels.add(SeatModel(
      name: name,
      coordinate: CoordinateModel(dx: left, dy: top),
    ));

    seats = seatModels;

    emit(_getState);

    await gridBox.put(
      "seats",
      jsonEncode(seats.map((e) => e.toJson()).toList()),
    );
  }

  updatePosition(
      {required int index, required DraggableDetails details}) async {
    double prevLeft = seats[index].coordinate.dx;
    double newLeft = details.offset.dx - pdAll;
    double maxLeft = sWidth - containerSize - pdAll * 2;
    double left = max(0, min(maxLeft, newLeft));

    double prevTop = seats[index].coordinate.dy;
    double newTop = details.offset.dy - seatTypeS - pdAll;
    double maxTop = gridHeight - containerSize;
    double top = max(0, min(maxTop, newTop));

    for (int i = 0; i < seats.length; i++) {
      CoordinateModel cdn = seats[i].coordinate;

      // Not checking with the same widget
      if (cdn.dx != prevLeft || cdn.dy != prevTop) {
        bool xExist = cdn.dx <= left && left < cdn.dx + containerSize ||
            left <= cdn.dx && cdn.dx < left + containerSize;
        bool yExist = cdn.dy <= top && top < cdn.dy + containerSize ||
            top <= cdn.dy && cdn.dy < top + containerSize;

        if (xExist && yExist) return;
      }
    }

    double leftDif = left - prevLeft;
    double topDif = top - prevTop;

    left = left - (leftDif % gridGap);
    top = top - (topDif % gridGap);

    if ((top + containerSize) ~/ gridGap == mainAxisCount) {
      mainAxisCount++;
      gridHeight = (mainAxisCount * gridGap).toDouble();

      await gridBox.put(
        "dimensions",
        jsonEncode({
          "gridGap": gridGap,
          "mainAxisCount": mainAxisCount,
        }),
      );
    }

    List<SeatModel> seatModels = seats.toList();

    seatModels[index] = SeatModel(
      name: seats[index].name,
      coordinate: CoordinateModel(dx: left, dy: top),
    );

    seats = seatModels;

    emit(_getState);

    await gridBox.put(
      "seats",
      jsonEncode(seats.map((e) => e.toJson()).toList()),
    );
  }
}
