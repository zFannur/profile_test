import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'firestore_state.dart';

class FirestoreCubit extends Cubit<FirestoreState> {
  FirestoreCubit()
      : super(const FirestoreState(
          asyncSnapshot: AsyncSnapshot.nothing(),
        ));

  Future<void> getUserData(User? user) async {
    try {
      emit(state.copyWith(asyncSnapshot: const AsyncSnapshot.waiting()));

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data()!;

          emit(state.copyWith(
            asyncSnapshot: const AsyncSnapshot.withData(
              ConnectionState.done,
              "Данные успешно загружены!",
            ),
            lastName: userData['lastName'],
            firstName: userData['firstName'],
            middleName: userData['middleName'],
          ));
        } else {
          emit(state.copyWith(
            asyncSnapshot: const AsyncSnapshot.withData(
              ConnectionState.done,
              "Данные успешно загружены!",
            ),
          ));
        }
      } else {
        throw 'Пользователь не авторизован';
      }
    } catch (e) {
      emit(state.copyWith(
          asyncSnapshot: AsyncSnapshot.withError(
        ConnectionState.done,
        'Ошибка при загрузке данных: ${e.toString()}',
      )));
    }
  }

  Future<void> saveUserData(User user) async {
    try {
      emit(state.copyWith(asyncSnapshot: const AsyncSnapshot.waiting()));

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'lastName': state.lastName,
        'firstName': state.firstName,
        'middleName': state.middleName,
      });
      emit(state.copyWith(
          asyncSnapshot: const AsyncSnapshot.withData(
        ConnectionState.done,
        "Данные успешно сохранены!",
      )));
    } catch (e) {
      emit(state.copyWith(
          asyncSnapshot: AsyncSnapshot.withError(
        ConnectionState.done,
        'Ошибка при сохранении данных: ${e.toString()}',
      )));
    }
  }

  void changeLastName(String lastName) {
    emit(state.copyWith(
      lastName: lastName,
      asyncSnapshot: const AsyncSnapshot.nothing(),
    ));
  }

  void changeFirstName(String firstName) {
    emit(state.copyWith(
      firstName: firstName,
      asyncSnapshot: const AsyncSnapshot.nothing(),
    ));
  }

  void changeMiddleName(String middleName) {
    emit(state.copyWith(
      middleName: middleName,
      asyncSnapshot: const AsyncSnapshot.nothing(),
    ));
  }
}
