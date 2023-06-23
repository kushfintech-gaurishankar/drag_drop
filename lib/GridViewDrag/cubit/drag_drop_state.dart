part of 'drag_drop_cubit.dart';

abstract class DragDropState extends Equatable {
  const DragDropState();

  @override
  List<Object?> get props => [];
}

class DragDropInitial extends DragDropState {}

class DragDrop extends DragDropState {
  final int crossAxisCount;
  final int mainAxisCount;
  final int gridGap;
  final double containerSize;
  final double seatTypeS;
  final double pdAll;
  final double pdBottom;
  final List<String> seatTypes;
  final List<SeatModel> seats;

  const DragDrop({
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.gridGap,
    required this.containerSize,
    required this.seatTypeS,
    required this.pdAll,
    required this.pdBottom,
    required this.seatTypes,
    required this.seats,
  });

  @override
  List<Object?> get props => [
        seats,
      ];
}
