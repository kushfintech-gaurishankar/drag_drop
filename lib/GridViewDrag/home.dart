import 'package:drag_drop/GridViewDrag/cubit/drag_drop_cubit.dart';
import 'package:drag_drop/GridViewDrag/widgets/seat_container.dart';
import 'package:drag_drop/GridViewDrag/widgets/seat_type_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double crossAxisCount;

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (builder) => DragDropCubit(context)
        ..widgetAlignment()
        ..checkSeats(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Builder(builder: (context) {
              return IconButton(
                onPressed: () =>
                    BlocProvider.of<DragDropCubit>(context)..clearData(),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              );
            }),
          ],
        ),
        body: BlocBuilder<DragDropCubit, DragDropState>(
          builder: (context, state) {
            if (state is DragDrop) {
              crossAxisCount = state.crossAxisCount.toDouble();

              return Stack(
                children: [
                  sTCList(
                    context: context,
                    gridGap: state.gridGap,
                    crossAxisCount: state.crossAxisCount,
                    bWidth: state.bWidth,
                    seatTypeS: state.seatTypeS,
                    mAll: state.mAll,
                    sTypes: state.sTypes,
                  ),
                  sCList(
                    context: context,
                    gridGap: state.gridGap,
                    seatTypeS: state.seatTypeS,
                    mAll: state.mAll,
                    mBottom: state.mBottom,
                    sWidth: sWidth,
                    sController: state.sController,
                    gridHeight:
                        (state.gridGap * state.mainAxisCount).toDouble(),
                    crossAxisCount: state.crossAxisCount,
                    mainAxisCount: state.mainAxisCount,
                    gridLength: state.crossAxisCount * state.mainAxisCount,
                    seats: state.seats,
                  ),
                ],
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
