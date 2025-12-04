// lib/providers/audit/folder_provider.dart
import 'package:auditlab/phase2/models/folder.dart';
import 'package:auditlab/phase2/services/folder_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final folderServiceProvider = Provider((ref) => FolderService());

final foldersProvider =
    StreamProvider.family<List<Folder>, ({String districtId, String periodId})>(
      (ref, params) {
        final service = ref.watch(folderServiceProvider);
        return service.streamFolders(params.districtId, params.periodId);
      },
    );

final selectedFolderProvider = StateProvider<Folder?>((ref) => null);
