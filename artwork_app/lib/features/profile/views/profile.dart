//import 'dart:async';
//import 'dart:html';
//import 'dart:js';
import 'package:artwork_app/common/colors.dart';
import 'package:artwork_app/common/sizes.dart';
import 'package:artwork_app/features/profile/controller/profile_controller.dart';
import 'package:artwork_app/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:appartwork12/lib/common/sizes.dart';


class Profile extends ConsumerWidget{
  const Profile({super.key});

  @override 
  Widget build(BuildContext context,WidgetRef ref){
    return Scaffold( 
      body: SafeArea(
        child: Padding(
          padding: scaffoldPadding,
          child: FutureBuilder<UserModel>(
            future: ref.read(profileControllerProvider).getUser(),
            builder: (context, snapshot){
              if(snapshot.hasData){
                final userModel = snapshot.data!;
              return Align( 
                alignment: Alignment.center,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  Padding(
                   padding:vertical10 ,
                   child:  CircleAvatar( 
                      backgroundColor: profilePhotoCircleColor,
                      radius: 50,
                      child: CircleAvatar( 
                        backgroundColor: profilePhotoCircleColor,
                        radius: 48,
                        backgroundImage:CachedNetworkImageProvider(
                          userModel.profilePhoto!),
                    ),
                  ),
                  ),
                  Padding(
                    padding: vertical10,
                    child: Text( 
                      "@${userModel.username}",
                      style: const TextStyle( 
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      )
                    ),
                    ),
                    Padding(
                    padding: vertical10,
                    child: Text( 
                      "${userModel.name} ${userModel.surname}",
                      style: const TextStyle( 
                        fontSize: 20,
                        color: titleColor,
                      )
                    ),
                    ),

                    MaterialButton(
                      color: profilePhotoCircleColor, 
                      onPressed: () {}, 
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide( 
                          color: borderColor,
                        ),
                      ),
                      minWidth: 200,
                      child: const Padding(
                        padding: vertical10,                    
                        child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: containerColor,
                        ),
                        ),
                      ),
                      ),
                ],
              ),
              );
            }
            else if(snapshot.connectionState==
              ConnectionState.waiting){
              return const Center(child:CircularProgressIndicator(),);
            }
            else {
              return const Center(child: Text("Something went wrong"));
            }


          }),
        ),
      ),
    );
  }
}
