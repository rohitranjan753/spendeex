import 'package:flutter/material.dart';
import 'package:spendeex/presentation/screens/add_expense_screen.dart';

class GroupDetails extends StatefulWidget {
  final String groupName;

  const GroupDetails({Key? key, required this.groupName}) : super(key: key);

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  int isSelected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          FlutterLogo(),
          Container(
            height: 70,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return FilterChip(
                  onSelected: (bool selected) {
                    setState(() {
                      isSelected = selected ? index : 0;
                    });
                  },
                  label: Text(
                    "Member $index",
                    style: TextStyle(
                      color: isSelected == index ? Colors.white : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Expense $isSelected"),
                  subtitle: Text("₹${(index + 1) * 100} Spent"),
                  trailing: Text("${(index + 1) * 2} Members"),
                  onTap: () {
                    // Handle expense tap
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
        },
        child: Icon(Icons.receipt),
      ),
    );
  }
}
