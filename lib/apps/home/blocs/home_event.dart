// apps/home/blocs/home_event.dart
part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeFetched extends HomeEvent {
  const HomeFetched();
}

final class HomeRefreshed extends HomeEvent {
  const HomeRefreshed(this.done);
  final Completer<void> done;
}
