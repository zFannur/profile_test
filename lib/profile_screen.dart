import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_test_app/auth_bloc/auth_bloc.dart';
import 'package:profile_test_app/firestore_cubit/firestore_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreCubit = context.read<FirestoreCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Личный кабинет'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, stateAuth) {
          if (stateAuth.status == AuthStatus.authenticated) {
            firestoreCubit.getUserData(stateAuth.user);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocConsumer<FirestoreCubit, FirestoreState>(
                listener: (BuildContext context, FirestoreState state) {
                  final messenger = ScaffoldMessenger.of(context);

                  if (state.asyncSnapshot?.hasData == true) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(state.asyncSnapshot?.data)),
                    );
                  }

                  if (state.asyncSnapshot?.hasError == true) {
                    messenger.showSnackBar(
                      SnackBar(
                          content: Text(state.asyncSnapshot!.error.toString())),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.asyncSnapshot?.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        initialValue: state.lastName,
                        decoration: const InputDecoration(labelText: 'Фамилия'),
                        onChanged: (value) {
                          firestoreCubit.changeLastName(value);
                        },
                      ),
                      TextFormField(
                        initialValue: state.firstName,
                        decoration: const InputDecoration(labelText: 'Имя'),
                        onChanged: (value) {
                          firestoreCubit.changeFirstName(value);
                        },
                      ),
                      TextFormField(
                        initialValue: state.middleName,
                        decoration:
                            const InputDecoration(labelText: 'Отчество'),
                        onChanged: (value) {
                          firestoreCubit.changeMiddleName(value);
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (stateAuth.user != null) {
                            firestoreCubit.saveUserData(stateAuth.user!);
                          }
                        },
                        child: const Text('Сохранить'),
                      ),
                    ],
                  );
                },
              ),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
