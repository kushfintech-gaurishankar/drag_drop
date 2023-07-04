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

  TextEditingController heightC = TextEditingController();
  TextEditingController widthC = TextEditingController();

  heightC.text = seat.heightInch.toString();
  widthC.text = seat.widthInch.toString();

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
                  width: seat.width / gridGap * (isSmall ? 30 : 20),
                  height: seat.height / gridGap * (isSmall ? 30 : 20),
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
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: widthC,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: "Width",
                          hintText: "Width in inch",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: heightC,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: "Height",
                          hintText: "Height in inch",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    bool noChange =
                        seat.isWindowSeat == features[0]["status"] &&
                            seat.isFoldingSeat == features[1]["status"] &&
                            seat.isReadingLights == features[2]["status"] &&
                            seat.heightInch == int.parse(heightC.text) &&
                            seat.widthInch == int.parse(widthC.text);
                    if (noChange) return;

                    SeatModel newSeat = SeatModel(
                      id: seat.id,
                      name: seat.name,
                      icon: seat.icon,
                      isWindowSeat: features[0]["status"],
                      isFoldingSeat: features[1]["status"],
                      isReadingLights: features[2]["status"],
                      height: seat.height,
                      width: seat.width,
                      heightInch: seat.heightInch,
                      widthInch: seat.widthInch,
                      coordinate: seat.coordinate,
                    );

                    BlocProvider.of<DragDropCubit>(mainContext).updateSeat(
                      index: mainIndex,
                      seat: newSeat,
                      newHInch: int.parse(heightC.text),
                      newWInch: int.parse(widthC.text),
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
