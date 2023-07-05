import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../cubit/drag_drop_cubit.dart';
import '../model/seat_model.dart';
import 'dart:math' as math;

void bmsSeat({
  required BuildContext mainContext,
  required SeatModel seat,
  required int angle,
  required int mainIndex,
  required int mainAxisCount,
  required int crossAxisCount,
  required int gridGap,
}) {
  TextEditingController seatSize = TextEditingController();
  seatSize.text = seat.widthInch.toString();

  double height = seat.height;
  double width = seat.width;

  bool isSmall = height == gridGap || width == gridGap;

  String icon = seat.icon;
  bool isWindow = seat.isWindowSeat;
  bool isFolding = seat.isFoldingSeat;

  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: mainContext,
    builder: (context) {
      return StatefulBuilder(builder: (context, newSetState) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: seat.width / gridGap * (isSmall ? 30 : 20),
                  height: seat.height / gridGap * (isSmall ? 30 : 20),
                  child: Transform.rotate(
                    angle: angle * math.pi / 180,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SvgPicture.asset(
                            icon,
                            height: double.maxFinite,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          seat.name,
                          style: const TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (seat.name != "Driver")
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 2,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ListTile(
                          dense: true,
                          title: const Text("Is Window"),
                          trailing: Switch(
                            value: isWindow,
                            onChanged: (value) {
                              isWindow = !isWindow;

                              if (isWindow && isFolding) {
                                icon = "asset/icons/sfwo.svg";
                              } else if (isWindow) {
                                icon = "asset/icons/snwo.svg";
                              } else if (isFolding) {
                                icon = "asset/icons/sfo.svg";
                              } else {
                                icon = "asset/icons/sno.svg";
                              }

                              newSetState(() {});
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 2,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ListTile(
                          dense: true,
                          title: const Text("Is Folding"),
                          trailing: Switch(
                            value: isFolding,
                            onChanged: (value) {
                              isFolding = !isFolding;

                              if (isWindow && isFolding) {
                                icon = "asset/icons/sfwo.svg";
                              } else if (isWindow) {
                                icon = "asset/icons/snwo.svg";
                              } else if (isFolding) {
                                icon = "asset/icons/sfo.svg";
                              } else {
                                icon = "asset/icons/sno.svg";
                              }

                              newSetState(() {});
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: seatSize,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: "Size",
                    hintText: "Size in inch",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    SeatModel newSeat = SeatModel(
                      id: seat.id,
                      name: seat.name,
                      icon: seat.icon,
                      isWindowSeat: isWindow,
                      isFoldingSeat: isFolding,
                      isReadingLights: seat.isReadingLights,
                      height: seat.height,
                      width: seat.width,
                      heightInch: seat.heightInch,
                      widthInch: seat.widthInch,
                      coordinate: seat.coordinate,
                    );

                    BlocProvider.of<DragDropCubit>(mainContext).updateSeat(
                      index: mainIndex,
                      seat: newSeat,
                      newHInch: int.parse(seatSize.text),
                      newWInch: int.parse(seatSize.text),
                    );
                  },
                  child: const Text("Save"),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      });
    },
  );
}
