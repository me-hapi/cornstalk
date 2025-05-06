import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go('/home');
      },
      child: Scaffold(
      appBar: AppBar(title:const Text("Profile")),
      body: FloatingActionButton(
      child: const Text("Sign out"),  
      onPressed: ()async{
        await Supabase.instance.client.auth.signOut();
        if(mounted){
            context.go('/auth');
        }
      }),
    ));
  }
}