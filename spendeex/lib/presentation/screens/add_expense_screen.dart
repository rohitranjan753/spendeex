import 'package:flutter/material.dart';
import 'package:spendeex/presentation/screens/category_chip.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  int length = 1;
  List<String> categories = [
   "Equally",
   "Unequally",
   "By Percentage",
   "By shares",
   "By adjustment",
  ];
  int highlightedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bill Name'),
            
            TextField(
              decoration: InputDecoration(
                hintText: "Enter bill name",
                border: OutlineInputBorder(),
              ),
            ),
            AlternativeCategoryWidget(),
            Text("Split With"),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  if (index == 3) {
                    return IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add_circle),
                    );
                  } else {
                    return CircleAvatar(radius: 30);
                  }
                },
              ),
            ),
            Text("Add Items"),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                spacing: 40,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: length,
                    itemBuilder: (context, index) {
                      return ListItem();
                    },
                  ),
                  ElevatedButton(onPressed: () {
                      setState(() {
                        length++;
                      });
                    }, child: Text("Add New Item")),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // show bottomsheet to select split type
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context,index){
                      return InkWell(
                        onTap: (){
                          setState(() {
                            highlightedIndex = index;
                          });
                          // Handle category selection
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                            color: highlightedIndex == index ? Colors.blue : Colors.white,
                          ),
                          padding: EdgeInsets.all(10),
                          child: Text(categories[index],),
                        ),
                      );
                    }),
                    ),
                    Expanded(child: ListView.builder(
                      itemCount: 15,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: FlutterLogo(),
                          trailing: Icon(Icons.remove),
                          onTap: () {
                            // Handle split type selection
                            Navigator.pop(context);
                          },
                        );
                      }
                    )),
                  ],
                ),
              );
            },
          );
        },
        child: Text("Split By:"),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Item 1"), Text("Add image")],
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter item name",
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter item amount",
              border: OutlineInputBorder(),
            ),
          ),
          
        ],
      ),
    );
  }
}
