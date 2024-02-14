part of 'firestore_cubit.dart';

final class FirestoreState extends Equatable {
  const FirestoreState({
    this.asyncSnapshot,
    this.lastName,
    this.firstName,
    this.middleName,
  });

  final AsyncSnapshot? asyncSnapshot;
  final String? lastName;
  final String? firstName;
  final String? middleName;

  FirestoreState copyWith({
    AsyncSnapshot? asyncSnapshot,
    String? lastName,
    String? firstName,
    String? middleName,
  }) {
    return FirestoreState(
      asyncSnapshot: asyncSnapshot ?? this.asyncSnapshot,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
    );
  }

  @override
  List<Object?> get props => [
    asyncSnapshot,
    lastName,
    firstName,
    middleName,
  ];
}
