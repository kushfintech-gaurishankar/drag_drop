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
  final ScrollController sController = ScrollController();
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
  late final double appBarHeight;
  late final int gridGap;
  late final double containerSize;
  late final double seatTypeS;
  late final double mAll;
  late final double mBottom;
  late final double gridWidth;
  late final Box gridBox;
  late double gridHeight;
  late int mainAxisCount;

  DragDropCubit(this.context) : super(DragDropInitial()) {
    sHeight = MediaQuery.of(context).size.height;
    sWidth = MediaQuery.of(context).size.width;
    appBarHeight = AppBar().preferredSize.height;

    // Grid Spacing, Draggable Container size, Seat types container height
    gridGap = (sWidth ~/ crossAxisCount);
    containerSize = gridGap * 2;
    seatTypeS = gridGap * 3;

    // Padding for the container to have perfect grid alignment
    mAll = (sWidth % gridGap) / 2;
    double gridHeightWithBottom = sHeight - appBarHeight - seatTypeS - mAll;
    mBottom = gridHeightWithBottom % gridGap;

    // Grid Size
    gridHeight = gridHeightWithBottom - mBottom;
    gridWidth = (crossAxisCount * gridGap).toDouble();
    mainAxisCount = gridHeight ~/ gridGap;
  }

  DragDrop get _getState => DragDrop(
        sController: sController,
        crossAxisCount: crossAxisCount,
        mainAxisCount: mainAxisCount,
        gridGap: gridGap,
        containerSize: containerSize,
        seatTypeS: seatTypeS,
        mAll: mAll,
        mBottom: mBottom,
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
      "seats",
      jsonEncode(seats.map((e) => e.toJson()).toList()),
    );

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
    if (details.offset.dy + containerSize < seatTypeS + mAll) return;

    // New x coordinate of the dragged Widget
    double newLeft = details.offset.dx - mAll;
    // The max x coordinate to which it can be moved
    double maxLeft = sWidth - containerSize - mAll * 2;
    // final x coordinate inside the grid view
    double left = max(0, min(maxLeft, newLeft));

    // Adding the y coordinate scroll offset to position it in right place
    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - appBarHeight - seatTypeS - mAll;
    double maxTop = gridHeight - containerSize;
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
    if (left % gridGap >= gridGap / 2) {
      left = left - (left % gridGap) + gridGap;
    } else {
      left = left - (left % gridGap);
    }

    if (top % gridGap >= gridGap / 2) {
      top = top - (top % gridGap) + gridGap;
    } else {
      top = top - (top % gridGap);
    }

    if ((top + containerSize) ~/ gridGap == mainAxisCount) {
      mainAxisCount += (containerSize ~/ gridGap);
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

  updatePosition({
    required int index,
    required DraggableDetails details,
  }) async {
    double prevLeft = seats[index].coordinate.dx;
    double newLeft = details.offset.dx - mAll;
    double maxLeft = sWidth - containerSize - mAll * 2;
    double left = max(0, min(maxLeft, newLeft));

    double prevTop = seats[index].coordinate.dy;
    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - appBarHeight - seatTypeS - mAll;
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
    if (leftDif < 0) {
      if ((leftDif * -1) % gridGap >= gridGap / 2) {
        left = left - (leftDif % gridGap);
      } else {
        left = left - (leftDif % gridGap) + gridGap;
      }
    } else {
      if (leftDif % gridGap >= gridGap / 2) {
        left = left - (leftDif % gridGap) + gridGap;
      } else {
        left = left - (leftDif % gridGap);
      }
    }

    double topDif = top - prevTop;
    if (topDif < 0) {
      if ((topDif * -1) % gridGap >= gridGap / 2) {
        top = top - (topDif % gridGap);
      } else {
        top = top - (topDif % gridGap) + gridGap;
      }
    } else {
      if (topDif % gridGap >= gridGap / 2) {
        top = top - (topDif % gridGap) + gridGap;
      } else {
        top = top - (topDif % gridGap);
      }
    }

    if ((top + containerSize) ~/ gridGap == mainAxisCount) {
      mainAxisCount += (containerSize ~/ gridGap);
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
