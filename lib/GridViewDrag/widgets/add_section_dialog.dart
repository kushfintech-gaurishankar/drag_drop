import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/drag_drop_cubit.dart';

addSection(BuildContext context) {
  TextEditingController nameC = TextEditingController();

  showDialog(
    context: context,
    builder: (context2) {
      return AlertDialog(
        scrollable: true,
        titlePadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name"),
            const SizedBox(height: 5),
            TextFormField(
              keyboardType: TextInputType.name,
              controller: nameC,
              decoration: const InputDecoration(
                isDense: true,
                hintText: "Enter the section name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  BlocProvider.of<DragDropCubit>(context)
                      .addSection(nameC.text);
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      );
    },
  );
}
