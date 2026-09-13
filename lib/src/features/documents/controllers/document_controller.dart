import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/remote_file_service.dart';
import '../../../core/services/supabase_storage_service.dart';
import '../../../models/document_model.dart';
import '../../../providers/type_defs.dart';
import '../repository/document_repository.dart';

part 'document_controller.g.dart';

const _maxFileSizeBytes = 2 * 1024 * 1024;

@riverpod
Future<void> documentFuture(DocumentFutureRef ref, {bool isRefreshed = false}) {
  return ref
      .watch(documentControllerProvider.notifier)
      .getAllDocuments(isRefreshed: isRefreshed);
}

@Riverpod(keepAlive: true)
class DocumentController extends _$DocumentController {
  final DocumentRepository _documentRepository = DocumentRepository();
  final SupabaseStorageService _storageService = SupabaseStorageService();
  final RemoteFileService _remoteFileService = RemoteFileService();

  @override
  List<Document> build() => [];

  Future<void> getAllDocuments({bool isRefreshed = false}) async {
    if (!isRefreshed && state.isNotEmpty) return;
    state = await _documentRepository.getAllDocuments();
  }

  FutureVoid deleteDocument(Document document) async {
    try {
      if (document.storagePath.isNotEmpty) {
        await _storageService.delete(document.storagePath);
      }
      await _documentRepository.deleteDocument(document);
      await getAllDocuments(isRefreshed: true);
      return right(null);
    } catch (e) {
      return left('Não foi possível excluir o documento "${document.name}"');
    }
  }

  FutureVoid renameDocument(Document document,
      {required String newName}) async {
    try {
      await _documentRepository.renameDocument(document, newName);
      await getAllDocuments(isRefreshed: true);
      return right(null);
    } catch (e) {
      return left('Não foi possível renomear o documento "${document.name}"');
    }
  }

  FutureVoid uploadFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      withData: true,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'docx', 'png'],
    );
    if (result == null) return right(null);

    final oversized = result.files.any((file) => file.size > _maxFileSizeBytes);
    if (oversized) return left('O tamanho máximo do arquivo é 2 MB');

    try {
      for (final file in result.files) {
        if (file.bytes == null) continue;
        await _addDocumentFromFile(file);
      }
      await getAllDocuments(isRefreshed: true);
      return right(null);
    } catch (e) {
      return left('Não foi possível adicionar o(s) documento(s)');
    }
  }

  Future<void> _addDocumentFromFile(PlatformFile file) async {
    final mimeType = lookupMimeType(file.name);
    final storagePath = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final url = await _storageService.upload(
      path: storagePath,
      bytes: file.bytes!,
      contentType: mimeType,
    );
    await _documentRepository.addDocument(
      Document(
        name: file.name,
        url: url,
        storagePath: storagePath,
        size: file.size,
        contentType: mimeType,
      ),
    );
  }

  FutureVoid openDocument(Document document) async {
    if (document.url.isEmpty) {
      return left('Arquivo indisponível para este documento');
    }
    try {
      await _remoteFileService.open(document.url,
          fileName: _downloadFileName(document));
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  FutureEither<String> downloadDocument(Document document) async {
    if (document.url.isEmpty) {
      return left('Arquivo indisponível para este documento');
    }
    try {
      final destination = await _remoteFileService.download(document.url,
          fileName: _downloadFileName(document));
      return right(destination);
    } catch (e) {
      return left(e.toString());
    }
  }

  /// Nome do arquivo para download: usa o nome exibido (renomeado), garantindo
  /// a extensão original guardada em [Document.storagePath].
  String _downloadFileName(Document document) {
    final extension =
        document.storagePath.contains('.') ? document.storagePath.split('.').last : '';
    if (extension.isEmpty ||
        document.name.toLowerCase().endsWith('.${extension.toLowerCase()}')) {
      return document.name;
    }
    return '${document.name}.$extension';
  }
}
