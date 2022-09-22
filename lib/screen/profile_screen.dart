import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/screen/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

import '../widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const  ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  @override
  void initState(){
    super.initState();
    getData();
  }
  getData()async{
    setState((){
      isLoading = true;
    });
    try{
    var userSnap =  await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    // get post length
    var postSnap = await FirebaseFirestore.instance.collection('posts').where('uid',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    postLen = postSnap.docs.length;
    userData = userSnap.data()!;
    followers = userSnap.data()!['followers'].length;
    following = userSnap.data()!['following'].length;
    isFollowing = userSnap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
    setState((){

    });
    }catch(e){
      // print(e.toString());
      showSnackBar(e.toString(), context);
    }
    setState((){
      isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return isLoading?const Center(child: CircularProgressIndicator(),):Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: Text(
              userData['username'],
          ),
          centerTitle: false,
        ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        userData['photoUrl']
                      ),
                      radius: 40,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                buildStateColumn(postLen, "posts"),
                                buildStateColumn(followers, "followers"),
                                buildStateColumn(following, "following"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FirebaseAuth.instance.currentUser!.uid==widget.uid?FollowButton(
                                text: 'Sign Out',
                                backgroundColor: mobileBackgroundColor,
                                textColor: primaryColor,
                                borderColor: Colors.grey,
                                function: ()async{
                                  await AuthMethods().signOut();
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> const LoginScreen(),),);
                                },
                              ): isFollowing ? FollowButton(
                                text: 'Unfollwing',
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                borderColor: Colors.grey,
                                function: ()async{
                                  await FireStoreMethods()
                                      .followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userData['uid']);
                                  setState((){
                                    isFollowing = false;
                                    followers--;
                                  });
                                },
                              ): FollowButton(
                                text: 'Follow',
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                borderColor: Colors.blue,
                                function: ()async{
                                  await FireStoreMethods()
                                      .followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userData['uid'],

                                  );
                                  setState((){
                                      isFollowing = true;
                                      followers++;
                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    userData['username'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 1),
                  child: Text(
                    userData['bio'],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder(
            future: FirebaseFirestore.instance.collection('posts').where('uid',isEqualTo: widget.uid).get(),
              builder: (context,snapShot){
              if(snapShot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator(),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                  itemCount: (snapShot.data! as dynamic).docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 1.5,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context,index){

                  DocumentSnapshot snap = (snapShot.data! as dynamic).docs[index];
                  return Container(
                    child: Image(
                      image: NetworkImage(
                        snap['postUrl'],
                      ),
                      fit: BoxFit.cover,
                    ),
                  );
                  },
              );
              }
          ),
        ],
      ),
    );
  }

  Column buildStateColumn(int num, String label){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(num.toString(),
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
           label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }


}
