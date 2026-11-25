import 'package:clickboard/src/features/documents/repository/document_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Fake do [DocumentRepository] usando Firestore em memória — sem rede.
class FakeDocumentRepository extends DocumentRepository {
  FakeDocumentRepository() : super(firestore: FakeFirebaseFirestore());
}
