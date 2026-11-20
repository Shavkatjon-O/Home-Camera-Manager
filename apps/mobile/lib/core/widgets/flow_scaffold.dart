import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
/// The page layout of a setup or sign-in step: a title, optional subtitle, content and a bottom
/// bar.
class FlowScaffold extends StatelessWidget {
  /// Creates a step page showing [children] under [title].
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

  /// The heading of the step.
  final String title;
  /// A line of explanation under the heading.
  final String? subtitle;
  /// The step indicator shown in the app bar.
  final String? step;
  /// The content of the step.
  final List<Widget> children;
  /// The widget pinned to the bottom, usually the main button.
  final Widget? bottom;
  /// The widget at the start of the app bar, replacing the back button.
  final Widget? leading;
  /// The actions at the end of the app bar.
  final List<Widget>? actions;
  /// Whether the app bar shows a back button.
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

/// A full-width filled button that shows a spinner in place of its label while busy.
class BusyButton extends StatelessWidget {
  /// Creates a button labelled [label] that calls [onPressed] unless it is busy.
  const BusyButton({super.key, required this.label, required this.onPressed, this.busy = false, this.icon});

  /// The text of the button.
  final String label;
  /// The callback for presses, or null to disable the button.
  final VoidCallback? onPressed;
  /// Whether the button shows a spinner and ignores presses.
  final bool busy;
  /// The icon shown before the label, if any.
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

/// A password field with a button to show or hide the text.
class PasswordField extends StatefulWidget {
  /// Creates a password field for [controller] labelled [label].
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

  /// The controller holding the entered text.
  final TextEditingController controller;
  /// The label shown on the field.
  final String label;
  /// The validator, which returns an error message or null when the value is valid.
  final String? Function(String?)? validator;
  /// The action of the keyboard's action key.
  final TextInputAction textInputAction;
  /// The callback called when the user submits from the keyboard.
  final ValueChanged<String>? onSubmitted;
  /// The hints that let the platform autofill the field.
  final Iterable<String> autofillHints;
  /// The callback called when the text changes.
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
