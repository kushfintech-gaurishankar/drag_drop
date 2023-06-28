import 'dart:convert';
import 'dart:math';

import 'package:drag_drop/GridViewDrag/model/seat_type_model.dart';
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
  List<SeatTypeModel> sTypes = const [
    SeatTypeModel(name: "D", hTimes: 3, wTimes: 2),
    SeatTypeModel(name: "P", hTimes: 2, wTimes: 2),
    SeatTypeModel(name: "H", hTimes: 2, wTimes: 1),
  ];
  List<SeatModel> seats = [];

  late final double sHeight;
  late final double sWidth;
  late final double appBarHeight;
  late final Box gridBox;

  int crossAxisCount = 25;
  late int gridGap;
  late double seatTypeS;
  late double mAll;
  late double mBottom;
  late double gridWidth;
  late double gridHeight;
  late int mainAxisCount;

  DragDropCubit(this.context) : super(DragDropInitial()) {
    sHeight = MediaQuery.of(context).size.height;
    sWidth = MediaQuery.of(context).size.width;
    appBarHeight = AppBar().preferredSize.height;

    // Grid Spacing, Draggable Container size, Seat types container height
    gridGap = (sWidth ~/ crossAxisCount);
    seatTypeS = gridGap * 4;

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
        seatTypeS: seatTypeS,
        mAll: mAll,
        mBottom: mBottom,
        sTypes: sTypes,
        seats: seats,
      );

  widgetAlignment() {
    emit(_getState);
  }

  clearData() {
    seats = [];
    mainAxisCount =
        (sHeight - appBarHeight - seatTypeS - mAll - mBottom) ~/ gridGap;
    emit(_getState);
    gridBox.clear();
  }

  newDimensions(int newCAC) async {
    if (newCAC == crossAxisCount) return;

    String? seatsData = gridBox.get("seats");
    String? dimensions = gridBox.get("dimensions");
    print(dimensions);
    // Map<String, dynamic> gD = jsonDecode(dimensions!);
    // int prevGG = gD["gridGap"];
    // int prevMAC = gD["mainAxisCount"];

    crossAxisCount = newCAC;
    gridGap = (sWidth ~/ crossAxisCount);
    seatTypeS = gridGap * 4;

    mAll = (sWidth % gridGap) / 2;
    double gridHeightWithBottom = sHeight - appBarHeight - seatTypeS - mAll;
    mBottom = gridHeightWithBottom % gridGap;

    gridHeight = gridHeightWithBottom - mBottom;
    gridWidth = (crossAxisCount * gridGap).toDouble();
    mainAxisCount = gridHeight ~/ gridGap;

    // if (seatsData != null) {
    //   List<dynamic> list = jsonDecode(seatsData) as List;
    //   seats = list.map((e) => SeatModel.fromJson(e)).toList();

    //   List<SeatModel> newSeats = seats.map((seat) {
    //     if (prevMAC > mainAxisCount) {
    //       mainAxisCount = prevMAC;
    //       gridHeight = (mainAxisCount * gridGap).toDouble();
    //     }

    //     // New Coordinate
    //     double nDx = (seat.coordinate.dx / prevGG) * gridGap;
    //     double nDy = (seat.coordinate.dy / prevGG) * gridGap;

    //     // New Size
    //     double nH = (seat.height / prevGG) * gridGap;
    //     double nW = (seat.width / prevGG) * gridGap;

    //     return SeatModel(
    //       name: seat.name,
    //       isWindowSeat: seat.isWindowSeat,
    //       isFoldingSeat: seat.isFoldingSeat,
    //       isReadingLights: seat.isReadingLights,
    //       height: nH,
    //       width: nW,
    //       coordinate: CoordinateModel(
    //         dx: nDx,
    //         dy: nDy,
    //       ),
    //     );
    //   }).toList();

    //   seats = newSeats;

    //   await gridBox.put(
    //     "seats",
    //     jsonEncode(seats.map((e) => e.toJson()).toList()),
    //   );
    // }

    emit(_getState);

    await gridBox.put(
      "dimensions",
      jsonEncode({
        "gridGap": gridGap,
        "mainAxisCount": mainAxisCount,
        "crossAxisCount": newCAC,
      }),
    );
  }

  checkSeats() async {
    // Saved widgets data
    gridBox = await Hive.openBox("Grid");
    String? seatsData = gridBox.get("seats");
    String? dimensions = gridBox.get("dimensions");

    if (seatsData != null) {
      List<dynamic> list = jsonDecode(seatsData) as List;
      seats = list.map((e) => SeatModel.fromJson(e)).toList();

      if (dimensions != null) {
        Map<String, dynamic> gD = jsonDecode(dimensions);
        int prevGG = gD["gridGap"];
        int prevMAC = gD["mainAxisCount"];
        int prevCAC = gD["crossAxisCount"];

        if (prevCAC != crossAxisCount) {
          crossAxisCount = prevCAC;
          gridGap = (sWidth ~/ crossAxisCount);
          seatTypeS = gridGap * 4;

          mAll = (sWidth % gridGap) / 2;
          double gridHeightWithBottom =
              sHeight - appBarHeight - seatTypeS - mAll;
          mBottom = gridHeightWithBottom % gridGap;

          gridHeight = gridHeightWithBottom - mBottom;
          gridWidth = (crossAxisCount * gridGap).toDouble();
          mainAxisCount = gridHeight ~/ gridGap;
        }

        if (prevGG != gridGap || prevMAC != mainAxisCount) {
          List<SeatModel> newSeats = seats.map((seat) {
            if (prevMAC > mainAxisCount) {
              mainAxisCount = prevMAC;
              gridHeight = (mainAxisCount * gridGap).toDouble();
            }

            // New Coordinate
            double nDx = (seat.coordinate.dx / prevGG) * gridGap;
            double nDy = (seat.coordinate.dy / prevGG) * gridGap;

            // New Size
            double nH = (seat.height / prevGG) * gridGap;
            double nW = (seat.width / prevGG) * gridGap;

            return SeatModel(
              name: seat.name,
              isWindowSeat: seat.isWindowSeat,
              isFoldingSeat: seat.isFoldingSeat,
              isReadingLights: seat.isReadingLights,
              height: nH,
              width: nW,
              coordinate: CoordinateModel(
                dx: nDx,
                dy: nDy,
              ),
            );
          }).toList();

          seats = newSeats;

          await gridBox.put(
            "seats",
            jsonEncode(seats.map((e) => e.toJson()).toList()),
          );
        }
      }
    }

    emit(_getState);

    await gridBox.put(
      "dimensions",
      jsonEncode({
        "gridGap": gridGap,
        "mainAxisCount": mainAxisCount,
        "crossAxisCount": crossAxisCount,
      }),
    );
  }

  addSeat({
    required SeatModel seat,
    required DraggableDetails details,
  }) async {
    // Checking if the dragged widget touches the grid area or not
    if (details.offset.dy + seat.height - (seat.height / 4) <
        seatTypeS + mAll + appBarHeight) {
      return;
    }

    // New x coordinate of the dragged Widget
    double newLeft = details.offset.dx - mAll;
    // The max x coordinate to which it can be moved
    double maxLeft = sWidth - seat.width - mAll * 2;
    // final x coordinate inside the grid view
    double left = max(0, min(maxLeft, newLeft));

    // Adding the y coordinate scroll offset to position it in right place
    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - appBarHeight - seatTypeS - mAll;
    double maxTop = gridHeight - seat.height;
    double top = max(0, min(maxTop, newTop));

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

    // Checking if the dragged widget collides with other widgets inside the grid area or not
    for (int i = 0; i < seats.length; i++) {
      CoordinateModel cn = seats[i].coordinate;
      double h = seats[i].height;
      double w = seats[i].width;

      bool xExist = cn.dx <= left && left < cn.dx + w ||
          left <= cn.dx && cn.dx < left + seat.width;
      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seat.height;

      if (xExist && yExist) return;
    }

    // if the dragged widget reaches the end of grid container
    if ((top + seat.height) ~/ gridGap == mainAxisCount) {
      mainAxisCount += (seat.height ~/ gridGap);
      gridHeight = (mainAxisCount * gridGap).toDouble();

      await gridBox.put(
        "dimensions",
        jsonEncode({
          "gridGap": gridGap,
          "mainAxisCount": mainAxisCount,
          "crossAxisCount": crossAxisCount,
        }),
      );
    }

    List<SeatModel> seatModels = seats.toList();

    seatModels.add(SeatModel(
      name: seat.name,
      isWindowSeat: seat.isWindowSeat,
      isFoldingSeat: seat.isFoldingSeat,
      isReadingLights: seat.isReadingLights,
      height: seat.height,
      width: seat.width,
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
    SeatModel seat = seats[index];

    double prevLeft = seat.coordinate.dx;
    double newLeft = details.offset.dx - mAll;
    double maxLeft = sWidth - seat.width - mAll * 2;
    double left = max(0, min(maxLeft, newLeft));

    double prevTop = seat.coordinate.dy;
    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - appBarHeight - seatTypeS - mAll;
    double maxTop = gridHeight - seat.height;
    double top = max(0, min(maxTop, newTop));

    if (left != 0) {
      // Not modifying if the dragged widget touches the border
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
    }

    if (top != 0) {
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
    }

    for (int i = 0; i < seats.length; i++) {
      CoordinateModel cn = seats[i].coordinate;
      double h = seats[i].height;
      double w = seats[i].width;

      // Not checking with the same widget
      if (cn.dx != prevLeft || cn.dy != prevTop) {
        bool xExist = cn.dx <= left && left < cn.dx + w ||
            left <= cn.dx && cn.dx < left + seat.width;
        bool yExist = cn.dy <= top && top < cn.dy + h ||
            top <= cn.dy && cn.dy < top + seat.height;

        if (xExist && yExist) return;
      }
    }

    if ((top + seat.height) ~/ gridGap == mainAxisCount) {
      mainAxisCount += (seat.height ~/ gridGap);
      gridHeight = (mainAxisCount * gridGap).toDouble();

      await gridBox.put(
        "dimensions",
        jsonEncode({
          "gridGap": gridGap,
          "mainAxisCount": mainAxisCount,
          "crossAxisCount": crossAxisCount,
        }),
      );
    }

    List<SeatModel> seatModels = seats.toList();

    seatModels[index] = SeatModel(
      name: seats[index].name,
      isWindowSeat: seats[index].isWindowSeat,
      isFoldingSeat: seats[index].isFoldingSeat,
      isReadingLights: seats[index].isReadingLights,
      height: seats[index].height,
      width: seats[index].width,
      coordinate: CoordinateModel(dx: left, dy: top),
    );

    seats = seatModels;

    emit(_getState);

    await gridBox.put(
      "seats",
      jsonEncode(seats.map((e) => e.toJson()).toList()),
    );
  }

  updateSeat({
    required int index,
    required SeatModel seat,
    required double newHeight,
    required double newWidth,
  }) async {
    bool overlap = false;

    if (seat.height != newHeight || seat.width != newWidth) {
      double left = seat.coordinate.dx;
      double top = seat.coordinate.dy;

      for (int i = 0; i < seats.length; i++) {
        CoordinateModel cn = seats[i].coordinate;
        double h = seats[i].height;
        double w = seats[i].width;

        if (cn.dx != left || cn.dy != top) {
          bool xExist = cn.dx <= left && left < cn.dx + w ||
              left <= cn.dx && cn.dx < left + newWidth;
          bool yExist = cn.dy <= top && top < cn.dy + h ||
              top <= cn.dy && cn.dy < top + newHeight;

          if (xExist && yExist) {
            overlap = true;
          }
        }
      }
    }

    // If does not overlap with other, then setting new size
    double h =
        overlap ? seat.height : min(gridHeight - seat.coordinate.dy, newHeight);
    double w =
        overlap ? seat.width : min(gridWidth - seat.coordinate.dx, newWidth);

    List<SeatModel> tempSeats = seats.toList();
    tempSeats[index] = SeatModel(
      name: seat.name,
      isWindowSeat: seat.isWindowSeat,
      isFoldingSeat: seat.isFoldingSeat,
      isReadingLights: seat.isReadingLights,
      height: h,
      width: w,
      coordinate: seat.coordinate,
    );

    seats = tempSeats;
    emit(_getState);

    await gridBox.put(
      "seats",
      jsonEncode(seats.map((e) => e.toJson()).toList()),
    );
  }
}
