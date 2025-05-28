import 'package:flutter/material.dart';

class SelectFriendsWidget extends StatefulWidget {
  final List<Friend>? initialFriends;
  final List<Friend>? preSelectedFriends;
  final Function(List<Friend>)? onSelectionChanged;
  final bool showAppBar;
  final String? title;
  final VoidCallback? onBackPressed;

  const SelectFriendsWidget({
    Key? key,
    this.initialFriends,
    this.preSelectedFriends,
    this.onSelectionChanged,
    this.showAppBar = true,
    this.title = 'Select Your Friends',
    this.onBackPressed,
  }) : super(key: key);

  @override
  _SelectFriendsWidgetState createState() => _SelectFriendsWidgetState();
}

class _SelectFriendsWidgetState extends State<SelectFriendsWidget> {
  List<Friend> selectedFriends = [];
  List<Friend> allFriends = [];
  List<Friend> filteredFriends = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Initialize friends list
    allFriends = widget.initialFriends ?? [
      Friend(id: '1', name: 'Alex McKinney', avatar: '👨‍💼'),
      Friend(id: '2', name: 'Eleanor Pena', avatar: '👩‍🦱'),
      Friend(id: '3', name: 'Alecia Johnson', avatar: '👩‍🎓'),
      Friend(id: '4', name: 'Michael Brown', avatar: '👨‍🎨'),
      Friend(id: '5', name: 'Sarah Wilson', avatar: '👩‍💻'),
      Friend(id: '6', name: 'David Martinez', avatar: '👨‍🔬'),
      Friend(id: '7', name: 'Lisa Anderson', avatar: '👩‍🍳'),
      Friend(id: '8', name: 'James Taylor', avatar: '👨‍🎤'),
    ];
    
    filteredFriends = allFriends;
    
    // Initialize selected friends
    selectedFriends = widget.preSelectedFriends?.toList() ?? [];
    
    // Add "You" as the first selected friend if not already present
    if (!selectedFriends.any((f) => f.id == '0')) {
      selectedFriends.insert(0, Friend(id: '0', name: 'You', avatar: '👤'));
    }
  }

  void toggleFriendSelection(Friend friend) {
    setState(() {
      if (selectedFriends.any((f) => f.id == friend.id)) {
        selectedFriends.removeWhere((f) => f.id == friend.id);
      } else {
        selectedFriends.add(friend);
      }
      // Notify parent widget of selection change
      widget.onSelectionChanged?.call(selectedFriends);
    });
  }

  void removeSelectedFriend(Friend friend) {
    setState(() {
      selectedFriends.removeWhere((f) => f.id == friend.id);
      // Notify parent widget of selection change
      widget.onSelectionChanged?.call(selectedFriends);
    });
  }

  void filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFriends = allFriends;
      } else {
        filteredFriends = allFriends
            .where((friend) =>
                friend.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  bool isFriendSelected(Friend friend) {
    return selectedFriends.any((f) => f.id == friend.id);
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
                            bool canRemove = friend.id != '0'; // Can't remove "You"
                            
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
                                            onTap: () => removeSelectedFriend(friend),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
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
                                  color: isSelected 
                                      ? Colors.blue 
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected 
                                        ? Colors.blue 
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
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

  Friend({
    required this.id,
    required this.name,
    required this.avatar,
  });
}
