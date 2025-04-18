// A full Flutter app in one file with Firebase Auth, Firestore, Navigation Drawer, Message Boards, and Realtime Chat
// Before running this, make sure Firebase is initialized via `flutterfire configure` and you have firebase_options.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Board App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> loginUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: loginUser, child: const Text('Login')),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
            child: const Text("Don't have an account? Register"),
          )
        ]),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  Future<void> registerUser() async {
    try {
      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
        'uid': userCred.user!.uid,
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'role': 'user',
        'registrationDateTime': DateTime.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(children: [
            TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: registerUser, child: const Text('Register')),
          ]),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, dynamic>> hardcodedBoards = const [
    {'name': 'Games', 'icon': Icons.videogame_asset},
    {'name': 'Business', 'icon': Icons.business},
    {'name': 'Public Health', 'icon': Icons.health_and_safety},
    {'name': 'Study', 'icon': Icons.school},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Message Boards")),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: hardcodedBoards.length,
        itemBuilder: (context, index) {
          final board = hardcodedBoards[index];
          return ListTile(
            leading: Icon(board['icon']),
            title: Text(board['name']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(boardId: board['name'], boardName: board['name']),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final String boardId;
  final String boardName;

  const ChatPage({super.key, required this.boardId, required this.boardName});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    void sendMessage() async {
      if (messageController.text.trim().isNotEmpty && user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final displayName = "${userDoc['firstName']} ${userDoc['lastName']}";

        await FirebaseFirestore.instance.collection('messages').add({
          'board': boardId,
          'message': messageController.text.trim(),
          'senderId': user.uid,
          'senderName': displayName,
          'timestamp': DateTime.now(),
        });
        messageController.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(boardName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('board', isEqualTo: boardId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView(
                  children: messages.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['senderName'] ?? 'Unknown'),
                      subtitle: Text(data['message']),
                      trailing: Text(
                        (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: messageController, decoration: const InputDecoration(hintText: 'Enter message'))),
                IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text('Navigation', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Message Boards'),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    firstNameController.text = doc['firstName'];
    lastNameController.text = doc['lastName'];
  }

  Future<void> updateProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
          TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: updateProfile, child: const Text('Update Profile')),
        ]),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Logout'),
            ),
            const SizedBox(height: 20),
            const Text('More settings coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
