import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/identity/presentation/validators.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
import 'package:smart_surveillance/features/tenancy/presentation/labels.dart';
final membersProvider = FutureProvider.autoDispose.family<List<Member>, String>(
  (ref, id) => ref.read(backendProvider).tenancy.members(id),
);

final invitationsProvider = FutureProvider.autoDispose.family<List<Invitation>, String>(
  (ref, id) => ref.read(backendProvider).tenancy.invitations(id),
);

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final organisation = site.organisation;
    final members = ref.watch(membersProvider(organisation.id));
    final invitations = ref.watch(invitationsProvider(organisation.id)).value ?? const [];
    final sites = (ref.watch(allSitesProvider).value ?? const <Site>[])
        .where((s) => s.organisationId == organisation.id)
        .toList();
    final admin = site.can(Role.admin);
    final format = Formats(context, ref.read(clockProvider)());
    String scope(List<String>? ids) {
      if (ids == null || ids.isEmpty) return l10n.membersAllSites;
      final names = sites.where((s) => ids.contains(s.id)).map((s) => s.name).toList();
      return names.isEmpty ? l10n.membersSomeSites(ids.length) : names.join(', ');
    }

    Future<void> open(Member? member) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MemberSheet(organisation: organisation, sites: sites, member: member),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.membersTitle)),
      floatingActionButton: admin
          ? FloatingActionButton.extended(
              onPressed: () => open(null),
              icon: const Icon(Icons.person_add_alt_outlined),
              label: Text(l10n.membersInvite),
            )
          : null,
      body: AsyncBody(
        value: members,
        onRetry: () => ref.invalidate(membersProvider(organisation.id)),
        loading: const ListSkeleton(thumbnail: false),
        data: (members) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            TileGroup(
              children: [
                for (final member in members)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: p.surface3,
                      child: Text(
                        member.name.isEmpty ? '?' : member.name.characters.first.toUpperCase(),
                        style: context.text.titleSmall,
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(child: Text(member.name, overflow: TextOverflow.ellipsis)),
                        if (member.you) ...[const SizedBox(width: 8), Tag(l10n.membersYou, dense: true, tone: TagTone.info)],
                      ],
                    ),
                    subtitle: Text('${member.email}\n${scope(member.siteIds)}'),
                    isThreeLine: true,
                    trailing: Tag(l10n.role(member.role)),
                    onTap: admin && !member.you && (member.role != Role.owner || site.can(Role.owner)) ? () => open(member) : null,
                  ),
              ],
            ),
            if (invitations.any((i) => i.state == InvitationState.pending)) ...[
              SectionHeader(l10n.membersPending),
              TileGroup(
                children: [
                  for (final invitation in invitations.where((i) => i.state == InvitationState.pending))
                    ListTile(
                      leading: const Icon(Icons.mail_outline_rounded),
                      title: Text(invitation.email),
                      subtitle: Text(
                        '${l10n.role(invitation.role)}, ${scope(invitation.siteIds)}\n'
                        '${l10n.membersExpires(format.date(invitation.expiresAt))}',
                      ),
                      isThreeLine: true,
                      trailing: admin
                          ? IconButton(
                              tooltip: l10n.membersRevoke,
                              onPressed: () async {
                                final ok = await confirm(
                                  context,
                                  title: l10n.membersRevoke,
                                  action: l10n.membersRevoke,
                                  destructive: true,
                                );
                                if (!ok) return;
                                await ref.read(backendProvider).tenancy.revokeInvitation(organisation.id, invitation.id);
                                ref.invalidate(invitationsProvider(organisation.id));
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MemberSheet extends ConsumerStatefulWidget {
  const MemberSheet({super.key, required this.organisation, required this.sites, this.member});

  final Organisation organisation;
  final List<Site> sites;
  final Member? member;

  @override
  ConsumerState<MemberSheet> createState() => _MemberSheetState();
}

class _MemberSheetState extends ConsumerState<MemberSheet> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  late Role role = widget.member?.role ?? Role.viewer;
  late bool allSites = widget.member?.siteIds == null || widget.member!.siteIds!.isEmpty;
  late Set<String> sites = {...?widget.member?.siteIds};
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final l10n = context.l10n;
    final tenancy = ref.read(backendProvider).tenancy;
    final organisation = widget.organisation;
    if (widget.member == null && !form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final scope = allSites ? null : sites.toList();
      if (widget.member == null) {
        await tenancy.invite(organisationId: organisation.id, email: email.text.trim(), role: role, siteIds: scope);
        ref.invalidate(invitationsProvider(organisation.id));
        if (mounted) showMessage(context, l10n.membersInviteSent(email.text.trim()));
      } else {
        await tenancy.updateMember(organisation.id, widget.member!.userId, role: role, siteIds: scope);
        ref.invalidate(membersProvider(organisation.id));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final owner = widget.organisation.role == Role.owner;
    final roles = Role.values.reversed.where((r) => owner || r != Role.owner).toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: form,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(Gaps.page + 4, 0, Gaps.page + 4, Gaps.lg),
          children: [
            Text(widget.member == null ? l10n.membersInviteTitle : widget.member!.name, style: context.text.titleLarge),
            const SizedBox(height: Gaps.xs),
            Text(
              widget.member == null ? l10n.membersInviteBody : widget.member!.email,
              style: context.text.bodyMedium?.copyWith(color: p.text2),
            ),
            const SizedBox(height: Gaps.lg),
            if (widget.member == null) ...[
              TextFormField(
                controller: email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.fieldEmail),
                validator: (value) => validateEmail(l10n, value),
              ),
              const SizedBox(height: Gaps.lg),
            ],
            Text(l10n.membersRole, style: context.text.titleSmall?.copyWith(color: p.text2)),
            RadioGroup<Role>(
              groupValue: role,
              onChanged: (value) => setState(() => role = value ?? role),
              child: Column(
                children: [
                  for (final option in roles)
                    RadioListTile<Role>(
                      contentPadding: EdgeInsets.zero,
                      value: option,
                      title: Text(l10n.role(option)),
                      subtitle: Text(l10n.roleBody(option)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Gaps.sm),
            Text(l10n.membersSites, style: context.text.titleSmall?.copyWith(color: p.text2)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.membersAllSites),
              value: allSites,
              onChanged: (value) => setState(() => allSites = value),
            ),
            if (!allSites)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final site in widget.sites)
                    FilterChip(
                      avatar: Icon(siteKindIcon(site.kind), size: 16),
                      label: Text(site.name),
                      selected: sites.contains(site.id),
                      onSelected: (on) => setState(() => on ? sites.add(site.id) : sites.remove(site.id)),
                    ),
                ],
              ),
            const SizedBox(height: Gaps.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy || (!allSites && sites.isEmpty) ? null : submit,
                child: Text(widget.member == null ? l10n.membersInvite : l10n.commonSave),
              ),
            ),
            if (widget.member != null) ...[
              const SizedBox(height: Gaps.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: p.dangerText),
                  onPressed: () async {
                    final ok = await confirm(
                      context,
                      title: l10n.membersRemove,
                      body: l10n.membersRemoveBody(widget.member!.name),
                      action: l10n.commonRemove,
                      destructive: true,
                    );
                    if (!ok) return;
                    await ref.read(backendProvider).tenancy.removeMember(widget.organisation.id, widget.member!.userId);
                    ref.invalidate(membersProvider(widget.organisation.id));
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(l10n.membersRemove),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
