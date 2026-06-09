import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/security_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/export_service.dart';
import '../../core/database/database_helper.dart';
import '../templates/templates_screen.dart';
import '../backup/backup_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _security = SecurityService();
  final _backupService = BackupService();
  final _exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Appearance
          _buildSectionHeader(context, '外观'),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            title: '主题模式',
            subtitle: _getThemeModeName(themeMode),
            onTap: () => _showThemeDialog(context, themeMode),
          ),
          const SizedBox(height: 8),

          // Security
          _buildSectionHeader(context, '安全'),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: '修改主密码',
            subtitle: '更改应用解锁密码',
            onTap: _showChangePasswordDialog,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.fingerprint,
            title: '生物识别',
            subtitle: '使用指纹或面容解锁',
            trailing: FutureBuilder<bool>(
              future: _security.isBiometricEnabled(),
              builder: (context, snapshot) {
                final enabled = snapshot.data ?? false;
                return Switch(
                  value: enabled,
                  onChanged: (v) => _toggleBiometric(v),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Data Management
          _buildSectionHeader(context, '数据管理'),
          _buildSettingsTile(
            context,
            icon: Icons.folder_outlined,
            title: '模板管理',
            subtitle: '创建和管理自定义模板',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TemplatesScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.backup_outlined,
            title: '备份与恢复',
            subtitle: '本地备份和恢复数据',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BackupScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.file_download_outlined,
            title: '导出数据',
            subtitle: '导出为 Markdown / PDF / TXT / JSON',
            onTap: _showExportDialog,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.file_upload_outlined,
            title: '批量导入',
            subtitle: '从 JSON 文件导入数据',
            onTap: _importData,
          ),
          const SizedBox(height: 8),

          // Tags Management
          _buildSectionHeader(context, '标签'),
          _buildSettingsTile(
            context,
            icon: Icons.label_outline,
            title: '管理标签',
            subtitle: '创建、编辑和删除标签',
            onTap: _showTagManagement,
          ),
          const SizedBox(height: 8),

          // About
          _buildSectionHeader(context, '关于'),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: '关于 Personal Vault',
            subtitle: '版本 1.0.0',
          ),
          _buildSettingsTile(
            context,
            icon: Icons.storage_outlined,
            title: '存储信息',
            subtitle: '查看数据库和文件存储大小',
            onTap: _showStorageInfo,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.neutral500)) : null,
          trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
          onTap: onTap,
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.system: return '跟随系统';
      case ThemeModeOption.light: return '浅色模式';
      case ThemeModeOption.dark: return '深色模式';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeModeOption current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeModeOption.values.map((mode) {
            return RadioListTile<ThemeModeOption>(
              title: Text(_getThemeModeName(mode)),
              value: mode,
              groupValue: current,
              onChanged: (v) {
                if (v != null) {
                  ref.read(themeModeProvider.notifier).state = v;
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改主密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldController, obscureText: true, decoration: const InputDecoration(labelText: '原密码')),
            const SizedBox(height: 12),
            TextField(controller: newController, obscureText: true, decoration: const InputDecoration(labelText: '新密码')),
            const SizedBox(height: 12),
            TextField(controller: confirmController, obscureText: true, decoration: const InputDecoration(labelText: '确认新密码')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              if (newController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('两次输入不一致')));
                return;
              }
              try {
                await _security.changeMasterPassword(oldController.text, newController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('密码修改成功')));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('修改'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled) {
      final canUse = await _security.canUseBiometric();
      if (!canUse) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('设备不支持生物识别')),
          );
        }
        return;
      }
      final authenticated = await _security.authenticateWithBiometric();
      if (authenticated) {
        await _security.setBiometricEnabled(true);
      }
    } else {
      await _security.setBiometricEnabled(false);
    }
    setState(() {});
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出数据'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExportOption(context, 'Markdown', Icons.description, () => _exportData('md')),
            _buildExportOption(context, 'PDF', Icons.picture_as_pdf, () => _exportData('pdf')),
            _buildExportOption(context, 'TXT', Icons.text_snippet, () => _exportData('txt')),
            _buildExportOption(context, 'JSON', Icons.code, () => _exportData('json')),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _exportData(String format) async {
    try {
      final entries = await DatabaseHelper.instance.getEntries();
      String path;
      switch (format) {
        case 'md': path = await _exportService.exportAsMarkdown(entries); break;
        case 'pdf': path = await _exportService.exportAsPdf(entries); break;
        case 'txt': path = await _exportService.exportAsTxt(entries); break;
        case 'json': path = await _exportService.exportAsJson(entries); break;
        default: return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出成功: $path')));
        Share.shareXFiles([XFile(path)]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败: $e')));
      }
    }
  }

  Future<void> _importData() async {
    // Import from JSON backup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('请前往"备份与恢复"页面导入数据')),
    );
  }

  void _showTagManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Consumer(
            builder: (context, ref, _) {
              final tagsAsync = ref.watch(tagsProvider);
              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('管理标签', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showAddTagDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: tagsAsync.when(
                        data: (tags) => tags.isEmpty
                            ? Center(child: Text('还没有标签', style: TextStyle(color: AppColors.neutral500)))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: tags.length,
                                itemBuilder: (context, index) {
                                  final tag = tags[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: tag.color != null
                                          ? AppColors.hexToColor(tag.color!)
                                          : AppColors.primary,
                                      radius: 14,
                                      child: Text(tag.name[0], style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                    title: Text(tag.name),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                      onPressed: () async {
                                        await DatabaseHelper.instance.deleteTag(tag.id);
                                        ref.invalidate(tagsProvider);
                                      },
                                    ),
                                  );
                                },
                              ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('加载失败: $e')),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建标签'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: '标签名称')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await DatabaseHelper.instance.insertTag(
                Tag(name: controller.text.trim()),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(tagsProvider);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo() async {
    final entryCount = await DatabaseHelper.instance.getEntryCount();
    final passwordCount = (await DatabaseHelper.instance.getPasswords()).length;
    final categoryCount = (await DatabaseHelper.instance.getAllCategories()).length;
    final tagCount = (await DatabaseHelper.instance.getTags()).length;

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('存储信息'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('记录总数', '$entryCount'),
              _infoRow('密码条目', '$passwordCount'),
              _infoRow('分类数量', '$categoryCount'),
              _infoRow('标签数量', '$tagCount'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
          ],
        ),
      );
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.neutral600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
