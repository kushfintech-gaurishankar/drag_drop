import 'package:drag_drop/GridViewDrag/model/seat_model.dart';
import 'package:drag_drop/GridViewDrag/model/section_model.dart';
import 'package:drag_drop/GridViewDrag/widgets/edit_section_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../cubit/drag_drop_cubit.dart';
import 'bms_seat.dart';

class GridContainer extends StatelessWidget {
  final ScrollController sController;
  final double gridTM;
  final double paddingH;
  final int gridGap;
  final int crossAxisCount;
  final int mainAxisCount;
  final int angle;
  final List<SectionModel> sections;
  final List<SeatModel> seats;
  final List<SeatModel> wheels;
  final List<SeatModel> doors;

  const GridContainer({
    super.key,
    required this.sController,
    required this.paddingH,
    required this.gridGap,
    required this.gridTM,
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.angle,
    required this.sections,
    required this.seats,
    required this.wheels,
    required this.doors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(sections.length, (index) {
        SectionModel section = sections[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: gridTM,
              padding: EdgeInsets.only(
                left: paddingH,
                right: paddingH,
                bottom: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(section.name, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => editSectionName(
                          context: context,
                          sectionIndex: index,
                          name: section.name,
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
                  if (index != 0)
                    GestureDetector(
                      onTap: () => BlocProvider.of<DragDropCubit>(context)
                        ..deleteSection(index),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(.2),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 15,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: (section.mainAxisCount * gridGap).toDouble(),
              child: Stack(
                children: [
                  GridView.count(
                    padding: EdgeInsets.only(left: paddingH, right: paddingH),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: crossAxisCount,
                    children: List.generate(
                        section.mainAxisCount * crossAxisCount, (index) {
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
                  Stack(
                    children:
                        List.generate(section.wheels.length, (wheelIndex) {
                      SeatModel seat = section.wheels[wheelIndex];
                      return Positioned(
                        left: seat.coordinate.dx,
                        top: seat.coordinate.dy,
                        child: GestureDetector(
                          onTap: () => bmsSeat(
                            mainContext: context,
                            seat: seat,
                            mainIndex: index,
                            seatIndex: wheelIndex,
                            mainAxisCount: mainAxisCount,
                            crossAxisCount: crossAxisCount,
                            gridGap: gridGap,
                            angle: 0,
                          ),
                          child: LongPressDraggable(
                            delay: const Duration(milliseconds: 100),
                            onDragEnd: (DraggableDetails details) =>
                                BlocProvider.of<DragDropCubit>(context)
                                  ..updateWheelPosition(
                                    sectionIndex: index,
                                    wheelIndex: wheelIndex,
                                    details: details,
                                  ),
                            childWhenDragging: wheelContainer(seat),
                            feedback: wheelContainer(seat),
                            child: wheelContainer(seat),
                          ),
                        ),
                      );
                    }),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: paddingH),
                    child: Stack(
                      children: List.generate(
                        sections[index].seats.length,
                        (seatIndex) {
                          SeatModel seatModel = section.seats[seatIndex];
                          return Positioned(
                              left: seatModel.coordinate.dx,
                              top: seatModel.coordinate.dy,
                              child: GestureDetector(
                                onTap: () => bmsSeat(
                                  mainContext: context,
                                  seat: seatModel,
                                  mainIndex: index,
                                  seatIndex: seatIndex,
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
                                          sectionIndex: index,
                                          seatIndex: seatIndex,
                                          details: details,
                                        ),
                                  childWhenDragging: seatContainer(seatModel),
                                  feedback: seatContainer(seatModel),
                                  child: seatContainer(seatModel),
                                ),
                              ));
                        },
                      ),
                    ),
                  ),
                  Stack(
                    children: List.generate(section.doors.length, (doorIndex) {
                      SeatModel seat = section.doors[doorIndex];
                      return Positioned(
                        left: seat.coordinate.dx,
                        top: seat.coordinate.dy,
                        child: GestureDetector(
                          onTap: () => bmsSeat(
                            mainContext: context,
                            seat: seat,
                            mainIndex: index,
                            seatIndex: doorIndex,
                            mainAxisCount: mainAxisCount,
                            crossAxisCount: crossAxisCount,
                            gridGap: gridGap,
                            angle: 0,
                          ),
                          child: LongPressDraggable(
                            delay: const Duration(milliseconds: 100),
                            onDragEnd: (DraggableDetails details) =>
                                BlocProvider.of<DragDropCubit>(context)
                                  ..updateDoorPosition(
                                    sectionIndex: index,
                                    doorIndex: doorIndex,
                                    details: details,
                                  ),
                            childWhenDragging: doorContainer(seat),
                            feedback: doorContainer(seat),
                            child: doorContainer(seat),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  AnimatedRotation seatContainer(SeatModel seat) {
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

  SvgPicture doorContainer(SeatModel seat) {
    return SvgPicture.asset(
      seat.icon,
      height: seat.height,
      width: seat.width,
    );
  }

  SizedBox wheelContainer(SeatModel seat) {
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
