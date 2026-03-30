import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import '../models/task.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  if (Isar.instanceNames.isNotEmpty) {
    return Isar.getInstance()!;
  }
  
  final dir = kIsWeb ? '' : (await getApplicationDocumentsDirectory()).path;
  
  return await Isar.open(
    [TaskSchema],
    directory: dir,
  );
});
