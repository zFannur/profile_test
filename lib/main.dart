import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Включение анонимной авторизации
  await FirebaseAuth.instance.signInAnonymously();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProfilePage(),
    );
  }
}


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<User?> _auth() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          throw "Anonymous auth hasn't been enabled for this project.";
        default:
          throw "Unknown error.";
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      user ??= await _auth();

      if (user != null) {
        // Получение данных пользователя из Firestore
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data()!;
          // Обновление данных на форме или хранение данных в переменных
          _lastNameController.text = userData['lastName'];
          _firstNameController.text = userData['firstName'];
          _middleNameController.text = userData['middleName'];

        } else {
          //Данные пользователя не найдены в Firestore
        }
      } else {
        //Не авторизован
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке данных: $e')),
      );
    }
  }

  Future<void> _saveUserData() async {
    try {
      // Получение текущего пользователя
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Сохранение данных пользователя в Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'lastName': _lastNameController.text,
          'firstName': _firstNameController.text,
          'middleName': _middleNameController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные успешно сохранены!')),
        );
      } else {
        // Обработка случая, когда пользователь не аутентифицирован
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении данных: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Личный кабинет'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Фамилия'),
            ),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Имя'),
            ),
            TextFormField(
              controller: _middleNameController,
              decoration: const InputDecoration(labelText: 'Отчество'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveUserData,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}