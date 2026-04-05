import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/position.dart';
import '../../domain/usecases/position_provider.dart';
import '../../domain/usecases/department_provider.dart';

class PositionsScreen extends ConsumerStatefulWidget {
  const PositionsScreen({super.key});

  @override
  ConsumerState<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends ConsumerState<PositionsScreen> {
  @override
  Widget build(BuildContext context) {
    final positionsAsync = ref.watch(positionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pozisyonlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPositionDialog(context),
          ),
        ],
      ),
      body: positionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(positionsProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (positions) {
          if (positions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.badge_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Pozisyon bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: positions.length,
            itemBuilder: (context, index) {
              final pos = positions[index];
              return _PositionCard(position: pos);
            },
          );
        },
      ),
    );
  }

  void _showPositionDialog(BuildContext context, {Position? position}) {
    showDialog(
      context: context,
      builder: (context) => _PositionDialog(position: position),
    );
  }
}

class _PositionCard extends ConsumerWidget {
  final Position position;
  const _PositionCard({required this.position});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: position.isActive
              ? Colors.green.shade100
              : Colors.grey.shade200,
          child: Icon(
            Icons.badge,
            color: position.isActive
                ? Colors.green.shade700
                : Colors.grey.shade500,
          ),
        ),
        title: Text(
          position.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (position.code.isNotEmpty) Text('Kod: ${position.code}'),
            if (position.department != null)
              Text('Departman: ${position.department!.name}'),
            if (position.level != null) Text('Seviye: ${position.level}'),
            if (position.salaryMin != null && position.salaryMax != null)
              Text(position.salaryRange),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(context, ref);
            } else if (value == 'delete') {
              _showDeleteConfirm(context, ref);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
            const PopupMenuItem(value: 'delete', child: Text('Sil')),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _PositionDialog(position: position),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pozisyonu Sil'),
        content: Text(
          '${position.title} pozisyonunu silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final repository = ref.read(positionRepositoryProvider);
                await repository.deletePosition(position.id);
                if (context.mounted) {
                  ref.invalidate(positionsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pozisyon silindi')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _PositionDialog extends ConsumerStatefulWidget {
  final Position? position;
  const _PositionDialog({this.position});

  @override
  ConsumerState<_PositionDialog> createState() => _PositionDialogState();
}

class _PositionDialogState extends ConsumerState<_PositionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _codeController;
  late final TextEditingController _descController;
  late final TextEditingController _levelController;
  late final TextEditingController _salaryMinController;
  late final TextEditingController _salaryMaxController;
  late bool _isActive;
  int? _selectedDepartmentId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.position?.title ?? '',
    );
    _codeController = TextEditingController(text: widget.position?.code ?? '');
    _descController = TextEditingController(
      text: widget.position?.description ?? '',
    );
    _levelController = TextEditingController(
      text: widget.position?.level?.toString() ?? '',
    );
    _salaryMinController = TextEditingController(
      text: widget.position?.salaryMin?.toString() ?? '',
    );
    _salaryMaxController = TextEditingController(
      text: widget.position?.salaryMax?.toString() ?? '',
    );
    _isActive = widget.position?.isActive ?? true;
    _selectedDepartmentId = widget.position?.departmentId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descController.dispose();
    _levelController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.position != null;
    final departmentsAsync = ref.watch(departmentsProvider);

    return AlertDialog(
      title: Text(isEdit ? 'Pozisyon Düzenle' : 'Yeni Pozisyon'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Başlık',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Başlık gerekli' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Kod (örn: SENG)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                departmentsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) =>
                      const Text('Departmanlar yüklenemedi'),
                  data: (departments) {
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Departman',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedDepartmentId,
                      items: departments
                          .map(
                            (d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(d.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedDepartmentId = v),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _levelController,
                  decoration: const InputDecoration(
                    labelText: 'Seviye (1-10)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _salaryMinController,
                        decoration: const InputDecoration(
                          labelText: 'Min Maaş (cent)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _salaryMaxController,
                        decoration: const InputDecoration(
                          labelText: 'Max Maaş (cent)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Aktif'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Güncelle' : 'Oluştur'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(positionRepositoryProvider);
      final pos = Position(
        id: widget.position?.id ?? 0,
        title: _titleController.text,
        code: _codeController.text,
        description: _descController.text.isEmpty ? null : _descController.text,
        departmentId: _selectedDepartmentId,
        level: int.tryParse(_levelController.text),
        salaryMin: int.tryParse(_salaryMinController.text),
        salaryMax: int.tryParse(_salaryMaxController.text),
        isActive: _isActive,
      );

      if (widget.position != null) {
        await repository.updatePosition(widget.position!.id, pos);
      } else {
        await repository.createPosition(pos);
      }

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(positionsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.position != null
                  ? 'Pozisyon güncellendi'
                  : 'Pozisyon oluşturuldu',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
