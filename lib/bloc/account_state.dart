part of 'account_bloc.dart';

sealed class AccountState extends Equatable {
  const AccountState();
  
  @override
  List<Object> get props => [];
}

final class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
 
 Map<String, dynamic>account; //return all account info in a list
 Map<String, dynamic> user;

 AccountLoaded({required this.account, required this.user});

   @override
  List<Object> get props => [account,user];
  
}

class UserUpdatedSuccessfully extends AccountState {

}

class ExpenseAddedSuccessfully extends AccountState {
  
}

class AccountError extends AccountState {
  final String error;
  
  const AccountError(this.error);
  
  @override
  List<Object> get props => [error];
}


