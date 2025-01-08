part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class LoadAccount extends AccountEvent{}

class AddExpense extends AccountEvent {
  final String email; // Email of the current user
  final String category;
  final String note;
  final double spent;

  const AddExpense(this.email, this.category, this.note, this.spent);

  @override
  List<Object> get props => [email, category, note, spent];
}


class UpdateUser extends AccountEvent {
  final String firstName;
  final String lastName;
  final String income;

  const UpdateUser(this.firstName,
  this.lastName,
  this.income);

 
  @override
  List<Object> get props => [
    firstName,
    lastName,
    income
  ];
}
