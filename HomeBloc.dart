import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentors/event/BaseEvent.dart';
import 'package:rentors/event/HomeEvent.dart';
import 'package:rentors/repo/HomeRepo.dart' as homeRepo;
import 'package:rentors/state/BaseState.dart';
import 'package:rentors/state/ErrorState.dart';
import 'package:rentors/state/HomeState.dart';
import 'package:rentors/state/OtpState.dart';

class HomeBloc extends Bloc<BaseEvent, BaseState> {
  @override
  // TODO: implement initialState
  BaseState get initialState => LoadingState();

  @override
  Stream<BaseState> mapEventToState(BaseEvent event) async* {
    if (event is HomeEvent) {
      yield LoadingState();
      try {
        var response = await homeRepo.getHomeData();
        yield HomeState(response);
      } catch (exception) {
        yield ErrorState(exception.toString());
      }
    }
  }
}
