import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spendeex/presentation/screens/category_chip.dart';
import 'package:spendeex/presentation/screens/select_friend.dart';
import 'package:spendeex/data/repositories/user_repository.dart';
import 'package:spendeex/core/auth_utils.dart';

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
  final UserRepository _userRepository = UserRepository();
  final GlobalKey<SelectFriendsWidgetState> _selectFriendsKey =
      GlobalKey<SelectFriendsWidgetState>();

  void _showAddPersonBottomSheet() {
    final TextEditingController emailController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Title
                        Text(
                          'Add Person',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),

                        // Email input
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter email address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.email),
                            errorText: errorMessage,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                        ),
                        SizedBox(height: 20),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                child: Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () async {
                                          final email =
                                              emailController.text.trim();
                                          if (email.isEmpty) {
                                            setModalState(() {
                                              errorMessage =
                                                  'Please enter an email address';
                                            });
                                            return;
                                          }

                                          // Check if user is trying to add their own email
                                          final currentUserEmail =
                                              AuthUtils.getCurrentUserEmail();
                                          if (currentUserEmail != null &&
                                              email == currentUserEmail) {
                                            setModalState(() {
                                              errorMessage =
                                                  'You cannot add yourself as a friend';
                                            });
                                            return;
                                          }

                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(email)) {
                                            setModalState(() {
                                              errorMessage =
                                                  'Please enter a valid email address';
                                            });
                                            return;
                                          }

                                          setModalState(() {
                                            isLoading = true;
                                            errorMessage = null;
                                          });

                                          try {
                                            final existingUser =
                                                await _userRepository
                                                    .getUserByEmail(email);

                                            if (existingUser != null) {
                                              // User already exists - add to selected friends
                                              Navigator.pop(context);
                                              _selectFriendsKey.currentState
                                                  ?.addNewFriend(
                                                    email,
                                                    existingUser['name']
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? existingUser['name']
                                                        : _extractNameFromEmail(
                                                          email,
                                                        ),
                                                  );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'User with email $email added to selection',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } else {
                                              // Create new user
                                              final newUser =
                                                  await _userRepository
                                                      .createUserWithEmail(
                                                        email,
                                                      );
                                              Navigator.pop(context);

                                              // Add the new user to selected friends
                                              _selectFriendsKey.currentState
                                                  ?.addNewFriend(
                                                    email,
                                                    newUser['name']
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? newUser['name']
                                                        : _extractNameFromEmail(
                                                          email,
                                                        ),
                                                  );

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'User with email $email has been added successfully',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            setModalState(() {
                                              errorMessage =
                                                  'Failed to add user. Please try again.';
                                              isLoading = false;
                                            });
                                          }
                                        },
                                child:
                                    isLoading
                                        ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Text('Add User'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    255,
                                    90,
                                    78,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  String _extractNameFromEmail(String email) {
    // Extract name from email by taking the part before @ and capitalizing
    final parts = email.split('@');
    if (parts.isNotEmpty) {
      final name = parts[0].replaceAll('.', ' ').replaceAll('_', ' ');
      return name
          .split(' ')
          .map(
            (word) =>
                word.isNotEmpty
                    ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                    : '',
          )
          .join(' ');
    }
    return 'New User';
  }

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
                _showAddPersonBottomSheet();
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
                key: _selectFriendsKey,
                initialFriends: [...selectedFriendList],
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
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(content: Text('Group created')),
                  //       );
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
