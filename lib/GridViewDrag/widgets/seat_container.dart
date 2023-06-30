import 'package:drag_drop/GridViewDrag/model/seat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/drag_drop_cubit.dart';
import 'bms_seat.dart';

Stack sCList({
  required BuildContext context,
  required double paddingH,
  required int gridGap,
  required double gridTM,
  required double gridBM,
  required ScrollController sController,
  required double gridHeight,
  required int crossAxisCount,
  required int mainAxisCount,
  required List<SeatModel> seats,
}) {
  return Stack(
    children: [
      Padding(
        padding: EdgeInsets.only(left: paddingH),
        child: const Text("Lower Decker"),
      ),
      Container(
        margin: EdgeInsets.only(top: gridTM, bottom: gridBM),
        padding: EdgeInsets.symmetric(horizontal: paddingH),
        width: double.maxFinite,
        height: gridHeight,
        color: Colors.white,
        child: SingleChildScrollView(
          controller: sController,
          child: SizedBox(
            height: (mainAxisCount * gridGap).toDouble(),
            child: Stack(
              children: [
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: crossAxisCount,
                  children:
                      List.generate(mainAxisCount * crossAxisCount, (index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black.withOpacity(.15),
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
                                ..updatePosition(
                                    index: index, details: details),
                          childWhenDragging: seatContainer(
                              seat: seats[index], isBordered: false),
                          feedback: seatContainer(
                              seat: seats[index], isBordered: true),
                          child: seatContainer(
                              seat: seats[index], isBordered: false),
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

Container seatContainer({
  required SeatModel seat,
  required bool isBordered,
}) {
  return Container(
    height: seat.height,
    width: seat.width,
    decoration: BoxDecoration(
      color: seat.isFoldingSeat ? Colors.blue : Colors.white,
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
