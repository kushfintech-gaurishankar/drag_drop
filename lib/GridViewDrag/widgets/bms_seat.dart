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
  required int seatIndex,
  required int mainAxisCount,
  required int crossAxisCount,
  required int gridGap,
}) {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController seatSize = TextEditingController();
  seatSize.text = seat.widthInch.toString();

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
                if (seat.name != "Wheel" && seat.name != "Door")
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<DragDropCubit>(mainContext).removeSeat(
                          name: seat.name,
                          sectionIndex: mainIndex,
                          seatIndex: seatIndex,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(.2),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  width: 80,
                  height: 80,
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
                if (seat.name != "Driver" &&
                    seat.name != "Wheel" &&
                    seat.name != "Door")
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
                if (seat.name != "Wheel" && seat.name != "Door")
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Form(
                        key: formKey,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: seatSize,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Size must be provided";
                            } else if (double.tryParse(value) == null) {
                              return "Invalid size";
                            }

                            return null;
                          },
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: "Size",
                            hintText: "Size in inch",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

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

                          BlocProvider.of<DragDropCubit>(mainContext)
                              .updateSeat(
                            sectionIndex: mainIndex,
                            seatIndex: seatIndex,
                            seat: newSeat,
                            newHInch: int.parse(seatSize.text),
                            newWInch: int.parse(seatSize.text),
                          );
                        },
                        child: const Text("Save"),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          BlocProvider.of<DragDropCubit>(mainContext)
                              .removeSeat(
                            name: seat.name,
                            sectionIndex: mainIndex,
                            seatIndex: seatIndex,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      });
    },
  );
}
