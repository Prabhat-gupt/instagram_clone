import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screen/add_post_screen.dart';
import 'package:instagram_clone/screen/feed_screen.dart';
import 'package:instagram_clone/screen/profile_screen.dart';
import 'package:instagram_clone/screen/search_screen.dart';

const webScreenSize = 600;
 String? str = FirebaseAuth.instance.currentUser!.uid;
 String str1 = "IvySCKnBz6b2vHGgVTcJy8oX3n03";
const homeScreenItems = [

  FeedScreen(),
  SearchScreen(),
  AddPostScreen(),
  Text('notif'),
  ProfileScreen(
    // uid: FirebaseAuth.instance.currentUser!.uid,
    // uid: str1,
    uid: "IvySCKnBz6b2vHGgVTcJy8oX3n03",
  ),
];

