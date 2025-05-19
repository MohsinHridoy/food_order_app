// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final supabase = Supabase.instance.client;
//
//   String? username;
//   String? phone;
//   String? address;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchProfile();
//   }
//
//   Future<void> fetchProfile() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) return;
//
//     try {
//       final response = await supabase
//           .from('profiles')
//           .select('username, phone, address')
//           .eq('id', user.id)
//           .single();
//
//       setState(() {
//         username = response['username'];
//         phone = response['phone'];
//         address = response['address'];
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching profile: $e');
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> logout() async {
//     await supabase.auth.signOut();
//     Navigator.pushReplacementNamed(context, '/');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = supabase.auth.currentUser;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//         actions: [
//           IconButton(
//             onPressed: logout,
//             icon: Icon(Icons.logout),
//           )
//         ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: user == null
//             ? Text('No user logged in.')
//             : Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Welcome!', style: TextStyle(fontSize: 24)),
//             SizedBox(height: 10),
//             Text('Phone: ${user.phone ?? 'N/A'}'),
//             SizedBox(height: 10),
//             Text('Username: ${username ?? 'Not set'}'),
//             Text('Address: ${address ?? 'Not set'}'),
//           ],
//         ),
//       ),
//     );
//   }
// }
