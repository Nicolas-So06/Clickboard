import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/utils.dart';

class Student {
  String name, roll, reg, email, uid, session, dept;
  String? pass;

  /// true quando o usuário é da coordenação (definido no doc do Firestore).
  final bool isAdmin;

  Student(
      {required this.name,
      required this.roll,
      required this.reg,
      required this.email,
      this.pass,
      required this.dept,
      required this.session,
      required this.uid,
      this.isAdmin = false});

  /// Getter claro de perfil: só a coordenação pode gerenciar conteúdo oficial.
  bool get isCoordinator => isAdmin;

  static String buildRollFromEmailAndDept(String email, String dept) {
    // E-mails @catolicasc.edu.br não têm matrícula embutida (ao contrário do
    // padrão herdado da JGEC), então retorna valor neutro em vez de inventar.
    if (!_hasEmbeddedRegistration(email)) return 'N/A';
    try {
      String smallRoll = '${email[4]}${email[5]}';
      int smallRollInt = int.parse(smallRoll);
      bool lateral = smallRollInt >= 80;
      int deptCode = departments.indexOf(dept) + 1;
      int session = int.parse('${email[2]}${email[3]}');
      int startingSession = lateral ? session - 3 : session - 4;
      String roll = '${startingSession}10110${deptCode}0$smallRoll';
      return roll;
    } catch (_) {
      // Qualquer e-mail fora do formato esperado não deve travar o app.
      return 'N/A';
    }
  }

  static String buildDeptFromEmail(String email) {
    if (!_hasEmbeddedRegistration(email)) return 'N/A';
    final match = RegExp(r'^[a-zA-Z0-9]*@(cse|ece|it|ee|ce|me).jgec.ac.in$')
        .firstMatch(email);
    if (match == null) return 'N/A';
    return match.group(1)!.toUpperCase();
  }

  static String buildFullSessionFromEmail(String email) {
    if (!_hasEmbeddedRegistration(email)) return 'N/A';
    try {
      int passYear = int.parse('20${email[2]}${email[3]}');
      int startingYear = passYear - 4;
      return '$startingYear-$passYear';
    } catch (_) {
      return 'N/A';
    }
  }

  /// Só o padrão herdado da JGEC carrega departamento/matrícula no próprio
  /// e-mail. Para qualquer outro (incluindo @catolicasc.edu.br) as derivações
  /// devem ser neutras ("N/A"), evitando dados incorretos ou travamentos.
  static bool _hasEmbeddedRegistration(String email) =>
      RegExp(r'^[a-zA-Z0-9]*@(cse|ece|it|ee|ce|me).jgec.ac.in$')
          .hasMatch(email);

  Map<String, String> toJSON() {
    return {
      "Full Name": name,
      "Email": email,
      "Roll Number": roll,
      "Registration Number": reg,
      "uid": uid,
      "Department": dept,
      "session": session,
      // Preserva o perfil real: não rebaixa a coordenação ao editar o perfil.
      "isAdmin": isAdmin ? "true" : "false"
    };
  }

  factory Student.fromEmail(
      {required String name,
      required String email,
      required String pass,
      required String reg,
      required String uid}) {
    String dept = buildDeptFromEmail(email);
    String session = buildFullSessionFromEmail(email);
    String roll = buildRollFromEmailAndDept(email, dept);
    return Student(
        name: name,
        roll: roll,
        reg: reg,
        email: email,
        dept: dept,
        session: session,
        pass: pass,
        uid: uid);
  }
  factory Student.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Student(
        name: data['Full Name'].toString(),
        roll: data['Roll Number'].toString(),
        reg: data['Registration Number'].toString(),
        email: data['Email'].toString(),
        uid: data["uid"].toString(),
        session: data["session"].toString(),
        dept: data["Department"].toString(),
        // Aceita bool (setado na console) ou string "true" (gravado pelo app).
        isAdmin: data["isAdmin"] == true || data["isAdmin"] == "true");
  }
  Student copyWith({
    String? name,
    String? reg,
  }) {
    return Student(
        name: name ?? this.name,
        roll: roll,
        reg: reg ?? this.reg,
        email: email,
        dept: dept,
        session: session,
        uid: uid,
        isAdmin: isAdmin);
  }
}
