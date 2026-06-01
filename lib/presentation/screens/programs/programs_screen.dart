import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/router/app_router.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/program_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_error.dart';
import 'package:level_bot/presentation/widgets/common/app_loading.dart';
import 'package:level_bot/presentation/widgets/program/program_card.dart';

class ProgramsScreen extends ConsumerStatefulWidget {
  const ProgramsScreen({super.key});

  @override
  ConsumerState<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ProgramsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
            onPressed: () => context.push('${AppRoutes.programs}/create'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Programs'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyProgramsTab(),
          _DiscoverTab(),
        ],
      ),
    );
  }
}

class _MyProgramsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsState = ref.watch(programsNotifierProvider);

    return programsState.when(
      loading: () => const AppLoading(),
      error: (error, _) => AppError(
        message: error.toString(),
        onRetry: () => ref.read(programsNotifierProvider.notifier).load(),
      ),
      data: (programs) {
        if (programs.isEmpty) return _EmptyPrograms();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: programs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProgramCard(
                program: programs[index],
                onTap: () => context.push(
                    '${AppRoutes.programs}/${programs[index].id}'),
              ),
            );
          },
        );
      },
    );
  }
}

class _DiscoverTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsState = ref.watch(publicProgramsProvider);

    return programsState.when(
      loading: () => const AppLoading(),
      error: (error, _) => AppError(message: error.toString()),
      data: (programs) {
        if (programs.isEmpty) {
          return const Center(child: Text('No public programs yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: programs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProgramCard(
                program: programs[index],
                showAuthor: true,
                onTap: () => context.push(
                    '${AppRoutes.programs}/${programs[index].id}'),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyPrograms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.view_list_rounded,
              size: 72,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text('No programs yet', style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Create your first training program\nto start your fitness journey',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.push('${AppRoutes.programs}/create'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Program'),
            ),
          ],
        ),
      ),
    );
  }
}
