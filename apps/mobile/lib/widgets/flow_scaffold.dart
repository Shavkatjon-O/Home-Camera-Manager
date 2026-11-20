import 'package:flutter/material.dart';

import '../core/theme/palette.dart';
import '../core/theme/theme.dart';
import '../l10n/l10n.dart';

class FlowScaffold extends StatelessWidget {
  const FlowScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.step,
    required this.children,
    this.bottom,
    this.leading,
    this.actions,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final String? step;
  final List<Widget> children;
  final Widget? bottom;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        leading: leading,
        actions: actions,
        title: step == null ? null : Text(step!, style: dataStyle(context, size: 12.5, color: p.text3)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Gaps.page + 4, Gaps.sm, Gaps.page + 4, Gaps.xl),
                children: [
                  Semantics(header: true, child: Text(title, style: context.text.headlineMedium)),
                  if (subtitle != null) ...[
                    const SizedBox(height: Gaps.sm),
                    Text(subtitle!, style: context.text.bodyLarge?.copyWith(color: p.text2)),
                  ],
                  const SizedBox(height: Gaps.xl),
                  ...children,
                ],
              ),
            ),
            if (bottom != null)
              Container(
                padding: const EdgeInsets.fromLTRB(Gaps.page + 4, Gaps.md, Gaps.page + 4, Gaps.lg),
                decoration: BoxDecoration(
                  color: p.background,
                  border: Border(top: BorderSide(color: p.border)),
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class BusyButton extends StatelessWidget {
  const BusyButton({super.key, required this.label, required this.onPressed, this.busy = false, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: busy
              ? SizedBox(
                  key: const ValueKey('busy'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: p.text2),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 8)],
                    Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                  ],
                ),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.autofillHints = const [AutofillHints.password],
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String> autofillHints;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: hidden,
    autocorrect: false,
    enableSuggestions: false,
    autofillHints: widget.autofillHints,
    textInputAction: widget.textInputAction,
    validator: widget.validator,
    onFieldSubmitted: widget.onSubmitted,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
      labelText: widget.label,
      suffixIcon: IconButton(
        tooltip: hidden ? context.l10n.commonShowPassword : context.l10n.commonHidePassword,
        onPressed: () => setState(() => hidden = !hidden),
        icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
      ),
    ),
  );
}
