import 'dart:convert';
import 'dart:math';

import 'package:drag_drop/GridViewDrag/model/seat_type_model.dart';
import 'package:drag_drop/GridViewDrag/model/section_model.dart';
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
  List<SectionModel> sections = [];
  bool updateState = true;

  late final double sHeight;
  late final double sWidth;
  late final double appStatusH;
  late final Box gridBox;

  int crossAxisCount = 25;
  double vWidth = 48;
  double gridTM = 40;
  int angle = 0;

  late double paddingH;
  late int gridGap;
  late double seatTypeH;
  late double buttonH;
  late double gridBM;
  late double gridWidth;
  late double gridHeight;
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
    // Adding remaining padding
    paddingH += ((sWidth - paddingH * 2) % crossAxisCount) / 2;
    seatTypeH = 100;
    buttonH = 50;

    double vSpacing = appStatusH + seatTypeH + buttonH + gridTM;
    double gridWithVM = sHeight - vSpacing;
    gridBM = (gridWithVM % gridGap);
    mainAxisCount = (gridWithVM - gridBM) ~/ gridGap;

    // Grid Size
    gridHeight = (mainAxisCount * gridGap).toDouble();
    gridWidth = (crossAxisCount * gridGap).toDouble();

    sections.add(
      SectionModel(
        name: "First Section",
        seats: const [],
        wheels: const [],
        doors: const [],
        mainAxisCount: mainAxisCount,
        height: gridHeight,
      ),
    );
  }

  DragDrop get _state => DragDrop(
        updateState: updateState,
        sController: sController,
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
        sections: sections,
        vWidth: vWidth,
      );

  loadData() async {
    emit(_state);

    gridBox = await Hive.openBox("Grid");
    int? prevGG = gridBox.get("gridGap");
    String? sectionData = gridBox.get("sections");

    if (prevGG == null) {
      return await gridBox.put("gridGap", gridGap);
    }

    if (sectionData != null) {
      sections = (jsonDecode(sectionData) as List)
          .map((e) => SectionModel.fromJson(e))
          .toList();

      List<SectionModel> newSections = [];

      for (int i = 0; i < sections.length; i++) {
        SectionModel sm = sections[i];
        List<SeatModel> newSeats = sm.seats;
        List<SeatModel> newWheels = sm.wheels;
        List<SeatModel> newDoors = sm.doors;
        int newMAC = mainAxisCount;
        double newHeight = gridHeight;

        if (sm.mainAxisCount > mainAxisCount) {
          newMAC = sm.mainAxisCount;
          newHeight = (newMAC * gridGap).toDouble();
        }

        // Updating data for new screens
        if (prevGG != gridGap) {
          newSeats = sm.seats.map((seat) {
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
              coordinate: CoordinateModel(dx: nDx, dy: nDy),
            );
          }).toList();

          newWheels = sm.wheels.map((seat) {
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

          newDoors = sm.doors.map((seat) {
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
        }

        newSections.add(
          SectionModel(
            name: sm.name,
            seats: newSeats,
            wheels: newWheels,
            doors: newDoors,
            mainAxisCount: newMAC,
            height: newHeight,
          ),
        );
      }

      sections = newSections;

      await gridBox.put(
        "sections",
        jsonEncode(sections.map((e) => e.toJson()).toList()),
      );
    }

    emit(_state);

    if (gridGap != prevGG) {
      await gridBox.put("gridGap", gridGap);
    }
  }

  clearData() async {
    sections = [
      SectionModel(
        name: "First Section",
        seats: const [],
        wheels: const [],
        doors: const [],
        mainAxisCount: mainAxisCount,
        height: gridHeight,
      )
    ];

    emit(_state);

    gridBox.clear();
    await gridBox.put("gridGap", gridGap);
  }

  addSection(String name) async {
    sections.add(SectionModel(
      name: name,
      seats: const [],
      wheels: const [],
      doors: const [],
      mainAxisCount: mainAxisCount,
      height: gridHeight,
    ));
    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
    );
  }

  deleteSection(int index) async {
    sections.removeAt(index);
    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
    );
  }

  editSectionName({required int sectionIndex, required String newName}) async {
    sections[sectionIndex].name = newName;
    updateState = !updateState;
    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
    );
  }

  removeSeat({
    required int sectionIndex,
    required int seatIndex,
    required String name,
  }) async {
    if (name == "Wheel") {
      sections[sectionIndex].wheels.removeAt(seatIndex);
    } else if (name == "Door") {
      sections[sectionIndex].doors.removeAt(seatIndex);
    } else {
      sections[sectionIndex].seats.removeAt(seatIndex);
    }
    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
    );
  }

  rotate() {
    angle = angle == 0 ? 90 : 0;
    emit(_state);
  }

  addSeat({
    required SeatTypeModel sType,
    required DraggableDetails details,
  }) async {
    // Determining seat size
    double seatH =
        double.parse(((sType.height / vWidth) * gridWidth).toStringAsFixed(2));
    double seatW =
        double.parse(((sType.width / vWidth) * gridWidth).toStringAsFixed(2));

    // Checking if the dragged widget touches the grid area or not
    if (details.offset.dy + seatH - (seatH / 4) < (appStatusH + seatTypeH)) {
      return;
    }

    // Finding in which section the dragged widget appears in
    late int sectionIndex;
    double yOffset = details.offset.dy;
    yOffset -= (appStatusH + seatTypeH);
    // Adding the scroll amount
    yOffset += sController.offset;

    // Extra height above the section
    double extraHeight = 0;
    for (int i = 0; i < sections.length; i++) {
      double h = extraHeight + gridTM + sections[i].height;
      if (extraHeight < yOffset && yOffset <= h) {
        sectionIndex = i;
        break;
      }

      extraHeight = h;
    }
    SectionModel section = sections[sectionIndex];

    // New x coordinate of the dragged Widget
    double newLeft = details.offset.dx - paddingH;
    // The max x coordinate to which it can be moved
    double maxLeft = gridWidth - seatW;
    // final x coordinate inside the grid view
    double left = max(0, min(maxLeft, newLeft));

    double newTop = yOffset - gridTM - extraHeight;
    double maxTop = section.height - seatH;
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
    for (int i = 0; i < section.seats.length; i++) {
      CoordinateModel cn = section.seats[i].coordinate;
      double h = section.seats[i].height;
      double w = section.seats[i].width;

      bool xExist = cn.dx <= left && left < cn.dx + w ||
          left <= cn.dx && cn.dx < left + seatW;
      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (xExist && yExist) return;
    }

    // if the dragged widget reaches the end of grid container
    if ((top + seatH) ~/ gridGap >= section.mainAxisCount - 1) {
      sections[sectionIndex].mainAxisCount++;
      sections[sectionIndex].height += gridGap;
    }

    List<SeatModel> seatModels = sections[sectionIndex].seats.toList();
    seatModels.add(SeatModel(
      id: section.seats.length + 1,
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
    sections[sectionIndex].seats = seatModels;

    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
    );
  }

  updateSeatPosition({
    required int sectionIndex,
    required int seatIndex,
    required DraggableDetails details,
  }) async {
    SectionModel section = sections[sectionIndex];
    SeatModel seat = section.seats[seatIndex];

    double prevLeft = seat.coordinate.dx;
    double newLeft = details.offset.dx - paddingH;
    double maxLeft = gridWidth - seat.width;
    double left = max(0, min(maxLeft, newLeft));

    double yOffset = details.offset.dy;
    yOffset -= (appStatusH + seatTypeH);
    yOffset += sController.offset;
    double extraHeight = 0;

    for (int i = 0; i < sectionIndex; i++) {
      extraHeight += gridTM + sections[i].height;
    }

    double prevTop = seat.coordinate.dy;
    double newTop = yOffset - gridTM - extraHeight;
    double maxTop = section.height - seat.height;
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

    for (int i = 0; i < section.seats.length; i++) {
      CoordinateModel cn = section.seats[i].coordinate;
      double h = section.seats[i].height;
      double w = section.seats[i].width;

      // Not checking with the same widget
      if (section.seats[i].id != seat.id) {
        bool xExist = cn.dx <= left && left < cn.dx + w ||
            left <= cn.dx && cn.dx < left + seat.width;
        bool yExist = cn.dy <= top && top < cn.dy + h ||
            top <= cn.dy && cn.dy < top + seat.height;

        if (xExist && yExist) return;
      }
    }

    if ((top + seat.height) ~/ gridGap >= section.mainAxisCount - 1) {
      sections[sectionIndex].mainAxisCount++;
      sections[sectionIndex].height += gridGap;
    }

    List<SeatModel> seatModels = sections[sectionIndex].seats.toList();
    seatModels[seatIndex] = SeatModel(
      id: seat.id,
      name: seat.name,
      icon: seat.icon,
      isWindowSeat: seat.isWindowSeat,
      isFoldingSeat: seat.isFoldingSeat,
      isReadingLights: seat.isReadingLights,
      height: seat.height,
      width: seat.width,
      heightInch: seat.heightInch,
      widthInch: seat.widthInch,
      coordinate: CoordinateModel(dx: left, dy: top),
    );
    sections[sectionIndex].seats = seatModels;

    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
    );
  }

  updateSeat({
    required int sectionIndex,
    required int seatIndex,
    required SeatModel seat,
    required int newHInch,
    required int newWInch,
  }) async {
    SectionModel section = sections[sectionIndex];
    bool overlap = false;

    double seatH =
        double.parse(((newHInch / vWidth) * gridWidth).toStringAsFixed(2));
    double seatW =
        double.parse(((newWInch / vWidth) * gridWidth).toStringAsFixed(2));

    // Checking overlapping with other widgets with the new height and width
    if (seat.heightInch != newHInch || seat.widthInch != newWInch) {
      double left = seat.coordinate.dx;
      double top = seat.coordinate.dy;

      for (int i = 0; i < section.seats.length; i++) {
        CoordinateModel cn = section.seats[i].coordinate;
        double h = section.seats[i].height;
        double w = section.seats[i].width;

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

    late double h, w;
    late int hI, wI;
    // If does not overlap with other and does not exceed grid area, then setting new size
    if (overlap ||
        seatH >= section.height - seat.coordinate.dy ||
        seatW >= gridWidth - seat.coordinate.dx) {
      h = seat.height;
      w = seat.width;

      hI = seat.heightInch;
      wI = seat.widthInch;
    } else {
      h = seatH;
      w = seatW;

      hI = newHInch;
      wI = newWInch;
    }

    String icon = seat.icon;
    if (seat.name != "Driver") {
      if (seat.isWindowSeat && seat.isFoldingSeat) {
        icon = "asset/icons/sfwo.svg";
      } else if (seat.isWindowSeat) {
        icon = "asset/icons/snwo.svg";
      } else if (seat.isFoldingSeat) {
        icon = "asset/icons/sfo.svg";
      } else {
        icon = "asset/icons/sno.svg";
      }
    }

    List<SeatModel> seatModels = sections[sectionIndex].seats.toList();
    seatModels[seatIndex] = SeatModel(
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
    sections[sectionIndex].seats = seatModels;
    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
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

    if (details.offset.dy + seatH - (seatH / 4) < (appStatusH + seatTypeH)) {
      return;
    }

    late int sectionIndex;
    double yOffset = details.offset.dy;
    yOffset -= (appStatusH + seatTypeH);
    yOffset += sController.offset;

    double extraHeight = 0;
    for (int i = 0; i < sections.length; i++) {
      double h = extraHeight + gridTM + sections[i].height;
      if (extraHeight < yOffset && yOffset <= h) {
        sectionIndex = i;
        break;
      }

      extraHeight = h;
    }
    SectionModel section = sections[sectionIndex];

    double newTop = yOffset - gridTM - extraHeight;
    double maxTop = section.height - seatH;
    double top = max(0, min(maxTop, newTop));

    // Checking if the dragged widget collides with other wheels
    for (int i = 0; i < section.wheels.length; i++) {
      CoordinateModel cn = section.wheels[i].coordinate;
      double h = section.wheels[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (yExist) return;
    }

    // Checking if the dragged widget collides with other doors
    for (int i = 0; i < section.doors.length; i++) {
      CoordinateModel cn = section.doors[i].coordinate;
      double h = section.doors[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (yExist) return;
    }

    List<SeatModel> seatModels = sections[sectionIndex].wheels.toList();
    seatModels.add(SeatModel(
      id: section.wheels.length + 1,
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
    sections[sectionIndex].wheels = seatModels;
    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
    );
  }

  updateWheelPosition({
    required int sectionIndex,
    required int wheelIndex,
    required DraggableDetails details,
  }) async {
    SectionModel section = sections[sectionIndex];
    SeatModel seat = section.wheels[wheelIndex];

    double yOffset = details.offset.dy;
    yOffset -= (appStatusH + seatTypeH);
    yOffset += sController.offset;
    double extraHeight = 0;

    for (int i = 0; i < sectionIndex; i++) {
      extraHeight += gridTM + sections[i].height;
    }

    double newTop = yOffset - gridTM - extraHeight;
    double maxTop = section.height - seat.height;
    double top = max(0, min(maxTop, newTop));

    for (int i = 0; i < section.wheels.length; i++) {
      CoordinateModel cn = section.wheels[i].coordinate;
      double h = section.wheels[i].height;

      if (seat.id != section.wheels[i].id) {
        bool yExist = cn.dy <= top && top < cn.dy + h ||
            top <= cn.dy && cn.dy < top + seat.height;

        if (yExist) return;
      }
    }

    for (int i = 0; i < section.doors.length; i++) {
      CoordinateModel cn = section.doors[i].coordinate;
      double h = section.doors[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seat.height;

      if (yExist) return;
    }

    List<SeatModel> seatModels = sections[sectionIndex].wheels.toList();
    seatModels[wheelIndex] = SeatModel(
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
    sections[sectionIndex].wheels = seatModels;
    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
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

    if (details.offset.dy + seatH - (seatH / 4) < (appStatusH + seatTypeH)) {
      return;
    }

    late int sectionIndex;
    double yOffset = details.offset.dy;
    yOffset -= (appStatusH + seatTypeH);
    yOffset += sController.offset;

    double extraHeight = 0;
    for (int i = 0; i < sections.length; i++) {
      double h = extraHeight + gridTM + sections[i].height;
      if (extraHeight < yOffset && yOffset <= h) {
        sectionIndex = i;
        break;
      }

      extraHeight = h;
    }
    SectionModel section = sections[sectionIndex];

    double left = details.offset.dx;

    if (left <= paddingH + gridWidth / 2) {
      left = paddingH - seatW / 2;
    } else {
      left = paddingH + gridWidth - seatW / 2;
    }

    double newTop = yOffset - gridTM - extraHeight;
    double maxTop = section.height - seatH;
    double top = max(0, min(maxTop, newTop));

    for (int i = 0; i < section.doors.length; i++) {
      CoordinateModel cn = section.doors[i].coordinate;
      double h = section.doors[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (yExist && left == section.doors[i].coordinate.dx) return;
    }

    for (int i = 0; i < section.wheels.length; i++) {
      CoordinateModel cn = section.wheels[i].coordinate;
      double h = section.wheels[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seatH;

      if (yExist) return;
    }

    List<SeatModel> seatModels = sections[sectionIndex].doors.toList();
    seatModels.add(SeatModel(
      id: section.doors.length + 1,
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
    sections[sectionIndex].doors = seatModels;
    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
    );
  }

  updateDoorPosition({
    required int sectionIndex,
    required int doorIndex,
    required DraggableDetails details,
  }) async {
    SectionModel section = sections[sectionIndex];
    SeatModel seat = section.doors[doorIndex];

    double yOffset = details.offset.dy;
    yOffset -= (appStatusH + seatTypeH);
    yOffset += sController.offset;
    double extraHeight = 0;

    for (int i = 0; i < sectionIndex; i++) {
      extraHeight += gridTM + sections[i].height;
    }

    double newTop = yOffset - gridTM - extraHeight;
    double maxTop = section.height - seat.height;
    double top = max(0, min(maxTop, newTop));

    double left = details.offset.dx;

    if (left <= paddingH + gridWidth / 2) {
      left = paddingH - seat.width / 2;
    } else {
      left = paddingH + gridWidth - seat.width / 2;
    }

    for (int i = 0; i < section.doors.length; i++) {
      CoordinateModel cn = section.doors[i].coordinate;
      double h = section.doors[i].height;

      if (section.doors[i].id != seat.id) {
        bool yExist = cn.dy <= top && top < cn.dy + h ||
            top <= cn.dy && cn.dy < top + seat.height;

        if (yExist && left == section.doors[i].coordinate.dx) return;
      }
    }

    for (int i = 0; i < section.wheels.length; i++) {
      CoordinateModel cn = section.wheels[i].coordinate;
      double h = section.wheels[i].height;

      bool yExist = cn.dy <= top && top < cn.dy + h ||
          top <= cn.dy && cn.dy < top + seat.height;

      if (yExist) return;
    }

    List<SeatModel> seatModels = sections[sectionIndex].doors.toList();
    seatModels[doorIndex] = SeatModel(
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
    sections[sectionIndex].doors = seatModels;
    updateState = !updateState;

    emit(_state);

    await gridBox.put(
      "sections",
      jsonEncode(sections.map((e) => e.toJson()).toList()),
    );
  }
}
