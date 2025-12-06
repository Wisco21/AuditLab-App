import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:auditlab/phase_two_core_features/time_covertor.dart';

part 'folder.freezed.dart';
part 'folder.g.dart';

@freezed
abstract class Folder with _$Folder {
  // const Folder._();

  // @JsonSerializable(explicitToJson: true)
  const factory Folder({
    required String id,
    required String periodId,
    required String folderNumber,
    required String chequeRangeStart,
    required String chequeRangeEnd,
    required String createdBy,

    @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
    required DateTime updatedAt,
    required String lastUpdatedBy,
    @Default('Pending') String status,
    @Default(0) int totalCheques,
    @Default(0) int completedCheques,
  }) = _Folder;

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);
}
