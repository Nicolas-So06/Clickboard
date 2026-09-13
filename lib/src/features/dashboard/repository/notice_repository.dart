import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../models/notice_model.dart';

class NoticeRepository {
  final FirebaseFirestore _firestore;

  NoticeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notices =>
      _firestore.collection(FirebaseConstants.noticesCollection);

  Future<List<Notice>> getAllNotices() async {
    final snapshot = await _notices.get();
    final notices = snapshot.docs.map(Notice.fromSnapshot).toList();
    notices.sort((a, b) => (b.timeCreated ?? DateTime(0))
        .compareTo(a.timeCreated ?? DateTime(0)));
    return notices;
  }
}
