import 'package:drag_drop/GridViewDrag/model/seat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/drag_drop_cubit.dart';
import 'bms_seat.dart';

class GridContainer extends StatelessWidget {
  final double paddingH;
  final int gridGap;
  final ScrollController sController;
  final double gridHeight;
  final int crossAxisCount;
  final int mainAxisCount;
  final List<SeatModel> seats;
  final List<SeatModel> otherSeats;

  const GridContainer({
    super.key,
    required this.paddingH,
    required this.gridGap,
    required this.sController,
    required this.gridHeight,
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.seats,
    required this.otherSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.maxFinite,
          height: gridHeight,
          child: SingleChildScrollView(
            controller: sController,
            child: SizedBox(
              height: (mainAxisCount * gridGap).toDouble(),
              child: Stack(
                children: [
                  GridView.count(
                    padding: EdgeInsets.only(
                      left: paddingH,
                      right: paddingH,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: crossAxisCount,
                    children:
                        List.generate(mainAxisCount * crossAxisCount, (index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1,
                            color: Colors.black.withOpacity(.15),
                          ),
                        ),
                      );
                    }),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: paddingH,
                      right: paddingH,
                    ),
                    child: Stack(
                      children: List.generate(
                        seats.length,
                        (index) {
                          return Positioned(
                            left: seats[index].coordinate.dx,
                            top: seats[index].coordinate.dy,
                            child: GestureDetector(
                              onTap: () => bmsSeat(
                                mainContext: context,
                                seat: seats[index],
                                mainIndex: index,
                                mainAxisCount: mainAxisCount,
                                crossAxisCount: crossAxisCount,
                                gridGap: gridGap,
                              ),
                              child: LongPressDraggable(
                                delay: const Duration(milliseconds: 100),
                                onDragEnd: (DraggableDetails details) =>
                                    BlocProvider.of<DragDropCubit>(context)
                                      ..updateSeatPosition(
                                        index: index,
                                        details: details,
                                      ),
                                childWhenDragging:
                                    seat(seat: seats[index], isBordered: false),
                                feedback:
                                    seat(seat: seats[index], isBordered: true),
                                child:
                                    seat(seat: seats[index], isBordered: false),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Stack(
                    children: List.generate(otherSeats.length, (index) {
                      return Positioned(
                        left: otherSeats[index].coordinate.dx,
                        top: otherSeats[index].coordinate.dy,
                        child: LongPressDraggable(
                          delay: const Duration(milliseconds: 100),
                          onDragEnd: (DraggableDetails details) =>
                              BlocProvider.of<DragDropCubit>(context)
                                ..updateWheelPosition(
                                  index: index,
                                  details: details,
                                ),
                          childWhenDragging: wheel(otherSeats[index]),
                          feedback: wheel(otherSeats[index]),
                          child: wheel(otherSeats[index]),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container seat({
    required SeatModel seat,
    required bool isBordered,
  }) {
    return Container(
      height: seat.height,
      width: seat.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: isBordered
            ? Border.all(
                color: seat.isWindowSeat ? Colors.green : Colors.black,
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Image(image: AssetImage(seat.icon))),
          const SizedBox(height: 5),
          Text(
            seat.name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Image door(SeatModel seat) {
    return Image(
      height: seat.height,
      width: seat.width,
      image: AssetImage(seat.icon),
    );
  }

  SizedBox wheel(SeatModel seat) {
    return SizedBox(
      height: seat.height,
      width: (crossAxisCount * gridGap).toDouble() + seat.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image(width: seat.width, image: AssetImage(seat.icon)),
          Image(width: seat.width, image: AssetImage(seat.icon)),
        ],
      ),
    );
  }
}
