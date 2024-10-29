import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';
import './category_card.dart';

class CategoryList extends StatelessWidget {
  CategoryList({Key? key}) : super(key: key); // Removed const

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .where('type', isEqualTo: 2)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenseData = snapshot.data!.docs;

        return ListView.builder(
          itemCount: expenseData.length,
          itemBuilder: (BuildContext context, int index) {
            return CategoryCard(
                expenseData[index]['name'], // category
                // index
                Color(int.parse(
                    '0x${expenseData[index]['color']}')), // colors list
                0, // percentage value
                expenseData[index]['icon']);
          },
        );
      },
    );
  }
}
