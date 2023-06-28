import 'package:drag_drop/GridViewDrag/cubit/drag_drop_cubit.dart';
import 'package:drag_drop/GridViewDrag/model/seat_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/coordinate_model.dart';
import '../model/seat_model.dart';

Container sTCList({
  required BuildContext context,
  required int gridGap,
  required double seatTypeS,
  required double mAll,
  required List<SeatTypeModel> sTypes,
}) {
  return Container(
    padding: EdgeInsets.all(mAll),
    height: seatTypeS,
    width: double.maxFinite,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(sTypes.length, (index) {
          SeatTypeModel sType = sTypes[index];

          return LongPressDraggable(
            delay: const Duration(milliseconds: 100),
            onDragEnd: (DraggableDetails details) {
              SeatModel s = SeatModel(
                name: sType.name,
                isWindowSeat: false,
                isFoldingSeat: false,
                isReadingLights: false,
                height: (sType.hTimes * gridGap).toDouble(),
                width: (sType.wTimes * gridGap).toDouble(),
                coordinate: const CoordinateModel(
                  dx: 0,
                  dy: 0,
                ),
              );

              BlocProvider.of<DragDropCubit>(context).addWidget(
                seat: s,
                details: details,
              );
            },
            childWhenDragging: seatTypeContainer(
              name: sType.name,
              height: (sType.hTimes * gridGap).toDouble(),
              width: (sType.wTimes * gridGap).toDouble(),
            ),
            feedback: seatTypeContainer(
              name: sType.name,
              height: (sType.hTimes * gridGap).toDouble(),
              width: (sType.wTimes * gridGap).toDouble(),
            ),
            child: seatTypeContainer(
              name: sType.name,
              height: (sType.hTimes * gridGap).toDouble(),
              width: (sType.wTimes * gridGap).toDouble(),
            ),
          );
        }),
      ),
    ),
  );
}

Container seatTypeContainer({
  required String name,
  required double height,
  required double width,
}) {
  return Container(
    height: height,
    width: width,
    margin: const EdgeInsets.only(right: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
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
