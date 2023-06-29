import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/drag_drop_cubit.dart';
import '../model/seat_model.dart';

void bmsSeat({
  required BuildContext mainContext,
  required SeatModel seat,
  required int mainIndex,
  required int mainAxisCount,
  required int crossAxisCount,
  required int gridGap,
}) {
  List<Map<String, dynamic>> features = [
    {
      "name": "Is Window Seat",
      "color": Colors.green,
      "status": seat.isWindowSeat,
    },
    {
      "name": "Is Folding Seat",
      "color": Colors.blue,
      "status": seat.isFoldingSeat,
    },
    {
      "name": "Is Reading Lights",
      "color": Colors.orange,
      "status": seat.isReadingLights,
    },
  ];

  double height = seat.height;
  double width = seat.width;

  bool isSmall = height == gridGap || width == gridGap;

  showModalBottomSheet(
    context: mainContext,
    builder: (context) {
      return StatefulBuilder(builder: (context, newSetState) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: seat.width / gridGap * (isSmall ? 20 : 10),
                  height: seat.height / gridGap * (isSmall ? 20 : 10),
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: features[1]["status"] ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color:
                          features[0]["status"] ? Colors.green : Colors.black,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      seat.name,
                      style: TextStyle(
                        color: features[2]["status"]
                            ? Colors.deepOrange
                            : Colors.black,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("W$width X H$height"),
                const SizedBox(height: 20),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: features.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return Container(
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
                        title: Text(
                          features[index]["name"],
                          style: TextStyle(color: features[index]["color"]),
                        ),
                        trailing: Switch(
                          value: features[index]["status"],
                          onChanged: (value) {
                            features[index]["status"] = value;

                            newSetState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Width"),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Slider(
                        min: gridGap.toDouble(),
                        max: ((crossAxisCount) * gridGap).toDouble(),
                        divisions: crossAxisCount - 1,
                        value: width,
                        label: width.round().toString(),
                        onChanged: (value) {
                          width = value;
                          newSetState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Height"),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Slider(
                        min: gridGap.toDouble(),
                        max: (mainAxisCount * gridGap).toDouble(),
                        divisions: mainAxisCount - 1,
                        value: height,
                        label: height.round().toString(),
                        onChanged: (value) {
                          height = value;
                          newSetState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    bool noChange =
                        seat.isWindowSeat == features[0]["status"] &&
                            seat.isFoldingSeat == features[1]["status"] &&
                            seat.isReadingLights == features[2]["status"] &&
                            seat.height == height &&
                            seat.width == width;
                    if (noChange) return;

                    SeatModel newSeat = SeatModel(
                      name: seat.name,
                      isWindowSeat: features[0]["status"],
                      isFoldingSeat: features[1]["status"],
                      isReadingLights: features[2]["status"],
                      height: seat.height,
                      width: seat.width,
                      coordinate: seat.coordinate,
                    );

                    Navigator.pop(context);
                    BlocProvider.of<DragDropCubit>(mainContext).updateSeat(
                      index: mainIndex,
                      seat: newSeat,
                      newHeight: height,
                      newWidth: width,
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}