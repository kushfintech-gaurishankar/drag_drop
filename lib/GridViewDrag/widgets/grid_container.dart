import 'package:drag_drop/GridViewDrag/model/seat_model.dart';
import 'package:drag_drop/GridViewDrag/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../cubit/drag_drop_cubit.dart';
import 'bms_seat.dart';
import 'dart:math' as math;

class GridContainer extends StatelessWidget {
  final ScrollController sController;
  final String name;
  final double gridHeight;
  final double gridTM;
  final double paddingH;
  final int gridGap;
  final int crossAxisCount;
  final int mainAxisCount;
  final int angle;
  final List<SeatModel> seats;
  final List<SeatModel> wheels;
  final List<SeatModel> doors;

  const GridContainer({
    super.key,
    required this.sController,
    required this.name,
    required this.paddingH,
    required this.gridGap,
    required this.gridTM,
    required this.gridHeight,
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.angle,
    required this.seats,
    required this.wheels,
    required this.doors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: gridHeight + gridTM,
      child: SingleChildScrollView(
        controller: sController,
        child: Column(
          children: [
            Container(
              height: gridTM,
              padding: EdgeInsets.only(
                left: paddingH,
                right: paddingH,
                bottom: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => editName(
                      context: context,
                      name: name,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0XFF6941C6).withOpacity(.2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0XFF6941C6),
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: (mainAxisCount * gridGap).toDouble(),
              child: Stack(
                children: [
                  GridView.count(
                    padding: EdgeInsets.only(left: paddingH, right: paddingH),
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
                    margin: EdgeInsets.symmetric(horizontal: paddingH),
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
                                angle: angle,
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
                                    seat(seat: seats[index], border: false),
                                feedback:
                                    seat(seat: seats[index], border: true),
                                child: seat(seat: seats[index], border: false),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Stack(
                    children: List.generate(wheels.length, (index) {
                      return Positioned(
                        left: wheels[index].coordinate.dx,
                        top: wheels[index].coordinate.dy,
                        child: LongPressDraggable(
                          delay: const Duration(milliseconds: 100),
                          onDragEnd: (DraggableDetails details) =>
                              BlocProvider.of<DragDropCubit>(context)
                                ..updateWheelPosition(
                                  index: index,
                                  details: details,
                                ),
                          childWhenDragging: wheel(wheels[index]),
                          feedback: wheel(wheels[index]),
                          child: wheel(wheels[index]),
                        ),
                      );
                    }),
                  ),
                  Stack(
                    children: List.generate(doors.length, (index) {
                      return Positioned(
                        left: doors[index].coordinate.dx,
                        top: doors[index].coordinate.dy,
                        child: LongPressDraggable(
                          delay: const Duration(milliseconds: 100),
                          onDragEnd: (DraggableDetails details) =>
                              BlocProvider.of<DragDropCubit>(context)
                                ..updateDoorPosition(
                                  index: index,
                                  details: details,
                                ),
                          childWhenDragging: door(doors[index]),
                          feedback: door(doors[index]),
                          child: door(doors[index]),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedRotation seat({required SeatModel seat, required bool border}) {
    return AnimatedRotation(
      turns: angle == 0 ? 0 : .25,
      duration: const Duration(milliseconds: 500),
      child: Container(
        height: seat.height,
        padding: const EdgeInsets.all(5),
        width: seat.width,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SvgPicture.asset(
                seat.icon,
                height: double.maxFinite,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              seat.name,
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

  SvgPicture door(SeatModel seat) {
    return SvgPicture.asset(
      seat.icon,
      height: seat.height,
      width: seat.width,
    );
  }

  SizedBox wheel(SeatModel seat) {
    return SizedBox(
      height: seat.height,
      width: (crossAxisCount * gridGap).toDouble() + seat.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(seat.icon, width: seat.width),
          SvgPicture.asset(seat.icon, width: seat.width),
        ],
      ),
    );
  }
}
