import 'package:drag_drop/GridViewDrag/model/seat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/drag_drop_cubit.dart';
import 'bottom_modal_sheet.dart';

Container sCList({
  required BuildContext context,
  required int gridGap,
  required double seatTypeS,
  required double mAll,
  required double mBottom,
  required double sWidth,
  required ScrollController sController,
  required double gridHeight,
  required int crossAxisCount,
  required int mainAxisCount,
  required int gridLength,
  required List<SeatModel> seats,
}) {
  return Container(
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
                            ..updatePosition(index: index, details: details),
                      childWhenDragging: seatContainer(seats[index]),
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
  );
}

Container seatContainer(SeatModel seat) {
  return Container(
    height: seat.height,
    width: seat.width,
    decoration: BoxDecoration(
      color: seat.isFoldingSeat ? Colors.blue : Colors.white,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: seat.isWindowSeat ? Colors.green : Colors.black,
      ),
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
