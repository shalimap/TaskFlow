import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ThemeCubit extends Cubit<bool> {
  final Box box;

  ThemeCubit(this.box) : super(box.get('isDark') ?? false);

  void toggleTheme() {
    final newValue = !state;
    box.put('isDark', newValue);
    emit(newValue);
  }
}