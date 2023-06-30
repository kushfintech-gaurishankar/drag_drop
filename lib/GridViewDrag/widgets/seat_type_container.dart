import 'package:drag_drop/GridViewDrag/cubit/drag_drop_cubit.dart';
import 'package:drag_drop/GridViewDrag/model/seat_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Stack sTCList({
  required BuildContext context,
  required int gridGap,
  required int crossAxisCount,
  required double vWidth,
  required double seatTypeH,
  required double paddingH,
  required List<SeatTypeModel> sTypes,
}) {
  return Stack(
    alignment: Alignment.bottomCenter,
    children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: seatTypeH,
        width: double.maxFinite,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(sTypes.length, (index) {
                SeatTypeModel sType = sTypes[index];

                return LongPressDraggable(
                  delay: const Duration(milliseconds: 100),
                  onDragEnd: (DraggableDetails details) =>
                      BlocProvider.of<DragDropCubit>(context).addSeat(
                    sType: sType,
                    details: details,
                  ),
                  childWhenDragging: seatTypeContainer(
                    sType: sType,
                    isBordered: false,
                    height: seatTypeH * .8,
                    width: seatTypeH * .6,
                  ),
                  feedback: seatTypeContainer(
                    sType: sType,
                    isBordered: true,
                    height:
                        (sType.height / vWidth) * (crossAxisCount * gridGap),
                    width: (sType.width / vWidth) * (crossAxisCount * gridGap),
                  ),
                  child: seatTypeContainer(
                    sType: sType,
                    isBordered: false,
                    height: seatTypeH * .8,
                    width: seatTypeH * .6,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0XFF6941C6).withOpacity(.2),
        ),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.screen_rotation_rounded,
            color: Color(0XFF6941C6),
          ),
        ),
      ),
    ],
  );
}

Container seatTypeContainer({
  required SeatTypeModel sType,
  required bool isBordered,
  required double height,
  required double width,
}) {
  return Container(
    height: height,
    width: width,
    margin: const EdgeInsets.only(right: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      border: isBordered
          ? Border.all(
              color: Colors.black,
            )
          : null,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Image(image: AssetImage(sType.icon))),
        const SizedBox(height: 5),
        Text(
          sType.name,
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
