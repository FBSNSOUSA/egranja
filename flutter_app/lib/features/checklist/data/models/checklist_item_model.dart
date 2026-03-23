// This file is kept for backward compatibility.
// ChecklistItem now handles its own serialization (fromJson/toJson)
// directly in the entity class since backend stores items as simple
// JSON objects with only 'descricao' and 'completado' fields.
//
// See: lib/features/checklist/domain/entities/checklist_item.dart
export 'package:egranja_flutter/features/checklist/domain/entities/checklist_item.dart';
