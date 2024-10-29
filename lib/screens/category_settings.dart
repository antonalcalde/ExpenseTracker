import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app/constants/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../constants/icons.dart';

class CategorySettings extends StatefulWidget {
  const CategorySettings(
      {super.key, required this.action, required this.type, required this.id});

  final int action; //1 - add, 2 - edit
  final int type; // 1 - income, 2 - expenses
  final String? id;

  @override
  State<CategorySettings> createState() => _CategorySettingsState();
}

class _CategorySettingsState extends State<CategorySettings> {
  final nameController = TextEditingController();

  Color pickerColor = Color(0xff81c784);

  int selectedIcon = 0;

  int selectedDateStability = 1;

  List<int> selectedDotm = [];

  List<String> dotw = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<int> selectedDotw = [];

  List<String> wotm = [
    '1st Week',
    '2nd Week',
    '3rd Week',
    '4th Week',
    '5th Week'
  ];
  List<int> selectedWotm = [];

  List<String> moty = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  List<int> selectedMoty = [];

  int selectedAmtStability = 1;

  final minController = TextEditingController();
  final maxController = TextEditingController();

  List<TextEditingController> amtController = [TextEditingController()];
  List<String> amtNum = [];
  double amtModalHeight = 100;

  String getSelectedDotm() {
    if (selectedDotm.isEmpty) return 'N/A';
    if (selectedDotm.length == 31) return '1-31';
    if (selectedDotm.length <= 3) return selectedDotm.join(', ');
    return '${selectedDotm.first}, ${selectedDotm[1]} ... ${selectedDotm.last}';
  }

  String getSelectedDotw() {
    if (selectedDotw.isEmpty) return 'N/A';
    if (selectedDotw.length == 7) return 'Mon-Sun';
    if (selectedDotw.length <= 3) {
      return selectedDotw
          .map((index) => dotw[index].substring(0, 3))
          .join(', ');
    }
    return '${dotw[selectedDotw[0]].substring(0, 3)}, ${dotw[selectedDotw[1]].substring(0, 3)} ... ${dotw[selectedDotw.last].substring(0, 3)}';
  }

  String getSelectedWotm() {
    if (selectedWotm.isEmpty) return 'N/A';
    if (selectedWotm.length == 5) return '1-5';
    List<String> selectedWeeks =
        selectedWotm.map((index) => (index + 1).toString()).toList();
    if (selectedWotm.length <= 3) {
      return selectedWeeks.join(', ');
    }
    return '${selectedWeeks[0]}, ${selectedWeeks[1]} ... ${selectedWeeks[selectedWeeks.length - 1]}';
  }

  String getSelectedMoty() {
    if (selectedMoty.isEmpty) return 'N/A';
    if (selectedMoty.length == 12) return 'Jan-Dec';
    if (selectedMoty.length == 3) {
      List<String> selectedMonths =
          selectedMoty.map((index) => moty[index]).toList();
      return selectedMonths.join(', ');
    }
    return '${moty[selectedMoty[0]]}, ${moty[selectedMoty[1]]} ... ${moty[selectedMoty.last]}';
  }

  String getSpecifiedAmounts() {
    List<String> enteredAmounts =
        amtController.map((controller) => controller.text).toList();
    enteredAmounts.removeWhere((amount) => amount.isEmpty);

    if (enteredAmounts.isEmpty) {
      return 'N/A';
    }

    if (enteredAmounts.length > 3) {
      return '${enteredAmounts.take(3).join(', ')} ...';
    }

    return enteredAmounts.join(', ');
  }

  void save() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Saving...'),
            ));

    try {
      if (widget.action == 1) {
        await FirebaseFirestore.instance.collection('categories').add({
          'name': nameController.text.trim(),
          'color': pickerColor.toHexString(),
          'icon': selectedIcon,
          'stability_ode': selectedDateStability,
          'dotm': selectedDotm,
          'dotw': selectedDotw,
          'wotm': selectedWotm,
          'moty': selectedMoty,
          'stavility_oae': selectedAmtStability,
          'min_range': minController.text.trim(),
          'max_range': maxController.text.trim(),
          'sepcify_amt': amtNum,
          'created_by': '0',
          'created_at': DateTime.now(),
          'type': widget.type
        });
      } else {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.id)
            .update({
          'name': nameController.text.trim(),
          'color': pickerColor.toHexString(),
          'icon': selectedIcon,
          'stability_ode': selectedDateStability,
          'dotm': selectedDotm,
          'dotw': selectedDotw,
          'wotm': selectedWotm,
          'moty': selectedMoty,
          'stavility_oae': selectedAmtStability,
          'min_range': minController.text.trim(),
          'max_range': maxController.text.trim(),
          'sepcify_amt': amtNum,
          'updated_by': '0',
          'updated_at': DateTime.now(),
        });
      }

      if (mounted) {
        int count = 2;
        Navigator.of(context).popUntil((_) => count-- <= 0);
      }
    } catch (ex) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Oops something went wrong.'),
                ));
      }
    }
  }

  void initializeData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.id)
        .get();

    final data = docSnapshot.data();

    nameController.text = data!['name'];
    pickerColor = Color(int.parse('0x${data['color']}'));
    selectedIcon = data['icon'];
    selectedDateStability = data['stability_ode'];
    selectedDotm = List<int>.from(data['dotm'] ?? []);
    selectedDotw = List<int>.from(data['dotw'] ?? []);
    selectedWotm = List<int>.from(data['wotm'] ?? []);
    selectedMoty = List<int>.from(data['moty'] ?? []);
    selectedAmtStability = data['stavility_oae'];
    minController.text = data['min_range'];
    maxController.text = data['max_range'];
    amtNum = List<String>.from(data['sepcify_amt'] ?? []);
    amtController = amtNum.isNotEmpty
        ? amtNum.map((amt) => TextEditingController(text: amt)).toList()
        : [TextEditingController()];
    amtModalHeight += (50 * amtController.length);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      initializeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.action == 1 ? 'Add Category' : 'Edit Category'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Name'),
                    content: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: 'Category Name'),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Text('Done'))
                    ],
                  ),
                ),
                leading: Text(
                  'Name',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  nameController.text.isEmpty
                      ? 'Category Name 1'
                      : nameController.text,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Color'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HueRingPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (color) =>
                                setState(() => pickerColor = color)),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () => setState(() {
                                Navigator.pop(context);
                              }),
                          child: Text('Done'))
                    ],
                  ),
                ),
                leading: Text(
                  'Color',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: pickerColor,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      '#${pickerColor.value.toRadixString(16).substring(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, setStateDialog) =>
                        AlertDialog(
                      title: Text('Icon'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 200,
                            width: double.maxFinite,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                              itemCount: icons.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () => setStateDialog(() {
                                    selectedIcon = index;
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedIcon == index
                                          ? Colors.green[300]
                                          : Colors.transparent,
                                      border: Border.all(
                                          color: Colors.green, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      icons.entries.elementAt(index).value,
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => Navigator.pop(context)),
                          child: Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Text(
                  'Icon',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Icon(getIcon(selectedIcon)),
              ),
              ListTile(
                leading: Text(
                  'Recurrence of Dates',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  '',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, setStateDialog) =>
                        AlertDialog(
                      title: Text('Stability of Date Entries'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => setStateDialog(() {
                              selectedDateStability = 1;
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedDateStability == 1
                                    ? Colors.green[300]
                                    : Colors.transparent,
                                border:
                                    Border.all(color: Colors.green, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              width: double.maxFinite,
                              child: Text('Stable'),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          InkWell(
                            onTap: () => setStateDialog(() {
                              selectedDateStability = 0;
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedDateStability == 0
                                    ? Colors.green[300]
                                    : Colors.transparent,
                                border:
                                    Border.all(color: Colors.green, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              width: double.maxFinite,
                              child: Text('Unstable'),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                            child: Text('Done'))
                      ],
                    ),
                  ),
                ),
                leading: Text(
                  'Stability of Date Entries',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  selectedDateStability == 1 ? '<Stable>' : '<Unstable>',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, setStateDialog) =>
                        AlertDialog(
                      title: Text('Day/s of the Month'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 300,
                            width: double.maxFinite,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                              ),
                              itemCount: 31,
                              itemBuilder: (BuildContext context, int index) {
                                int day = index + 1; // Adjust index to 1-based
                                return InkWell(
                                  onTap: () => setStateDialog(() {
                                    selectedDotm.contains(day)
                                        ? selectedDotm.remove(day)
                                        : selectedDotm.add(day);

                                    selectedDotm.sort();
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedDotm.contains(day)
                                          ? Colors.green[300]
                                          : Colors.transparent,
                                      border: Border.all(
                                          color: Colors.green, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: Text(
                                      day.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setStateDialog(() {
                                if (selectedDotm.length == 31) {
                                  selectedDotm.clear();
                                } else {
                                  selectedDotm =
                                      List.generate(31, (index) => index + 1);
                                }
                              });
                            },
                            child: Text(selectedDotm.length == 31
                                ? 'Clear'
                                : 'Select All'),
                          )
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Text(
                  'Day/s of the Month',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  getSelectedDotm(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, setStateDialog) =>
                        AlertDialog(
                      title: Text('Day/s of the Week'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 425,
                            width: double.maxFinite,
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 12,
                              ),
                              itemCount: dotw.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () => setStateDialog(() {
                                    selectedDotw.contains(index)
                                        ? selectedDotw.remove(index)
                                        : selectedDotw.add(index);

                                    selectedDotw.sort();
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedDotw.contains(index)
                                          ? Colors.green[300]
                                          : Colors.transparent,
                                      border: Border.all(
                                          color: Colors.green, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(12),
                                    width: double.maxFinite,
                                    child: Text(dotw[index]),
                                  ),
                                );
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setStateDialog(() {
                                if (selectedDotw.length == 7) {
                                  selectedDotw.clear();
                                } else {
                                  selectedDotw =
                                      List.generate(7, (index) => index);
                                }
                              });
                            },
                            child: Text(selectedDotw.length == 7
                                ? 'Clear'
                                : 'Select All'),
                          )
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => Navigator.pop(context)),
                          child: Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Text(
                  'Day/s of the Week',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  getSelectedDotw(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, setStateDialog) =>
                        AlertDialog(
                      title: Text('Week/s of the Month'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 300,
                            width: double.maxFinite,
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 12,
                              ),
                              itemCount: wotm.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () => setStateDialog(() {
                                    if (selectedWotm.contains(index)) {
                                      selectedWotm.remove(index);
                                    } else {
                                      selectedWotm.add(index);
                                    }
                                    selectedWotm
                                        .sort(); // Ensure correct order after every tap
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedWotm.contains(index)
                                          ? Colors.green[300]
                                          : Colors.transparent,
                                      border: Border.all(
                                          color: Colors.green, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(12),
                                    width: double.maxFinite,
                                    child: Text(wotm.elementAt(index)),
                                  ),
                                );
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setStateDialog(() {
                                if (selectedWotm.length == 5) {
                                  selectedWotm.clear();
                                } else {
                                  selectedWotm =
                                      List.generate(5, (index) => index);
                                }
                              });
                            },
                            child: Text(selectedWotm.length == 5
                                ? 'Clear'
                                : 'Select All'),
                          )
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => Navigator.pop(context)),
                          child: Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Text(
                  'Week/s of the Month',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  getSelectedWotm(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, setStateDialog) =>
                        AlertDialog(
                      title: Text('Month/s of the Year'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 300,
                            width: double.maxFinite,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 40,
                              ),
                              itemCount: moty.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () => setStateDialog(() {
                                    if (selectedMoty.contains(index)) {
                                      selectedMoty.remove(index);
                                    } else {
                                      selectedMoty.add(index);
                                    }
                                    selectedMoty
                                        .sort(); // Ensure correct order of selected months
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedMoty.contains(index)
                                          ? Colors.green[300]
                                          : Colors.transparent,
                                      border: Border.all(
                                          color: Colors.green, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: Text(
                                      moty.elementAt(index),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setStateDialog(() {
                                if (selectedMoty.length == 12) {
                                  selectedMoty.clear();
                                } else {
                                  selectedMoty =
                                      List.generate(12, (index) => index);
                                }
                              });
                            },
                            child: Text(selectedMoty.length == 12
                                ? 'Clear'
                                : 'Select All'),
                          )
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => Navigator.pop(context)),
                          child: Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Text(
                  'Month/s of the Year',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  getSelectedMoty(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                leading: Text(
                  'Pattern of Amounts',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  '',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, setStateDialog) =>
                        AlertDialog(
                      title: Text('Stability of Amount Entries'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => setStateDialog(() {
                              selectedAmtStability = 1;
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedAmtStability == 1
                                    ? Colors.green[300]
                                    : Colors.transparent,
                                border:
                                    Border.all(color: Colors.green, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              width: double.maxFinite,
                              child: Text('Stable'),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          InkWell(
                            onTap: () => setStateDialog(() {
                              selectedAmtStability = 0;
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedAmtStability == 0
                                    ? Colors.green[300]
                                    : Colors.transparent,
                                border:
                                    Border.all(color: Colors.green, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              width: double.maxFinite,
                              child: Text('Unstable'),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () =>
                                setState(() => Navigator.pop(context)),
                            child: Text('Done'))
                      ],
                    ),
                  ),
                ),
                leading: Text(
                  'Stability of Amount Entries',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  selectedAmtStability == 0 ? '<Unstable>' : '<Stable>',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                  onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Amount Range'),
                          content: SizedBox(
                            height: 100,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: minController,
                                  decoration: InputDecoration(hintText: 'Min'),
                                  keyboardType: TextInputType.number,
                                ),
                                TextFormField(
                                  controller: maxController,
                                  decoration: InputDecoration(hintText: 'Max'),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () =>
                                    setState(() => Navigator.pop(context)),
                                child: Text('Done'))
                          ],
                        ),
                      ),
                  leading: Text(
                    'Amount Range',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    '${minController.text.isEmpty ? '0' : minController.text}-${maxController.text.isEmpty ? '0' : maxController.text}',
                    style: TextStyle(fontSize: 16),
                  )),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, setStateDialog) =>
                        AlertDialog(
                      title: Text('Specify Amount/s'),
                      content: SizedBox(
                        height: amtModalHeight,
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemCount: amtController.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return TextFormField(
                                    controller: amtController[
                                        index], // Use correct controller
                                    decoration: InputDecoration(
                                      hintText: 'Amount ${index + 1}',
                                      suffixIcon: IconButton(
                                        onPressed: () => setStateDialog(() {
                                          if (amtController.length > 1) {
                                            amtController[index].dispose();
                                            amtController.removeAt(index);
                                            amtModalHeight -=
                                                60; // Adjust modal height
                                          }
                                        }),
                                        icon: Icon(Icons.remove_circle_outline),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  );
                                },
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setStateDialog(() {
                                  amtModalHeight +=
                                      60; // Increase modal height for new input
                                  amtController.add(
                                      TextEditingController()); // Add new controller
                                });
                              },
                              child: Text('Add More'),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Filter out any empty or blank text from controllers
                              amtNum = amtController
                                  .map((controller) => controller.text)
                                  .where((value) => value.trim().isNotEmpty)
                                  .toList();
                              Navigator.pop(context);
                            });
                          },
                          child: Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Text(
                  'Specify Amount/s',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  getSpecifiedAmounts(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(onPressed: () => save(), child: Text('Save'))
            ],
          ),
        ),
      ),
    );
  }
}
