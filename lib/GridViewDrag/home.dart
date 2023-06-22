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
  late double cHeight;
  late double cWidth;

  Container container(String name) {
    return Container(
      height: cHeight,
      width: cWidth,
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

  Container containerSmall(Color color, int index) {
    return Container(
      width: cWidth,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
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
    double sHeight = MediaQuery.of(context).size.height;
    double sWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (builder) => DragDropCubit(context)..widgetAlignment(),
      child: Scaffold(
        body: BlocBuilder<DragDropCubit, DragDropState>(
          builder: (context, state) {
            if (state is DragDrop) {
              cHeight = state.cHeight;
              cWidth = state.cWidth;
              double sCHeight = state.sCHeight;
              int gridGap = state.gridGap;
              double pdAll = state.pdAll;
              double pdBottom = state.pdBottom;
              int gridLength = state.gridLength;
              List<String> seatTypes = state.seatTypes;
              List<SeatModel> seats = state.seats;

              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(pdAll),
                    height: sCHeight,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(seatTypes.length, (index) {
                          return LongPressDraggable(
                            delay: const Duration(milliseconds: 100),
                            onDragEnd: (DraggableDetails details) =>
                                BlocProvider.of<DragDropCubit>(context)
                                  ..addWidget(
                                      name: seatTypes[index], details: details),
                            childWhenDragging:
                                containerSmall(Colors.purpleAccent, index),
                            feedback: containerSmall(Colors.purple, index),
                            child: containerSmall(Colors.purple, index),
                          );
                        }),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: sCHeight + pdAll,
                      left: pdAll,
                      right: pdAll,
                      bottom: pdBottom,
                    ),
                    width: sWidth,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Stack(
                      children: [
                        GridView.count(
                          crossAxisCount: sWidth ~/ gridGap,
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
                                childWhenDragging: container(seats[index].name),
                                feedback: container(seats[index].name),
                                child: container(seats[index].name),
                              ),
                            );
                          })),
                        ),
                      ],
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
