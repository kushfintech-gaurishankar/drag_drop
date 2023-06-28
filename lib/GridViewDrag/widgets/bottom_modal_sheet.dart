import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/drag_drop_cubit.dart';
import '../model/seat_model.dart';

showModal({
  required BuildContext context,
  required SeatModel seat,
  required int index,
}) {
  bool isW = seat.isWindowSeat;
  bool isF = seat.isFoldingSeat;
  bool isR = seat.isReadingLights;

  showModalBottomSheet(
    context: context,
    builder: (context1) {
      return StatefulBuilder(builder: (context12, newSetState) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: seat.width,
                height: seat.height,
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: isF ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isW ? Colors.green : Colors.black),
                ),
                child: Center(
                  child: Text(
                    seat.name,
                    style: TextStyle(
                      color: isR ? Colors.deepOrange : Colors.black,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListTile(
                  dense: true,
                  title: const Text(
                    "Is Window Seat",
                    style: TextStyle(color: Colors.green),
                  ),
                  trailing: Switch(
                    value: isW,
                    onChanged: (value) {
                      isW = value;
                      BlocProvider.of<DragDropCubit>(context).updateSeat(
                        index: index,
                        seat: SeatModel(
                          name: seat.name,
                          isWindowSeat: isW,
                          isFoldingSeat: isF,
                          isReadingLights: isR,
                          height: seat.height,
                          width: seat.width,
                          coordinate: seat.coordinate,
                        ),
                      );
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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListTile(
                  dense: true,
                  title: const Text(
                    "Is Folding Seat",
                    style: TextStyle(color: Colors.blue),
                  ),
                  trailing: Switch(
                    value: isF,
                    onChanged: (value) {
                      isF = value;
                      BlocProvider.of<DragDropCubit>(context).updateSeat(
                        index: index,
                        seat: SeatModel(
                          name: seat.name,
                          isWindowSeat: isW,
                          isFoldingSeat: isF,
                          isReadingLights: isR,
                          height: seat.height,
                          width: seat.width,
                          coordinate: seat.coordinate,
                        ),
                      );
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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListTile(
                  dense: true,
                  title: const Text(
                    "Is Reading Lights",
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  trailing: Switch(
                    value: isR,
                    onChanged: (value) {
                      isR = value;
                      BlocProvider.of<DragDropCubit>(context).updateSeat(
                        index: index,
                        seat: SeatModel(
                          name: seat.name,
                          isWindowSeat: isW,
                          isFoldingSeat: isF,
                          isReadingLights: isR,
                          height: seat.height,
                          width: seat.width,
                          coordinate: seat.coordinate,
                        ),
                      );
                      newSetState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      });
    },
  );
}
