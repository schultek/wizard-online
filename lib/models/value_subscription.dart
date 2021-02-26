import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase/firebase.dart';
import 'package:flutter/foundation.dart';

class ValueSubscription<T> with ChangeNotifier {
  late StreamSubscription subscription;

  DatabaseReference ref;
  T? value;

  ValueSubscription(this.ref, T Function(dynamic data) mapper) {
    subscription = ref.onValue.listen((event) {
      var data = event.snapshot.val();
      value = data != null ? mapper(data) : null;
      notifyListeners();
    });
  }

  Future<void> set(T newValue) async {
    await ref.set(newValue);
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
