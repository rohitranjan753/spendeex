import 'package:flutter/material.dart';
import 'package:spendeex/core/auth_utils.dart';

class SelectFriendsWidget extends StatefulWidget {
  final List<Friend>? initialFriends;
  final List<Friend>? preSelectedFriends;
  final Function(List<Friend>)? onSelectionChanged;
  final bool showAppBar;
  final String? title;
  final Function(List<Friend>)? onBackPressed;
  final Function()? onAddPersonPressed;

  const SelectFriendsWidget({
    Key? key,
    this.initialFriends,
    this.preSelectedFriends,
    this.onSelectionChanged,
    this.showAppBar = true,
    this.title = 'Select Your Friends',
    this.onBackPressed,
    this.onAddPersonPressed,
  }) : super(key: key);

  @override
  SelectFriendsWidgetState createState() => SelectFriendsWidgetState();
}

class SelectFriendsWidgetState extends State<SelectFriendsWidget> {
  List<Friend> selectedFriends = [];
  List<Friend> allFriends = [];
  List<Friend> filteredFriends = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Get current user's email
    final currentUserEmail = AuthUtils.getCurrentUserEmail();

    // Initialize friends list
    List<Friend> initialFriends = widget.initialFriends ?? [];

    // Remove current user from the friends list (users can't select themselves)
    if (currentUserEmail != null) {
      allFriends =
          initialFriends
              .where((friend) => friend.email != currentUserEmail)
              .toList();
    } else {
      allFriends = initialFriends;
    }

    filteredFriends = allFriends;

    // Initialize selected friends
    selectedFriends = widget.preSelectedFriends?.toList() ?? [];

    // Add "You" as the first selected friend if not already present
    if (currentUserEmail != null &&
        !selectedFriends.any((f) => f.email == currentUserEmail)) {
      selectedFriends.insert(
        0,
        Friend(id: '0', name: 'You', avatar: '👤', email: currentUserEmail),
      );
    }
  }

  void toggleFriendSelection(Friend friend) {
    setState(() {
      if (selectedFriends.any((f) => f.email == friend.email)) {
        selectedFriends.removeWhere((f) => f.email == friend.email);
      } else {
        selectedFriends.add(friend);
      }
      // Notify parent widget of selection change
      widget.onSelectionChanged?.call(selectedFriends);
    });
  }

  void removeSelectedFriend(Friend friend) {
    setState(() {
      selectedFriends.removeWhere((f) => f.email == friend.email);
      // Notify parent widget of selection change
      widget.onSelectionChanged?.call(selectedFriends);
    });
  }

  void filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFriends = allFriends;
      } else {
        filteredFriends =
            allFriends
                .where(
                  (friend) =>
                      friend.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  bool isFriendSelected(Friend friend) {
    return selectedFriends.any((f) => f.email == friend.email);
  }

  void addNewFriend(String email, String name) {
    // Don't allow adding the current user as a friend
    final currentUserEmail = AuthUtils.getCurrentUserEmail();
    if (currentUserEmail != null && email == currentUserEmail) {
      return; // Early return if trying to add self
    }

    // Generate a unique ID for the new friend
    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    final newFriend = Friend(
      id: newId,
      name: name,
      avatar: '👤', // Default profile picture
      email: email,
    );

    setState(() {
      // Add to allFriends list if not already present
      if (!allFriends.any((f) => f.email == email)) {
        allFriends.add(newFriend);
        filteredFriends = allFriends;
      }

      // Add to selected friends if not already present
      if (!selectedFriends.any((f) => f.email == email)) {
        selectedFriends.add(newFriend);
        // Notify parent widget of selection change
        widget.onSelectionChanged?.call(selectedFriends);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Friends Section
          if (selectedFriends.isNotEmpty) ...[
            Container(
              height: 170,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send to',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedFriends.length,
                        itemBuilder: (context, index) {
                          Friend friend = selectedFriends[index];
                          final currentUserEmail =
                              AuthUtils.getCurrentUserEmail();
                          bool canRemove =
                              friend.email !=
                              currentUserEmail; // Can't remove current user

                          return Container(
                            margin: EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade200,
                                      ),
                                      child: Center(
                                        child: Text(
                                          friend.avatar,
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                    if (canRemove)
                                      Positioned(
                                        top: -4,
                                        right: -4,
                                        child: GestureDetector(
                                          onTap:
                                              () =>
                                                  removeSelectedFriend(friend),
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade400,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  friend.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // List Contact Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'List Contact',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterFriends,
                      decoration: InputDecoration(
                        hintText: 'Find your friend...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Friends List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredFriends.length,
                    itemBuilder: (context, index) {
                      Friend friend = filteredFriends[index];
                      bool isSelected = isFriendSelected(friend);

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: Center(
                              child: Text(
                                friend.avatar,
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          title: Text(
                            friend.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () => toggleFriendSelection(friend),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    isSelected
                                        ? Colors.blue
                                        : Colors.transparent,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child:
                                  isSelected
                                      ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ),
                          onTap: () => toggleFriendSelection(friend),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print('Selected Friends: $selectedFriends');
                widget.onBackPressed?.call(selectedFriends);
              },
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class Friend {
  final String id;
  final String name;
  final String avatar;
  final String email;

  Friend({
    required this.id,
    required this.name,
    required this.avatar,
    required this.email,
  });
}
