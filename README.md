# projet_flutter

Projet Dev. Mutli-platforme

## 18 Mars : Setup projet avec firebase

flutter pub add firebase_core
# Install the CLI if not already done so
dart pub global activate flutterfire_cli
# Run the `configure` command, select a Firebase project and platforms
flutterfire configure
# Ajout BD FireStore
flutter pub add cloud_firestore
# Au niveau du code : 
Read / Update en temps réel d'une bdd cloud firestore

Vérifier que la version courante (java -version) de JAVA_HOME est set sur le jdk 11 ( au plus ), sinon modifier le path (  /usr/libexec/java_home -V / export JAVA_HOME="...")

## TODO 
[] Config authentification pour passer la bd en prod
Ajout règles d'éditions à la bd
Google Sign In / Apple Sign In --> suivre guide FlutterFire UI
test push notif
Mettre en place l'architecture principale du projet
Analytics 
Remote Config : mettre à jour l'app sans devoir re dl 
Dynamic links : ouvrir l'app depuis un navigateur
Upload d'images




