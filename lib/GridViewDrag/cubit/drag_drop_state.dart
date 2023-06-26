part of 'drag_drop_cubit.dart';

abstract class DragDropState extends Equatable {
  const DragDropState();

  @override
  List<Object?> get props => [];
}

class DragDropInitial extends DragDropState {}

class DragDrop extends DragDropState {
  final ScrollController sController;
  final int crossAxisCount;
  final int mainAxisCount;
  final int gridGap;
  final double containerSize;
  final double seatTypeS;
  final double mAll;
  final double mBottom;
  final List<String> seatTypes;
  final List<SeatModel> seats;

  const DragDrop({
    required this.sController,
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.gridGap,
    required this.containerSize,
    required this.seatTypeS,
    required this.mAll,
    required this.mBottom,
    required this.seatTypes,
    required this.seats,
  });

  @override
  List<Object?> get props => [seats];
}
