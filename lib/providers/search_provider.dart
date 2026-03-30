import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'database_provider.dart';
import '../models/task.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final debouncedSearchQueryProvider = FutureProvider<String>((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  // Wait for 300ms. If the user types again, this provider will be re-evaluated
  // and the previous Future will be effectively orphaned. Riverpod handles 
  // debouncing beautifully like this.
  await Future.delayed(const Duration(milliseconds: 300));
  
  return query;
});

final searchResultsProvider = FutureProvider<List<Task>>((ref) async {
  final query = await ref.watch(debouncedSearchQueryProvider.future);
  if (query.isEmpty) {
    return [];
  }
  
  final isar = await ref.read(isarProvider.future);
  
  // Example of using filter on Isar
  return await isar.tasks.filter()
      .titleContains(query, caseSensitive: false)
      .findAll();
});
