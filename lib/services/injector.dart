

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import 'authentication.dart';


final injector = GetIt.instance;

void registerDependencies() {
  _registerManagers();
  _registerDependencies();
}


void _registerManagers() {
  injector.registerLazySingleton<FirebaseAuth>(() {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return firebaseAuth;
  });
  injector.registerLazySingleton<BaseAuth>(() {
    return Auth(injector.get());
  });

}

void _registerDependencies() {
  injector.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging());
  //injector.registerLazySingleton<Geolocator>(() => Geolocator());
}
