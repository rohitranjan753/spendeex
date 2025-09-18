import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/presentation/screens/category_chip.dart';
import 'package:spendeex/presentation/screens/select_friend.dart';
import 'package:spendeex/data/repositories/user_repository.dart';
import 'package:spendeex/core/auth_utils.dart';
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
  final UserRepository _userRepository = UserRepository();
  final GlobalKey<SelectFriendsWidgetState> _selectFriendsKey =
      GlobalKey<SelectFriendsWidgetState>();

  @override
  void dispose() {
    groupTitleController.dispose();
    groupDescriptionController.dispose();
    groupCategoryController.dispose();
    super.dispose();
  }

  void _showAddPersonBottomSheet() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
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
                        Text(
                          'Add Person',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name *',
                            hintText: 'Enter full name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.person),
                          ),
                          textCapitalization: TextCapitalization.words,
                          enabled: !isLoading,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address *',
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
                                          final name =
                                              nameController.text.trim();

                                          if (name.isEmpty) {
                                            setModalState(() {
                                              errorMessage =
                                                  'Please enter a full name';
                                            });
                                            return;
                                          }

                                          if (email.isEmpty) {
                                            setModalState(() {
                                              errorMessage =
                                                  'Please enter an email address';
                                            });
                                            return;
                                          }

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
                                              Navigator.pop(context);
                                              _selectFriendsKey.currentState
                                                  ?.addNewFriend(
                                                    email,
                                                    existingUser['name']
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? existingUser['name']
                                                        : name,
                                                    userId:
                                                        existingUser['uid'], // Pass the actual user ID
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
                                              final newUser =
                                                  await _userRepository
                                                      .createUserWithEmailAndName(
                                                        email,
                                                        name,
                                                      );
                                              Navigator.pop(context);

                                              _selectFriendsKey.currentState
                                                  ?.addNewFriend(
                                                    email,
                                                    name,
                                                    userId:
                                                        newUser['uid'], // Pass the actual user ID from newly created user
                                                  );

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'User "$name" with email $email has been added successfully',
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

  Future<void> _createGroup() async {
    final provider = context.read<CreateGroupProvider>();
    provider.updateTitle(groupTitleController.text);
    provider.updateDescription(groupDescriptionController.text);
    provider.updateCategory(selectedCategory ?? '');
    provider.updateSelectedMembers(selectedFriendList);

    final error = await provider.createGroupWithMembers();

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Group "${groupTitleController.text}" created successfully!',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      provider.reset();
      groupTitleController.clear();
      groupDescriptionController.clear();
      selectedFriendList.clear();
      selectedCategory = null;

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateGroupProvider>(
      builder: (context, provider, child) {
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
            title: Text(firstPage ? 'Create Group' : 'Select Members'),
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
              firstPage ? _buildGroupDetailsPage() : _buildSelectMembersPage(),
          floatingActionButton: _buildFloatingActionButton(provider),
        );
      },
    );
  }

  Widget _buildGroupDetailsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 90, 78),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: groupTitleController,
              decoration: InputDecoration(
                hintText: 'Enter group title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Description (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 90, 78),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: groupDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter group description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 90, 78),
              ),
            ),
            SizedBox(height: 8),
            AlternativeCategoryWidget(
              onCategorySelected: _onCategorySelected,
              selectedCategory: selectedCategory,
            ),
            SizedBox(height: 20),
            if (selectedFriendList.isNotEmpty) ...[
              Text(
                'Selected Members (${selectedFriendList.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 90, 78),
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFriendList.length,
                  itemBuilder: (context, index) {
                    final friend = selectedFriendList[index];
                    return Container(
                      margin: EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blue,
                            child: Text(
                              friend.avatar,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            friend.name.length > 8
                                ? '${friend.name.substring(0, 8)}...'
                                : friend.name,
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectMembersPage() {
    return SelectFriendsWidget(
      key: _selectFriendsKey,
      initialFriends: [...selectedFriendList],
      preSelectedFriends: [...selectedFriendList],
      onBackPressed: (List<Friend> selectedFriends) {
        setState(() {
          selectedFriendList.clear();
          selectedFriendList.addAll(selectedFriends);
          firstPage = true;
        });
        print("Selected Friends Updated ${selectedFriendList[1].id}");
        if (kDebugMode) {
          print('Selected Friends: ${selectedFriendList.toString()}');
        }
      },
    );
  }

  Widget? _buildFloatingActionButton(CreateGroupProvider provider) {
    if (firstPage) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (groupTitleController.text.isNotEmpty && selectedCategory != null)
            FloatingActionButton.extended(
              onPressed: provider.isLoading ? null : _createGroup,
              backgroundColor: const Color.fromARGB(255, 63, 104, 67),
              foregroundColor: Colors.white,
              icon:
                  provider.isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Icon(Icons.save),
              label: Text(provider.isLoading ? 'Creating...' : 'Create Group'),
            ),
          SizedBox(width: 12),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                firstPage = false;
              });
            },
            backgroundColor: const Color.fromARGB(255, 255, 90, 78),
            foregroundColor: Colors.white,
            child: Icon(Icons.arrow_forward_ios),
          ),
        ],
      );
    }
    return null;
  }
}
