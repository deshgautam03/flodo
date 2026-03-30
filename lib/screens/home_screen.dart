import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/task_provider.dart';
import '../widgets/task_list_tile.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';
import 'add_task_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String _debouncedSearchQuery = '';
  Timer? _debounceTimer;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'To-Do', 'In Progress', 'Done'];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _debouncedSearchQuery = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsyncValue = ref.watch(taskProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryDim.withValues(alpha: 0.2), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDvFAWW9FoBUIqisOFHZBc42TMT7Q2DWg7DFO_7_zSAh7NUVcDXNeC4oGmXfHxG72eSuGCRRUsuX1pSRDd3wCdszbj7D7H0xiB9neAbt0_txMub5PbB-fwa7SDfEmkJL4O7WbBVySStN8Xc7HjEZxFwnav27MUvq9lGpP3ee7qKsZiE5udzKKp5FrdXTUxQ69gUyIDrg47JphAhmXCSwxNruRyBj9jgcBh-xatIOYS-e7YNAzXjbMyKDrlXZ2-jE0VuutbDw42_Ll0'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Flodo',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                filled: true,
                fillColor: AppTheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.primaryDim),
                ),
              ),
            ),
          ),
          
          // Filter Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 0, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF7C4DFF) : AppTheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          Expanded(
            child: tasksAsyncValue.when(
              data: (tasks) {
                final filteredTasks = tasks.where((task) {
                  final matchesSearch = task.title.toLowerCase().contains(_debouncedSearchQuery.toLowerCase()) ||
                      (task.description?.toLowerCase().contains(_debouncedSearchQuery.toLowerCase()) ?? false);
                  
                  bool matchesFilter = true;
                  if (_selectedFilter == 'To-Do') {
                    matchesFilter = task.priority == 'To-Do';
                  } else if (_selectedFilter == 'In Progress') {
                    matchesFilter = task.priority == 'In Progress';
                  } else if (_selectedFilter == 'Done') {
                    matchesFilter = task.isCompleted;
                  }
                  return matchesSearch && matchesFilter;
                }).toList();
                
                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.surfaceContainerHighest),
                          const SizedBox(height: 24),
                          Text(
                            tasks.isEmpty ? 'No tasks yet' : 'No tasks found',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.onSurfaceVariant),
                          ),
                          if (tasks.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'The digital obsidian is clear. Tap add below to create your first task.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.outlineVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16).copyWith(bottom: 100),
                  itemCount: filteredTasks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24, left: 4),
                        child: Text(
                          "Today's Focus",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                      );
                    }
                    final task = filteredTasks[index - 1];
                    return TaskListTile(
                      task: task,
                      searchQuery: _searchQuery,
                      onCheckboxChanged: (val) {
                        if (val != null) {
                          task.isCompleted = val;
                          ref.read(taskProvider.notifier).updateTask(task);
                        }
                      },
                      onDelete: () {
                        ref.read(taskProvider.notifier).deleteTask(task.id);
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTaskScreen(task: task),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.error))),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: GradientButton(
          borderRadius: 24,
          hasShadow: true,
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen()));
          },
          child: const Icon(Icons.add, size: 32, color: Colors.black),
        ),
      ),
    );
  }
}
