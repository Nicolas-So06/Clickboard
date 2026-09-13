import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/utils.dart';
import '../../../models/document_model.dart';
import '../../../providers/type_defs.dart';
import '../repository/document_repository.dart';

part 'document_controller.g.dart';

@riverpod
Future<void> documentFuture(DocumentFutureRef ref, {bool isRefreshed = false}) {
  return ref
      .watch(documentControllerProvider.notifier)
      .getAllDocuments(isRefreshed: isRefreshed);
}

@Riverpod(keepAlive: true)
class DocumentController extends _$DocumentController {
  final DocumentRepository _documentRepository = DocumentRepository();

  @override
  List<Document> build() => [];

  Future<void> getAllDocuments({bool isRefreshed = false}) async {
    if (!isRefreshed && state.isNotEmpty) return;
    state = await _documentRepository.getAllDocuments();
  }

  FutureVoid deleteDocument(Document document) async {
    try {
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
    String? message;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'docx', 'png'],
    );
    if (result == null) return right(null);

    final files = result.files.where((file) {
      if (file.size > 2048 * 1024) {
        message = 'O tamanho máximo do arquivo é 2 MB';
        return false;
      }
      return true;
    }).toList();
    if (files.isEmpty) return left(message ?? 'Nenhum arquivo selecionado');

    try {
      for (final file in files) {
        await _documentRepository.addDocument(
          Document(
            name: file.name,
            size: file.size,
            contentType: file.extension,
          ),
        );
      }
      await getAllDocuments(isRefreshed: true);
      return right(null);
    } catch (e) {
      return left('Não foi possível adicionar o(s) documento(s)');
    }
  }

  FutureEither<String> saveDocumentFile(Document document) async {
    if (document.url.isEmpty) {
      return left('Arquivo indisponível para este documento');
    }
    try {
      final tempDir = (await getTemporaryDirectory()).path;
      final file = File('$tempDir/${document.name}');
      final response = await http.get(Uri.parse(document.url));
      await file.writeAsBytes(response.bodyBytes);
      return right(file.path);
    } catch (e) {
      return left(e.toString());
    }
  }

  FutureEither<String> downloadDocument(Document document) async {
    if (document.url.isEmpty) {
      return left('Arquivo indisponível para este documento');
    }
    try {
      final downloadPath = (await getDownloadPath())!;
      final file = File('$downloadPath/${document.name}');
      if (await Permission.manageExternalStorage.request().isGranted) {
        final response = await http.get(Uri.parse(document.url));
        await file.writeAsBytes(response.bodyBytes);
        return right(downloadPath);
      }
    } catch (e) {
      return left(e.toString());
    }
    return left('Aceite as permissões de arquivo para baixar');
  }
}
