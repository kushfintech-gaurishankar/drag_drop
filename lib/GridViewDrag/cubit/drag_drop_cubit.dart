import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/coordinates.dart';
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

  final int gridGap = 20;
  final double cHeight = 60;
  final double cWidth = 60;

  late final double sHeight;
  late final double sWidth;
  late final double sCHeight;
  late final double pdAll;
  late final double pdBottom;
  late final int gridLength;

  DragDropCubit(this.context) : super(DragDropInitial()) {
    sHeight = MediaQuery.of(context).size.height;
    sWidth = MediaQuery.of(context).size.width;
    sCHeight = sHeight * .1;

    pdAll = ((sWidth % gridGap) / 2).toDouble();
    double cHeight = sHeight - sCHeight - pdAll;
    pdBottom = cHeight % gridGap;
    gridLength =
        ((cHeight - pdBottom) ~/ gridGap * (sWidth - pdAll * 2) ~/ gridGap);
  }

  DragDrop get _getState => DragDrop(
        cHeight: cHeight,
        cWidth: cWidth,
        sCHeight: sCHeight,
        gridGap: gridGap,
        pdAll: pdAll,
        pdBottom: pdBottom,
        gridLength: gridLength,
        seatTypes: seatTypes,
        seats: seats,
      );

  widgetAlignment() {
    emit(_getState);
  }

  addWidget({required String name, required DraggableDetails details}) {
    // Checking if the dragged widget touches the grid area or not
    if (details.offset.dy + cHeight < sCHeight + pdAll) return;

    double newLeft = details.offset.dx - pdAll; // New x coordinate of the dragged Widget
    double maxLeft = sWidth - cWidth - pdAll * 2; // The max x coordinate to which it can be moved
    double left = max(0, min(maxLeft, newLeft)); // final x coordinate inside the grid view

    double newTop = details.offset.dy - sCHeight - pdAll;
    double maxTop = sHeight - sCHeight - cHeight - pdAll - pdBottom;
    double top = max(0, min(maxTop, newTop));

    // Checking if the dragged widget collides with other widgets inside the grid area or not
    for (int i = 0; i < seats.length; i++) {
      CoordinateModel cdn = seats[i].coordinate;

      bool xExist = cdn.dx <= left && left < cdn.dx + cWidth ||
          left <= cdn.dx && cdn.dx < left + cWidth;
      bool yExist = cdn.dy <= top && top < cdn.dy + cHeight ||
          top <= cdn.dy && cdn.dy < top + cHeight;

      if (xExist && yExist) return;
    }

    // Alignment of widget along with the grid lines
    left = left - (left % gridGap);
    top = top - (top % gridGap);

    List<SeatModel> seatModels = seats.toList();

    seatModels.add(SeatModel(
      name: name,
      coordinate: CoordinateModel(dx: left, dy: top),
    ));

    seats = seatModels;

    emit(_getState);
  }

  updatePosition({required int index, required DraggableDetails details}) {
    double prevLeft = seats[index].coordinate.dx;
    double newLeft = details.offset.dx - pdAll;
    double maxLeft = sWidth - cWidth - pdAll * 2;
    double left = max(0, min(maxLeft, newLeft));

    double prevTop = seats[index].coordinate.dy;
    double newTop = details.offset.dy - sCHeight - pdAll;
    double maxTop = sHeight - sCHeight - cHeight - pdAll * 2;
    double top = max(0, min(maxTop, newTop));

    for (int i = 0; i < seats.length; i++) {
      CoordinateModel cdn = seats[i].coordinate;

      // Note checking the
      if (cdn.dx != prevLeft || cdn.dy != prevTop) {
        bool xExist = cdn.dx <= left && left < cdn.dx + cWidth ||
            left <= cdn.dx && cdn.dx < left + cWidth;
        bool yExist = cdn.dy <= top && top < cdn.dy + cHeight ||
            top <= cdn.dy && cdn.dy < top + cHeight;

        if (xExist && yExist) return;
      }
    }

    double leftDif = left - prevLeft;
    double topDif = top - prevTop;

    left = left - (leftDif % gridGap);
    top = top - (topDif % gridGap);

    List<SeatModel> seatModels = seats.toList();

    seatModels[index] = SeatModel(
      name: seats[index].name,
      coordinate: CoordinateModel(dx: left, dy: top),
    );

    seats = seatModels;

    emit(_getState);
  }
}
