import 'package:drag_drop/GridViewDrag/cubit/drag_drop_cubit.dart';
import 'package:drag_drop/GridViewDrag/model/seat_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/flutter_svg.dart';

class SeatTypeContainer extends StatelessWidget {
  final int crossAxisCount;
  final double paddingH;
  final int gridGap;
  final double vWidth;
  final double height;
  final int angle;
  final List<SeatTypeModel> sTypes;

  final double bM = 12.5;
  final double bP = 18;

  const SeatTypeContainer({
    super.key,
    required this.crossAxisCount,
    required this.paddingH,
    required this.gridGap,
    required this.vWidth,
    required this.height,
    required this.angle,
    required this.sTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: paddingH),
          height: height,
          width: double.maxFinite,
          child: Container(
            margin: EdgeInsets.only(bottom: bM),
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: bP),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(sTypes.length, (index) {
                  SeatTypeModel sType = sTypes[index];
                  double seatH = double.parse(
                      ((sType.height / vWidth) * (crossAxisCount * gridGap))
                          .toStringAsFixed(2));
                  double seatW = double.parse(
                      ((sType.width / vWidth) * (crossAxisCount * gridGap))
                          .toStringAsFixed(2));

                  late Widget feedback;

                  if (sType.name == "Wheel") {
                    feedback = wheel(
                      sType: sType,
                      height: seatH,
                      width: seatW,
                    );
                  } else if (sType.name == "Door") {
                    feedback = door(
                      sType: sType,
                      height: seatH,
                      width: seatW,
                    );
                  } else {
                    feedback = seatType(
                      sType: sType,
                      height: seatH,
                      width: seatW,
                    );
                  }

                  return Row(
                    children: [
                      LongPressDraggable(
                        delay: const Duration(milliseconds: 100),
                        onDragEnd: (DraggableDetails details) {
                          if (sType.name == "Wheel") {
                            BlocProvider.of<DragDropCubit>(context).addWheel(
                              sType: sType,
                              details: details,
                            );
                          } else if (sType.name == "Door") {
                            BlocProvider.of<DragDropCubit>(context).addDoor(
                              sType: sType,
                              details: details,
                            );
                          } else {
                            BlocProvider.of<DragDropCubit>(context).addSeat(
                              sType: sType,
                              details: details,
                            );
                          }
                        },
                        childWhenDragging: seatType(
                          sType: sType,
                          height: height - bM - bP,
                          width: height - bM - bP,
                        ),
                        feedback: feedback,
                        child: seatType(
                          sType: sType,
                          height: height - bM - bP,
                          width: height - bM - bP,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => BlocProvider.of<DragDropCubit>(context).rotate(),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0XFF6941C6).withOpacity(.2),
            ),
            child: angle == 0
                ? const Icon(
                    Icons.refresh_rounded,
                    color: Color(0XFF6941C6),
                    size: 20,
                  )
                : const Icon(
                    Icons.restart_alt_rounded,
                    color: Color(0XFF6941C6),
                    size: 20,
                  ),
          ),
        ),
      ],
    );
  }

  AnimatedRotation seatType({
    required SeatTypeModel sType,
    required double height,
    required double width,
  }) {
    return AnimatedRotation(
      turns: angle == 0 ? 0 : .25,
      duration: const Duration(milliseconds: 500),
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SvgPicture.asset(
                sType.icon,
                height: double.maxFinite,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              sType.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SvgPicture door({
    required SeatTypeModel sType,
    required double height,
    required double width,
  }) {
    return SvgPicture.asset(
      sType.icon,
      width: width,
      height: height,
    );
  }

  SizedBox wheel({
    required SeatTypeModel sType,
    required double height,
    required double width,
  }) {
    return SizedBox(
      height: height,
      width: (crossAxisCount * gridGap).toDouble() + width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(sType.icon, width: width),
          SvgPicture.asset(sType.icon, width: width),
        ],
      ),
    );
  }
}
