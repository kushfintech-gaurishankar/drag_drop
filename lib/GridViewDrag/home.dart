import 'package:drag_drop/GridViewDrag/cubit/drag_drop_cubit.dart';
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

  Container container(String name) {
    return Container(
      height: containerSize,
      width: containerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Container containerSmall(int index) {
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
        body: BlocBuilder<DragDropCubit, DragDropState>(
          builder: (context, state) {
            if (state is DragDrop) {
              containerSize = state.containerSize;
              double seatTypeS = state.seatTypeS;
              int crossAxisCount = state.crossAxisCount;
              int gridLength = crossAxisCount * state.mainAxisCount;
              double gridHeight =
                  (state.gridGap * state.mainAxisCount).toDouble();
              double pdAll = state.pdAll;
              double pdBottom = state.pdBottom;
              List<String> seatTypes = state.seatTypes;
              List<SeatModel> seats = state.seats;

              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(pdAll),
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
                                    name: seatTypes[index],
                                    details: details,
                                  ),
                            childWhenDragging: containerSmall(index),
                            feedback: containerSmall(index),
                            child: containerSmall(index),
                          );
                        }),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: seatTypeS + pdAll,
                      left: pdAll,
                      right: pdAll,
                      bottom: pdBottom,
                    ),
                    width: sWidth,
                    child: SingleChildScrollView(
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
                                  child: LongPressDraggable(
                                    delay: const Duration(milliseconds: 100),
                                    data: index,
                                    onDragEnd: (DraggableDetails details) =>
                                        BlocProvider.of<DragDropCubit>(context)
                                          ..updatePosition(
                                              index: index, details: details),
                                    childWhenDragging:
                                        container(seats[index].name),
                                    feedback: container(seats[index].name),
                                    child: container(seats[index].name),
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
}
