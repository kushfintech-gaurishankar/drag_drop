import 'package:drag_drop/GridViewDrag/cubit/drag_drop_cubit.dart';
import 'package:drag_drop/GridViewDrag/model/coordinate_model.dart';
import 'package:drag_drop/GridViewDrag/model/seat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double containerSize;

  Container seatContainer(SeatModel seat) {
    return Container(
      height: containerSize,
      width: containerSize,
      decoration: BoxDecoration(
        color: seat.isFoldingSeat ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: seat.isWindowSeat ? Colors.green : Colors.black),
      ),
      child: Center(
        child: Text(
          seat.name,
          style: TextStyle(
            color: seat.isReadingLights ? Colors.deepOrange : Colors.black,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Container seatTypeContainer(int index) {
    return Container(
      width: containerSize,
      height: containerSize,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          "S${index + 1}",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (builder) => DragDropCubit(context)
        ..widgetAlignment()
        ..checkSeatExist(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Builder(builder: (context) {
              return IconButton(
                onPressed: () =>
                    BlocProvider.of<DragDropCubit>(context)..clearData(),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              );
            }),
          ],
        ),
        body: BlocBuilder<DragDropCubit, DragDropState>(
          builder: (context, state) {
            if (state is DragDrop) {
              ScrollController sController = state.sController;
              containerSize = state.containerSize;
              double seatTypeS = state.seatTypeS;
              int crossAxisCount = state.crossAxisCount;
              int gridLength = crossAxisCount * state.mainAxisCount;
              double gridHeight =
                  (state.gridGap * state.mainAxisCount).toDouble();
              double mAll = state.mAll;
              double mBottom = state.mBottom;
              List<String> seatTypes = state.seatTypes;
              List<SeatModel> seats = state.seats;

              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(mAll),
                    height: seatTypeS,
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(seatTypes.length, (index) {
                          return LongPressDraggable(
                            delay: const Duration(milliseconds: 100),
                            onDragEnd: (DraggableDetails details) =>
                                BlocProvider.of<DragDropCubit>(context)
                                  ..addWidget(
                                    seat: SeatModel(
                                      name: seatTypes[index],
                                      isWindowSeat: false,
                                      isFoldingSeat: false,
                                      isReadingLights: false,
                                      coordinate: const CoordinateModel(
                                        dx: 0,
                                        dy: 0,
                                      ),
                                    ),
                                    details: details,
                                  ),
                            childWhenDragging: seatTypeContainer(index),
                            feedback: seatTypeContainer(index),
                            child: seatTypeContainer(index),
                          );
                        }),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: seatTypeS + mAll,
                      left: mAll,
                      right: mAll,
                      bottom: mBottom,
                    ),
                    width: sWidth,
                    child: SingleChildScrollView(
                      controller: sController,
                      child: SizedBox(
                        height: gridHeight,
                        child: Stack(
                          children: [
                            GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: crossAxisCount,
                              children: List.generate(gridLength, (index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.black45,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Stack(
                              children: (List.generate(seats.length, (index) {
                                return Positioned(
                                  left: seats[index].coordinate.dx,
                                  top: seats[index].coordinate.dy,
                                  child: GestureDetector(
                                    onTap: () => showModal(
                                      context: context,
                                      seat: seats[index],
                                      index: index,
                                    ),
                                    child: LongPressDraggable(
                                      delay: const Duration(milliseconds: 100),
                                      onDragEnd: (DraggableDetails details) =>
                                          BlocProvider.of<DragDropCubit>(
                                              context)
                                            ..updatePosition(
                                                index: index, details: details),
                                      childWhenDragging:
                                          seatContainer(seats[index]),
                                      feedback: seatContainer(seats[index]),
                                      child: seatContainer(seats[index]),
                                    ),
                                  ),
                                );
                              })),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Container();
          },
        ),
      ),
    );
  }

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
                  width: containerSize,
                  height: containerSize,
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: isF ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: isW ? Colors.green : Colors.black),
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
}
