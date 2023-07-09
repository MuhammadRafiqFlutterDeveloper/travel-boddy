import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_buddy/constant/fonts.dart';

class LayoutBottomSheet extends StatelessWidget {
  final name;
  final profile;
  final email;
  LayoutBottomSheet(
      { this.name,
         this.profile,
         this.email,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          Divider(
            color: Color(0xff767676).withOpacity(0.40),
            // height: 49,
            indent: 130,
            endIndent: 130,
            thickness: 6,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(profile),

            ),
            title: Text(name, style: postuser,),
            subtitle: Text(email, style: title,),
          )
        ],
      ),
    );
  }
}