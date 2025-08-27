import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/presentation/screens/category_chip.dart';
import 'package:spendeex/presentation/screens/select_friend.dart';
import 'package:spendeex/providers/create_group_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  String? selectedCategory;
  bool firstPage = true;
  TextEditingController groupTitleController = TextEditingController();
  TextEditingController groupDescriptionController = TextEditingController();
  TextEditingController groupCategoryController = TextEditingController();
  final List<Friend> selectedFriendList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (firstPage) {
              Navigator.pop(context);
            } else {
              setState(() {
                firstPage = !firstPage;
              });
            }
          },
          icon: Icon(Icons.arrow_circle_left_sharp),
        ),
        title: firstPage ? Text('Create Group') : Text('Select friend'),
        actions: [
          if (!firstPage)
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () {
                if (!firstPage) {
                  setState(() {
                    firstPage = !firstPage;
                  });
                  return;
                }
                Navigator.pop(context);
              },
            ),
        ],
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
                        controller: groupTitleController,
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
                        controller: groupDescriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      AlternativeCategoryWidget(),
                      // Calenda
                    ],
                  ),
                ),
              )
              : SelectFriendsWidget(
                preSelectedFriends: [...selectedFriendList],
                onBackPressed: (List<Friend> selectedFriends) {
                  selectedFriendList.clear();
                  selectedFriendList.addAll(selectedFriends);
                  if (kDebugMode) {
                    print('Selected Friends: $selectedFriendList');
                  }
                  setState(() {
                    firstPage = !firstPage;
                  });
                },
              ),
      floatingActionButton:
          firstPage
              ? Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   onPressed: () async {
          //     final provider = context.read<CreateGroupProvider>();
          //     provider.updateGroupDetails(
          //       groupTitleController.text,
          //       groupDescriptionController.text,
          //     );

          //     final error = await provider.createGroup();
          //     if (error != null) {
          //       ScaffoldMessenger.of(
          //         context,
          //       ).showSnackBar(SnackBar(content: Text(error)));
          //     } else {
          //       ScaffoldMessenger.of(
          //         context,
          //       ).showSnackBar(SnackBar(content: Text('Group created')));
          //       groupTitleController.clear();
          //       groupDescriptionController.clear();
          //       setState(() => selectedCategory = null);
          //     }
          //   },
          //   child: Icon(Icons.save),
          //   backgroundColor: const Color.fromARGB(255, 63, 104, 67),
          // ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                firstPage = !firstPage;
              });
            },
            child:
                
                    Icon(Icons.arrow_forward_ios),
            backgroundColor: const Color.fromARGB(255, 255, 90, 78),
          ),
        ],
              )
              : null,
    );
  }
}
