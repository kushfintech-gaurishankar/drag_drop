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
  String name = "Lower Decker";
  List<SeatTypeModel> sTypes = const [
    SeatTypeModel(
      name: "A1",
      icon: "asset/icons/sno.svg",
      height: 8,
      width: 8,
    ),
    SeatTypeModel(
      name: "Driver",
      icon: "asset/icons/sdf.svg",
      height: 8,
      width: 8,
    ),
    SeatTypeModel(
      name: "Wheel",
      icon: "asset/icons/wheel.svg",
      height: 4,
      width: 4,
    ),
    SeatTypeModel(
      name: "Door",
      icon: "asset/icons/door.svg",
      height: 4,
      width: 4,
    ),
  ];
  List<SeatModel> seats = [];
  List<SeatModel> wheels = [];
  List<SeatModel> doors = [];

  late final double sHeight;
  late final double sWidth;
  late final double appStatusH;
  late final Box gridBox;

  int crossAxisCount = 25;
  double vWidth = 48;
  double gridTM = 30;
  int angle = 0;

  late double paddingH;
  late int gridGap;
  late double seatTypeH;
  late double buttonH;
  late double gridBM;
  late double gridWidth;
  late double gridHeight;
  late double gridSH;
  late int mainAxisCount;

  DragDropCubit(this.context) : super(DragDropInitial()) {
    sHeight = MediaQuery.of(context).size.height;
    sWidth = MediaQuery.of(context).size.width;

    // Grid Spacing, Draggable Container Height, button height
    double statusBarH = MediaQuery.of(context).viewPadding.top;
    double appBarH = AppBar().preferredSize.height;
    appStatusH = appBarH + statusBarH;
    paddingH = sWidth * .03;
    gridGap = ((sWidth - paddingH * 2) ~/ crossAxisCount);
    paddingH += ((sWidth - paddingH * 2) % crossAxisCount) / 2;
    seatTypeH = sHeight * .12;
    buttonH = sHeight * .06;

    double vSpacing = appStatusH + seatTypeH + buttonH + gridTM;
    double gridWithVM = sHeight - vSpacing;
    gridBM = (gridWithVM % gridGap);
    mainAxisCount = (gridWithVM - gridBM) ~/ gridGap;

    // Grid Size
    gridHeight = (mainAxisCount * gridGap).toDouble();
    gridWidth = (crossAxisCount * gridGap).toDouble();

    gridSH = (mainAxisCount * gridGap).toDouble();
  }

  DragDrop get _state => DragDrop(
        sController: sController,
        name: name,
        crossAxisCount: crossAxisCount,
        mainAxisCount: mainAxisCount,
        gridGap: gridGap,
        gridHeight: gridHeight,
        seatTypeH: seatTypeH,
        paddingH: paddingH,
        buttonH: buttonH,
        gridTM: gridTM,
        gridBM: gridBM,
        angle: angle,
        sTypes: sTypes,
        seats: seats,
        wheels: wheels,
        doors: doors,
        vWidth: vWidth,
      );

  clearData() async {
    seats = [];
    wheels = [];
    doors = [];

    double vSpacing = appStatusH + seatTypeH + buttonH + gridTM + gridBM;
    double gridWithVM = sHeight - vSpacing;
    mainAxisCount = gridWithVM ~/ gridGap;
    gridBox.clear();

    await gridBox.put(
      "dimension",
      jsonEncode({
        "gridGap": gridGap,
        "mainAxisCount": mainAxisCount,
      }),
    );

    emit(_state);
  }

  loadData() async {
    emit(_state);

    gridBox = await Hive.openBox("Grid");
    String? dimension = gridBox.get("dimension");
    String? seatsData = gridBox.get("seats");
    String? wheelData = gridBox.get("wheels");
    String? doorData = gridBox.get("doors");

    if (dimension == null) {
      await gridBox.put(
        "dimension",
        jsonEncode({
          "gridGap": gridGap,
          "mainAxisCount": mainAxisCount,
        }),
      );

      return;
    }

    Map<String, dynamic> gD = jsonDecode(dimension);
    int prevGG = gD["gridGap"];
    int prevMAC = gD["mainAxisCount"];

    if (prevMAC > mainAxisCount) {
      mainAxisCount = prevMAC;
      gridSH = (mainAxisCount * gridGap).toDouble();
    }

    if (seatsData != null) {
      List<dynamic> list = jsonDecode(seatsData) as List;
      seats = list.map((e) => SeatModel.fromJson(e)).toList();

      if (prevGG != gridGap || prevMAC != mainAxisCount) {
        List<SeatModel> newSeats = seats.map((seat) {
          // New Coordinate
          double nDx = (seat.coordinate.dx / prevGG) * gridGap;
          double nDy = (seat.coordinate.dy / prevGG) * gridGap;

          // New Size
          double nH = (seat.heightInch / vWidth) * gridWidth;
          double nW = (seat.widthInch / vWidth) * gridWidth;

          return SeatModel(
            id: seat.id,
            name: seat.name,
            icon: seat.icon,
            isWindowSeat: seat.isWindowSeat,
            isFoldingSeat: seat.isFoldingSeat,
            isReadingLights: seat.isReadingLights,
            height: nH,
            width: nW,
            heightInch: seat.heightInch,
            widthInch: seat.widthInch,
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

    if (wheelData != null) {
      List<dynamic> list = jsonDecode(wheelData) as List;
      wheels = list.map((e) => SeatModel.fromJson(e)).toList();

      if (prevGG != gridGap) {
        List<SeatModel> newSeats = wheels.map((seat) {
          double nH = (seat.heightInch / vWidth) * gridWidth;
          double nW = (seat.widthInch / vWidth) * gridWidth;

          double nDx = paddingH - nW / 2;
          double nDy = (seat.coordinate.dy / prevGG) * gridGap;

          return SeatModel(
            id: seat.id,
            name: seat.name,
            icon: seat.icon,
            isWindowSeat: seat.isWindowSeat,
            isFoldingSeat: seat.isFoldingSeat,
            isReadingLights: seat.isReadingLights,
            height: nH,
            width: nW,
            heightInch: seat.heightInch,
            widthInch: seat.widthInch,
            coordinate: CoordinateModel(dx: nDx, dy: nDy),
          );
        }).toList();

        wheels = newSeats;

        await gridBox.put(
          "wheels",
          jsonEncode(wheels.map((e) => e.toJson()).toList()),
        );
      }
    }

    if (doorData != null) {
      List<dynamic> list = jsonDecode(doorData) as List;
      doors = list.map((e) => SeatModel.fromJson(e)).toList();

      if (prevGG != gridGap) {
        List<SeatModel> newSeats = doors.map((seat) {
          double nH = (seat.heightInch / vWidth) * gridWidth;
          double nW = (seat.widthInch / vWidth) * gridWidth;

          double nDx = seat.coordinate.dx > paddingH + seat.width
              ? paddingH + gridWidth - nW / 2
              : paddingH - nW / 2;
          double nDy = (seat.coordinate.dy / prevGG) * gridGap;

          return SeatModel(
            id: seat.id,
            name: seat.name,
            icon: seat.icon,
            isWindowSeat: seat.isWindowSeat,
            isFoldingSeat: seat.isFoldingSeat,
            isReadingLights: seat.isReadingLights,
            height: nH,
            width: nW,
            heightInch: seat.heightInch,
            widthInch: seat.widthInch,
            coordinate: CoordinateModel(dx: nDx, dy: nDy),
          );
        }).toList();

        doors = newSeats;

        await gridBox.put(
          "doors",
          jsonEncode(doors.map((e) => e.toJson()).toList()),
        );
      }
    }

    emit(_state);

    await gridBox.put(
      "dimension",
      jsonEncode({
        "gridGap": gridGap,
        "mainAxisCount": mainAxisCount,
      }),
    );
  }

  editName(String newName) {
    name = newName;
    emit(_state);
  }

  rotate() {
    angle = angle == 0 ? 90 : 0;
    emit(_state);
  }

  addSeat({
    required SeatTypeModel sType,
    required DraggableDetails details,
  }) async {
    double seatH =
        double.parse(((sType.height / vWidth) * gridWidth).toStringAsFixed(2));
    double seatW =
        double.parse(((sType.width / vWidth) * gridWidth).toStringAsFixed(2));

    // Checking if the dragged widget touches the grid area or not
    if (details.offset.dy + seatH - (seatH / 4) <
        (appStatusH + seatTypeH + gridTM)) {
      return;
    }

    // New x coordinate of the dragged Widget
    double newLeft = details.offset.dx - paddingH;
    // The max x coordinate to which it can be moved
    double maxLeft = gridWidth - seatW;
    // final x coordinate inside the grid view
    double left = max(0, min(maxLeft, newLeft));

    // Adding the y coordinate scroll offset to position it in right place
    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - (appStatusH + seatTypeH + gridTM);
    double maxTop = gridSH - seatH;
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
          left <= cn.dx && cn.dx < left + seatW;
      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (xExist && yExist) return;
    }

    // if the dragged widget reaches the end of grid container
    if ((top + seatH) ~/ gridGap >= mainAxisCount - 1) {
      mainAxisCount += (seatH ~/ gridGap);
      gridSH = (mainAxisCount * gridGap).toDouble();

      await gridBox.put(
        "dimension",
        jsonEncode({
          "gridGap": gridGap,
          "mainAxisCount": mainAxisCount,
        }),
      );
    }

    List<SeatModel> seatModels = seats.toList();

    seatModels.add(SeatModel(
      id: seats.length + 1,
      name: sType.name,
      icon: sType.icon,
      isWindowSeat: false,
      isFoldingSeat: false,
      isReadingLights: false,
      height: seatH,
      width: seatW,
      heightInch: sType.height,
      widthInch: sType.width,
      coordinate: CoordinateModel(dx: left, dy: top),
    ));

    seats = seatModels;

    emit(_state);

    await gridBox.put(
      "seats",
      jsonEncode(seats.map((e) => e.toJson()).toList()),
    );
  }

  updateSeatPosition({
    required int index,
    required DraggableDetails details,
  }) async {
    SeatModel seat = seats[index];

    double prevLeft = seat.coordinate.dx;
    double newLeft = details.offset.dx - paddingH;
    double maxLeft = gridWidth - seat.width;
    double left = max(0, min(maxLeft, newLeft));

    double prevTop = seat.coordinate.dy;
    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - (appStatusH + seatTypeH + gridTM);
    double maxTop = gridSH - seat.height;
    double top = max(0, min(maxTop, newTop));

    if (left != 0) {
      // Not modifying if the dragged widget touches the border
      if (left - prevLeft < 0) {
        if (left % gridGap >= gridGap / 2) {
          left = left - (left % gridGap) + gridGap;
        } else {
          left = left - (left % gridGap);
        }
      } else {
        if ((left + seat.width) % gridGap >= gridGap / 2) {
          left = left - ((left + seat.width) % gridGap) + gridGap;
        } else {
          left = left - ((left + seat.width) % gridGap);
        }
      }
    }

    if (top != 0) {
      if (top - prevTop < 0) {
        if (top % gridGap >= gridGap / 2) {
          top = top - (top % gridGap) + gridGap;
        } else {
          top = top - (top % gridGap);
        }
      } else {
        if ((top + seat.height) % gridGap >= gridGap / 2) {
          top = top - ((top + seat.height) % gridGap) + gridGap;
        } else {
          top = top - ((top + seat.height) % gridGap);
        }
      }
    }

    for (int i = 0; i < seats.length; i++) {
      CoordinateModel cn = seats[i].coordinate;
      double h = seats[i].height;
      double w = seats[i].width;

      // Not checking with the same widget
      if (seats[i].id != seat.id) {
        bool xExist = cn.dx <= left && left < cn.dx + w ||
            left <= cn.dx && cn.dx < left + seat.width;
        bool yExist = cn.dy <= top && top < cn.dy + h ||
            top <= cn.dy && cn.dy < top + seat.height;

        if (xExist && yExist) return;
      }
    }

    if ((top + seat.height) ~/ gridGap >= mainAxisCount - 1) {
      mainAxisCount += (seat.height ~/ gridGap);
      gridSH = (mainAxisCount * gridGap).toDouble();

      await gridBox.put(
        "dimension",
        jsonEncode({
          "gridGap": gridGap,
          "mainAxisCount": mainAxisCount,
        }),
      );
    }

    List<SeatModel> seatModels = seats.toList();

    seatModels[index] = SeatModel(
      id: seats[index].id,
      name: seats[index].name,
      icon: seats[index].icon,
      isWindowSeat: seats[index].isWindowSeat,
      isFoldingSeat: seats[index].isFoldingSeat,
      isReadingLights: seats[index].isReadingLights,
      height: seats[index].height,
      width: seats[index].width,
      heightInch: seats[index].heightInch,
      widthInch: seats[index].widthInch,
      coordinate: CoordinateModel(dx: left, dy: top),
    );

    seats = seatModels;

    emit(_state);

    await gridBox.put(
      "seats",
      jsonEncode(seats.map((e) => e.toJson()).toList()),
    );
  }

  updateSeat({
    required int index,
    required SeatModel seat,
    required int newHInch,
    required int newWInch,
  }) async {
    bool overlap = false;

    double seatH =
        double.parse(((newHInch / vWidth) * gridWidth).toStringAsFixed(2));
    double seatW =
        double.parse(((newWInch / vWidth) * gridWidth).toStringAsFixed(2));

    // Checking overlapping with other widgets with the new height and width
    if (seat.heightInch != newHInch || seat.widthInch != newWInch) {
      double left = seat.coordinate.dx;
      double top = seat.coordinate.dy;

      for (int i = 0; i < seats.length; i++) {
        CoordinateModel cn = seats[i].coordinate;
        double h = seats[i].height;
        double w = seats[i].width;

        if (cn.dx != left || cn.dy != top) {
          bool xExist = cn.dx <= left && left < cn.dx + w ||
              left <= cn.dx && cn.dx < left + seatW;
          bool yExist = cn.dy <= top && top < cn.dy + h ||
              top <= cn.dy && cn.dy < top + seatH;

          if (xExist && yExist) {
            overlap = true;
          }
        }
      }
    }

    // If does not overlap with other, then setting new size without exceeding the grid area
    late double h, w;
    late int hI, wI;
    if (overlap) {
      h = seat.height;
      w = seat.width;

      hI = seat.heightInch;
      wI = seat.widthInch;
    } else {
      h = min(gridSH - seat.coordinate.dy, seatH);
      w = min(gridWidth - seat.coordinate.dx, seatW);

      hI = newHInch;
      wI = newWInch;
    }

    String icon = seat.icon;
    if (seat.isWindowSeat && seat.isFoldingSeat) {
      icon = "asset/icons/sfwo.svg";
    } else if (seat.isWindowSeat) {
      icon = "asset/icons/snwo.svg";
    } else if (seat.isFoldingSeat) {
      icon = "asset/icons/sfo.svg";
    } else {
      icon = "asset/icons/sno.svg";
    }

    List<SeatModel> tempSeats = seats.toList();
    tempSeats[index] = SeatModel(
      id: seat.id,
      name: seat.name,
      icon: icon,
      isWindowSeat: seat.isWindowSeat,
      isFoldingSeat: seat.isFoldingSeat,
      isReadingLights: seat.isReadingLights,
      height: h,
      width: w,
      heightInch: hI,
      widthInch: wI,
      coordinate: seat.coordinate,
    );

    seats = tempSeats;
    emit(_state);

    await gridBox.put(
      "seats",
      jsonEncode(seats.map((e) => e.toJson()).toList()),
    );
  }

  addWheel({
    required SeatTypeModel sType,
    required DraggableDetails details,
  }) async {
    double seatH =
        double.parse(((sType.height / vWidth) * gridWidth).toStringAsFixed(2));
    double seatW =
        double.parse(((sType.width / vWidth) * gridWidth).toStringAsFixed(2));

    // Checking if the dragged widget touches the grid area or not
    if (details.offset.dy + seatH - (seatH / 4) <
        (appStatusH + seatTypeH + gridTM)) {
      return;
    }

    // Adding the y coordinate scroll offset to position it in right place
    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - (appStatusH + seatTypeH + gridTM);
    double maxTop = gridSH - seatH;
    double top = max(0, min(maxTop, newTop));

    // Checking if the dragged widget collides with other widgets inside the grid area or not
    for (int i = 0; i < wheels.length; i++) {
      CoordinateModel cn = wheels[i].coordinate;
      double h = wheels[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (yExist) return;
    }

    for (int i = 0; i < doors.length; i++) {
      CoordinateModel cn = doors[i].coordinate;
      double h = doors[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (yExist) return;
    }

    List<SeatModel> seatModels = wheels.toList();

    seatModels.add(SeatModel(
      id: wheels.length + 1,
      name: sType.name,
      icon: sType.icon,
      isWindowSeat: false,
      isFoldingSeat: false,
      isReadingLights: false,
      height: seatH,
      width: seatW,
      heightInch: sType.height,
      widthInch: sType.width,
      coordinate: CoordinateModel(dx: paddingH - seatW / 2, dy: top),
    ));

    wheels = seatModels;

    emit(_state);

    await gridBox.put(
      "wheels",
      jsonEncode(wheels.map((e) => e.toJson()).toList()),
    );
  }

  updateWheelPosition({
    required int index,
    required DraggableDetails details,
  }) async {
    SeatModel seat = wheels[index];

    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - (appStatusH + seatTypeH + gridTM);
    double maxTop = gridSH - seat.height;
    double top = max(0, min(maxTop, newTop));

    for (int i = 0; i < wheels.length; i++) {
      CoordinateModel cn = wheels[i].coordinate;
      double h = wheels[i].height;

      if (seat.id != wheels[i].id) {
        bool yExist = cn.dy <= top && top < cn.dy + h ||
            top <= cn.dy && cn.dy < top + seat.height;

        if (yExist) return;
      }
    }

    for (int i = 0; i < doors.length; i++) {
      CoordinateModel cn = doors[i].coordinate;
      double h = doors[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seat.height;

      if (yExist) return;
    }

    List<SeatModel> seatModels = wheels.toList();

    seatModels[index] = SeatModel(
      id: seat.id,
      name: seat.name,
      icon: seat.icon,
      isWindowSeat: false,
      isFoldingSeat: false,
      isReadingLights: false,
      height: seat.height,
      width: seat.width,
      heightInch: seat.heightInch,
      widthInch: seat.widthInch,
      coordinate: CoordinateModel(dx: seat.coordinate.dx, dy: top),
    );

    wheels = seatModels;

    emit(_state);

    await gridBox.put(
      "wheels",
      jsonEncode(wheels.map((e) => e.toJson()).toList()),
    );
  }

  addDoor({
    required SeatTypeModel sType,
    required DraggableDetails details,
  }) async {
    double seatH =
        double.parse(((sType.height / vWidth) * gridWidth).toStringAsFixed(2));
    double seatW =
        double.parse(((sType.width / vWidth) * gridWidth).toStringAsFixed(2));

    if (details.offset.dy + seatH - (seatH / 4) <
        (appStatusH + seatTypeH + gridTM)) {
      return;
    }

    double left = details.offset.dx;

    if (left <= paddingH + gridWidth / 2) {
      left = paddingH - seatW / 2;
    } else {
      left = paddingH + gridWidth - seatW / 2;
    }

    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - (appStatusH + seatTypeH + gridTM);
    double maxTop = gridSH - seatH;
    double top = max(0, min(maxTop, newTop));

    for (int i = 0; i < doors.length; i++) {
      CoordinateModel cn = doors[i].coordinate;
      double h = doors[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (yExist && left == doors[i].coordinate.dx) return;
    }

    for (int i = 0; i < wheels.length; i++) {
      CoordinateModel cn = wheels[i].coordinate;
      double h = wheels[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (yExist) return;
    }

    List<SeatModel> seatModels = doors.toList();

    seatModels.add(SeatModel(
      id: doors.length + 1,
      name: sType.name,
      icon: sType.icon,
      isWindowSeat: false,
      isFoldingSeat: false,
      isReadingLights: false,
      height: seatH,
      width: seatW,
      heightInch: sType.height,
      widthInch: sType.width,
      coordinate: CoordinateModel(dx: left, dy: top),
    ));

    doors = seatModels;

    emit(_state);

    await gridBox.put(
      "doors",
      jsonEncode(doors.map((e) => e.toJson()).toList()),
    );
  }

  updateDoorPosition({
    required int index,
    required DraggableDetails details,
  }) async {
    SeatModel seat = doors[index];

    double yOffset = details.offset.dy + sController.offset;
    double newTop = yOffset - (appStatusH + seatTypeH + gridTM);
    double maxTop = gridSH - seat.height;
    double top = max(0, min(maxTop, newTop));

    double left = details.offset.dx;

    if (left <= paddingH + gridWidth / 2) {
      left = paddingH - seat.width / 2;
    } else {
      left = paddingH + gridWidth - seat.width / 2;
    }

    for (int i = 0; i < doors.length; i++) {
      CoordinateModel cn = doors[i].coordinate;
      double h = doors[i].height;

      if (doors[i].id != seat.id) {
        bool yExist = cn.dy <= top && top < cn.dy + h ||
            top <= cn.dy && cn.dy < top + seat.height;

        if (yExist && left == doors[i].coordinate.dx) return;
      }
    }

    for (int i = 0; i < wheels.length; i++) {
      CoordinateModel cn = wheels[i].coordinate;
      double h = wheels[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seat.height;

      if (yExist) return;
    }

    List<SeatModel> seatModels = doors.toList();

    seatModels[index] = SeatModel(
      id: seat.id,
      name: seat.name,
      icon: seat.icon,
      isWindowSeat: false,
      isFoldingSeat: false,
      isReadingLights: false,
      height: seat.height,
      width: seat.width,
      heightInch: seat.heightInch,
      widthInch: seat.widthInch,
      coordinate: CoordinateModel(dx: left, dy: top),
    );

    doors = seatModels;

    emit(_state);

    await gridBox.put(
      "doors",
      jsonEncode(doors.map((e) => e.toJson()).toList()),
    );
  }
}
