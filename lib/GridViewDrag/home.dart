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
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (builder) => DragDropCubit(context)
        ..widgetAlignment()
        ..checkSeats(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2F4F7),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          actions: [
            Builder(builder: (context) {
              return IconButton(
                onPressed: () =>
                    BlocProvider.of<DragDropCubit>(context)..clearData(),
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
              );
            }),
          ],
        ),
        body: BlocBuilder<DragDropCubit, DragDropState>(
          builder: (context, state) {
            if (state is DragDrop) {
              return Column(
                children: [
                  sTCList(
                    context: context,
                    gridGap: state.gridGap,
                    crossAxisCount: state.crossAxisCount,
                    vWidth: state.vWidth,
                    seatTypeH: state.seatTypeH,
                    paddingH: state.paddingH,
                    sTypes: state.sTypes,
                  ),
                  sCList(
                    context: context,
                    paddingH: state.paddingH,
                    gridGap: state.gridGap,
                    gridTM: state.gridTM,
                    gridBM: state.gridBM,
                    sController: state.sController,
                    gridHeight: state.gridHeight,
                    crossAxisCount: state.crossAxisCount,
                    mainAxisCount: state.mainAxisCount,
                    seats: state.seats,
                  ),
                  SizedBox(
                    height: state.buttonH,
                    width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF6941C6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text("Save Draft"),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF6941C6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text("Next"),
                        )
                      ],
                    ),
                  )
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
