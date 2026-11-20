import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/operations/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

/// One page of an organisation's audit log for a category.
final auditProvider = FutureProvider.autoDispose.family<AuditPage, ({String organisationId, AuditCategory? category})>(
  (ref, key) => ref.read(backendProvider).business.audit(key.organisationId, category: key.category),
);

/// The name of [category].
String categoryName(AppLocalizations l10n, AuditCategory category) => switch (category) {
  AuditCategory.signIn => l10n.auditSignIn,
  AuditCategory.members => l10n.auditMembers,
  AuditCategory.cameras => l10n.auditCameras,
  AuditCategory.rules => l10n.auditRules,
  AuditCategory.arm => l10n.auditArm,
  AuditCategory.views => l10n.auditViews,
  AuditCategory.exports => l10n.auditExports,
  AuditCategory.faces => l10n.auditFaces,
  AuditCategory.admin => l10n.auditAdmin,
};

/// The icon of [category].
IconData categoryIcon(AuditCategory category) => switch (category) {
  AuditCategory.signIn => Icons.login_rounded,
  AuditCategory.members => Icons.group_outlined,
  AuditCategory.cameras => Icons.videocam_outlined,
  AuditCategory.rules => Icons.draw_outlined,
  AuditCategory.arm => Icons.shield_outlined,
  AuditCategory.views => Icons.visibility_outlined,
  AuditCategory.exports => Icons.ios_share_rounded,
  AuditCategory.faces => Icons.face_outlined,
  AuditCategory.admin => Icons.admin_panel_settings_outlined,
};

/// The readable text of an audit [action] code, or the code itself when unknown.
String actionText(AppLocalizations l10n, String action) => switch (action) {
  'auth.sign_in' => l10n.actionAuthSignIn,
  'member.invite' => l10n.actionMemberInvite,
  'member.role' => l10n.actionMemberRole,
  'member.remove' => l10n.actionMemberRemove,
  'camera.add' => l10n.actionCameraAdd,
  'camera.update' => l10n.actionCameraUpdate,
  'camera.delete' => l10n.actionCameraDelete,
  'rules.update' => l10n.actionRulesUpdate,
  'arm.change' => l10n.actionArmChange,
  'live.view' => l10n.actionLiveView,
  'clip.view' => l10n.actionClipView,
  'clip.export' => l10n.actionClipExport,
  'face.enrol' => l10n.actionFaceEnrol,
  'face.delete' => l10n.actionFaceDelete,
  'org.plan' => l10n.actionOrgPlan,
  _ => action,
};

/// The organisation's audit log for admins and owners, filtered by category.
class ActivityScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  AuditCategory? category;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final key = (organisationId: site.organisation.id, category: category);
    final value = ref.watch(auditProvider(key));
    final format = Formats(context, ref.read(clockProvider)());
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.activityTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Gaps.page, 4, Gaps.page, 10),
              children: [
                ChoiceChip(
                  label: Text(l10n.activityAll),
                  selected: category == null,
                  onSelected: (_) => setState(() => category = null),
                ),
                for (final option in AuditCategory.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: Icon(categoryIcon(option), size: 16),
                    label: Text(categoryName(l10n, option)),
                    selected: category == option,
                    onSelected: (_) => setState(() => category = option),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(auditProvider(key)),
        child: AsyncBody(
          value: value,
          loading: const ListSkeleton(thumbnail: false),
          onRetry: () => ref.invalidate(auditProvider(key)),
          data: (page) {
            if (page.items.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyState(icon: Icons.history_rounded, title: l10n.activityEmpty),
                ],
              );
            }
            final rows = <Widget>[];
            DateTime? day;
            for (final entry in page.items) {
              final entryDay = DateTime(entry.at.year, entry.at.month, entry.at.day);
              if (entryDay != day) {
                day = entryDay;
                rows.add(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, Gaps.xs),
                    child: Text(format.dayHeader(entryDay), style: context.text.titleSmall),
                  ),
                );
              }
              rows.add(
                ListTile(
                  leading: Icon(categoryIcon(entry.category)),
                  title: Text(actionText(l10n, entry.action)),
                  subtitle: Text([entry.actor, ?entry.target, ?entry.siteName].join(', ')),
                  trailing: Text(format.time(entry.at), style: dataStyle(context, size: 12, color: p.text3)),
                ),
              );
            }
            rows.add(const SizedBox(height: Gaps.xxl));
            return ListView(physics: const AlwaysScrollableScrollPhysics(), children: rows);
          },
        ),
      ),
    );
  }
}
