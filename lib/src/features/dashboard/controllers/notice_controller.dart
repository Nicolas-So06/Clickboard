import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/utils.dart';
import '../../../models/notice_model.dart';
import '../../../providers/type_defs.dart';
import '../repository/notice_repository.dart';

part 'notice_controller.g.dart';

@riverpod
Future<void> noticeFuture(NoticeFutureRef ref, {bool isRefreshed = false}) {
  return ref
      .watch(noticeControllerProvider.notifier)
      .getAllNotices(isRefreshed: isRefreshed);
}

@Riverpod(keepAlive: true)
class NoticeController extends _$NoticeController {
  final NoticeRepository _noticeRepository = NoticeRepository();

  @override
  List<Notice> build() => [];

  Future<void> getAllNotices({bool isRefreshed = false}) async {
    if (!isRefreshed && state.isNotEmpty) return;
    state = await _noticeRepository.getAllNotices();
  }

  FutureEither<String> saveNoticeFile(Notice notice) async {
    if (notice.downloadUrl.isEmpty) {
      return left('Arquivo indisponível para este aviso');
    }
    try {
      final tempDir = (await getTemporaryDirectory()).path;
      final file = File('$tempDir/${notice.name}.pdf');
      final response = await http.get(Uri.parse(notice.downloadUrl));
      await file.writeAsBytes(response.bodyBytes);
      return right(file.path);
    } catch (e) {
      return left(e.toString());
    }
  }

  FutureEither<String> downloadNotice(Notice notice) async {
    if (notice.downloadUrl.isEmpty) {
      return left('Arquivo indisponível para este aviso');
    }
    try {
      final downloadPath = (await getDownloadPath())!;
      final file = File('$downloadPath/${notice.name}.pdf');
      if (await Permission.manageExternalStorage.request().isGranted) {
        final response = await http.get(Uri.parse(notice.downloadUrl));
        await file.writeAsBytes(response.bodyBytes);
        return right(downloadPath);
      }
    } catch (e) {
      return left(e.toString());
    }
    return left('Aceite as permissões de arquivo para baixar');
  }
}
