import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.unknown()) {
    on<_AuthStatusChanged>(_onAuthenticationStatusChanged);
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        add(const _AuthStatusChanged(AuthStatus.unauthenticated));
      } else {
        add(const _AuthStatusChanged(AuthStatus.authenticated));
      }
    });
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> _onAuthenticationStatusChanged(
    _AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    try {
      switch (event.status) {
        case AuthStatus.unauthenticated:
          final user = await _trySignInAnonymously();
          return emit(
            user != null
                ? AuthState.authenticated(user)
                : const AuthState.unauthenticated(),
          );
        case AuthStatus.authenticated:
          final user = await _tryGetUser();
          return emit(
            user != null
                ? AuthState.authenticated(user)
                : const AuthState.unauthenticated(),
          );
        case AuthStatus.unknown:
          User? user = await _tryGetUser();
          user ??= await _trySignInAnonymously();
          return emit(
            user != null
                ? AuthState.authenticated(user)
                : const AuthState.unauthenticated(),
          );
      }
    } catch(e) {
      return emit(AuthState.error('Ошибка ${e.toString()}'));
    }
  }

  Future<User?> _trySignInAnonymously() async {
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

  Future<User?> _tryGetUser() async {
    try {
      User? user = auth.currentUser;
      return user;
    } catch (_) {
      return null;
    }
  }
}
