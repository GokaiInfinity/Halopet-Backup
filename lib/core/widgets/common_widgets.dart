import 'package:flutter/material.dart';
import '../../app/theme.dart';

class HaloPetLogo extends StatelessWidget {
  const HaloPetLogo({super.key, this.size = 72});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * .3),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x332F80ED),
                  blurRadius: 24,
                  offset: Offset(0, 12))
            ]),
        child: Icon(Icons.pets_rounded, color: Colors.white, size: size * .55),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text))),
        if (action != null) action!
      ]);
}

class InfoCard extends StatelessWidget {
  const InfoCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(18),
      this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(padding: padding, child: child)));
}

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key,
      required this.title,
      required this.message,
      this.icon = Icons.inbox_outlined,
      this.action});
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 72, color: AppColors.secondary),
            const SizedBox(height: 18),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.5)),
            if (action != null) ...[const SizedBox(height: 20), action!]
          ])));
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => EmptyState(
      title: 'Terjadi kesalahan',
      message: message,
      icon: Icons.error_outline,
      action: onRetry == null
          ? null
          : FilledButton(onPressed: onRetry, child: const Text('Coba lagi')));
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'finished' => AppColors.success,
      'ongoing' || 'accepted' => AppColors.primary,
      'cancelled' => AppColors.danger,
      _ => const Color(0xFFE0A800)
    };
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(99)),
        child: Text(status.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w800)));
  }
}

String initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((e) => e[0].toUpperCase()).join();
}

class AvatarInitials extends StatelessWidget {
  const AvatarInitials(this.name, {super.key, this.radius = 25, this.icon});
  final String name;
  final double radius;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFDCEBFF),
      child: icon != null
          ? Icon(icon, color: AppColors.primary)
          : Text(initials(name),
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w800)));
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: EmptyState(
          title: 'Halaman tidak ditemukan',
          message: 'Route yang diminta tidak tersedia.',
          icon: Icons.travel_explore));
}
