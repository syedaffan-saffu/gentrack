import 'package:flutter/material.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  String? selected;
  static const List<String> _names = [
    'Contact No.',
    'Contact Person Name',
    'Client Name',
    'City',
    'Address',
    'Requirement'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lead Generation Form"),
        shadowColor: Colors.transparent,
      ),
      body: Form(
          child: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...List.generate(
                  _names.length,
                  (index) => FormRow(
                      name: _names[index],
                      hint: index == 0 ? '03XXXXXXXXX' : "",
                      length: index == 0 ? 11 : null,
                      inputType: index == 0 ? TextInputType.phone : null)),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 10, bottom: 5),
                child: Text(
                  "Priority",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, height: 2.5, fontSize: 16),
                ),
              ),
              DropdownMenu(
                  enableSearch: false,
                  inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 'low', label: "Low"),
                    DropdownMenuEntry(value: 'high', label: 'High'),
                    DropdownMenuEntry(value: 'medium', label: 'Medium')
                  ])
            ])),
      )),
    );
  }
}

class FormRow extends StatelessWidget {
  final String name;
  final String hint;
  final TextInputType inputType;
  final int? length;
  const FormRow({
    super.key,
    required this.name,
    required this.hint,
    TextInputType? inputType,
    this.length,
  }) : inputType = inputType ?? TextInputType.text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, top: 7, bottom: 3),
          child: Text(
            name,
            style: TextStyle(
                fontWeight: FontWeight.bold, height: 2.5, fontSize: 16),
          ),
        ),
        TextField(
          keyboardType: inputType,
          maxLength: length,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              hintText: hint),
        )
      ],
    );
  }
}
