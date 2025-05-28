import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spendeex/presentation/screens/category_chip.dart';
import 'package:spendeex/presentation/screens/select_friend.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  String? selectedCategory;
  bool firstPage = false;

  final List<CategoryItem> categories = [
    CategoryItem(title: 'Trip', emoji: '✈️'),
    CategoryItem(title: 'Family', emoji: '👨‍👩‍👧‍👦'),
    CategoryItem(title: 'Couple', emoji: '👫'),
    CategoryItem(title: 'Event', emoji: '🎂'),
    CategoryItem(title: 'Project', emoji: '🏢'),
    CategoryItem(title: 'Other', emoji: '🍀'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: firstPage ? Text('Create Group') : Text('Select friend'),
        actions: [IconButton(icon: Icon(Icons.person_add), onPressed: () {})],
      ),

      body:
          firstPage
              ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Title(
                        color: const Color.fromARGB(255, 255, 90, 78),
                        child: Text('Title'),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Title(
                        color: const Color.fromARGB(255, 255, 90, 78),
                        child: Text('Description'),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Title(
                        color: const Color.fromARGB(255, 255, 90, 78),
                        child: Text('Title'),
                      ),
                      Title(color: Colors.red, child: Text('Category')),
                      AlternativeCategoryWidget(),
                      // Calenda
                    ],
                  ),
                ),
              )
              : SelectFriendsWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            firstPage = !firstPage;
          });
        },
        child:
            firstPage
                ? Icon(Icons.arrow_forward_ios)
                : Icon(Icons.arrow_back_ios),
        backgroundColor: const Color.fromARGB(255, 255, 90, 78),
      ),
    );
  }
}
