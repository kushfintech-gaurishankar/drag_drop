import 'package:drag_drop/GridViewDrag/cubit/drag_drop_cubit.dart';
import 'package:drag_drop/GridViewDrag/model/seat_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SeatTypeContainer extends StatelessWidget {
  final int crossAxisCount;
  final double paddingH;
  final int gridGap;
  final double vWidth;
  final double height;
  final List<SeatTypeModel> sTypes;

  const SeatTypeContainer({
    super.key,
    required this.crossAxisCount,
    required this.paddingH,
    required this.gridGap,
    required this.vWidth,
    required this.height,
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
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 25,
            ),
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
                      width: seatW,
                      height: seatH,
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
                      isBordered: true,
                      height: seatH,
                      width: seatW,
                    );
                  }

                  return LongPressDraggable(
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
                    childWhenDragging: seatType(sType: sType),
                    feedback: feedback,
                    child: seatType(sType: sType),
                  );
                }),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(1),
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

  Container seatType({
    required SeatTypeModel sType,
    bool isBordered = false,
    double height = double.maxFinite,
    double width = 50,
  }) {
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: isBordered ? Border.all(color: Colors.black) : null,
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

  Image door({
    required SeatTypeModel sType,
    double height = double.maxFinite,
    double width = 50,
  }) {
    return Image(
      height: height,
      width: width,
      image: AssetImage(sType.icon),
    );
  }

  SizedBox wheel({
    required SeatTypeModel sType,
    double height = double.maxFinite,
    double width = 50,
  }) {
    return SizedBox(
      height: height,
      width: (crossAxisCount * gridGap).toDouble() + width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image(width: width, image: AssetImage(sType.icon)),
          Image(width: width, image: AssetImage(sType.icon)),
        ],
      ),
    );
  }
}
