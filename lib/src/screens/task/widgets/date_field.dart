import 'package:attendance_app/src/screens/task/widgets/title_field.dart';
import 'package:flutter/material.dart';

class DataField extends StatelessWidget {
  final int idField;
  final title;
  final Function? onchanged;
  String? valtugas;
  List? listtugas;
  TextEditingController? controller;
  DataField(
      {required this.idField,
      this.title,
      required this.onchanged,
      this.valtugas,
      this.listtugas,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: TitleField(
                textfield: title,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: idField == 1
                ? Container(
                    height: 50.0,
                    width: 210.0,
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[300],
                        border: Border.all(style: BorderStyle.none)),
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      onChanged: onchanged as Function(String)?,
                    ),
                  )
                : idField == 2
                    ? Container(
                        height: 50.0,
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300],
                            border: Border.all(style: BorderStyle.none)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: valtugas as Object,
                            items: listtugas!.map((value) {
                              return DropdownMenuItem(
                                child: Text(value["text"]),
                                value: value["id"],
                              );
                            }).toList(),
                            onChanged: onchanged as void Function(Object?)?,
                          ),
                        ),
                      )
                    : Container(
                        height: 100.0,
                        width: 215.0,
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300],
                            border: Border.all(style: BorderStyle.none)),
                        child: TextFormField(
                          maxLines: 3,
                          controller: controller,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                          onChanged: onchanged as Function(String)?,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
