import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/remote_file_service.dart';
import '../../../core/services/supabase_storage_service.dart';
import '../repository/document_repository.dart';

part 'document_providers.g.dart';

@Riverpod(keepAlive: true)
SupabaseStorageService supabaseStorageService(SupabaseStorageServiceRef ref) =>
    SupabaseStorageService();

@Riverpod(keepAlive: true)
RemoteFileService remoteFileService(RemoteFileServiceRef ref) =>
    RemoteFileService();

@Riverpod(keepAlive: true)
DocumentRepository documentRepository(DocumentRepositoryRef ref) =>
    DocumentRepository();
