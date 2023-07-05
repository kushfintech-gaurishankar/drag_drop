import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/drag_drop_cubit.dart';

editName({required BuildContext context, required String name}) {
  TextEditingController nameC = TextEditingController();
  nameC.text = name;

  showDialog(
    context: context,
    builder: (context2) {
      return AlertDialog(
        scrollable: true,
        titlePadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              keyboardType: TextInputType.name,
              controller: nameC,
              decoration: const InputDecoration(
                isDense: true,
                labelText: "Name",
                hintText: "Size in inch",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (name != nameC.text) {
                  BlocProvider.of<DragDropCubit>(context).editName(nameC.text);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      );
    },
  );
}
