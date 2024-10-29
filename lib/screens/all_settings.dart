import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app/constants/functions.dart';
import 'package:expense_app/screens/category_settings.dart';
import 'package:flutter/material.dart';

class AllSettings extends StatelessWidget {
  const AllSettings({super.key, required this.type});

  // 1 - income, 2 - expenses
  final int type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type == 1 ? 'All Incomes' : 'All Expenses'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CategorySettings(
                        action: 1,
                        type: type,
                        id: null,
                      ))),
              icon: Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .where('type', isEqualTo: type)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final settingData = snapshot.data!.docs;

                return Expanded(
                  child: ListView.builder(
                    itemCount: settingData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Color(
                                int.parse('0x${settingData[index]['color']}')),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(getIcon(settingData[index]['icon'])),
                        ),
                        title: Text(settingData[index]['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CategorySettings(
                                          action: 2,
                                          type: type,
                                          id: settingData[index].id,
                                        ),
                                      ),
                                    ),
                                icon: Icon(Icons.edit)),
                            const SizedBox(
                              width: 12,
                            ),
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text('Are you sure?'),
                                            content: Text(
                                                'this will delete the category.'),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('Cancel')),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            'categories')
                                                        .doc(settingData[index]
                                                            .id)
                                                        .delete()
                                                        .then((value) =>
                                                            Navigator.pop(
                                                                context));
                                                  },
                                                  child: Text('Yes'))
                                            ],
                                          ));
                                },
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ))
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }
}
