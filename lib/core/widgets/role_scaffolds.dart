import 'package:flutter/material.dart';
import '../../app/routes.dart';

class OwnerScaffold extends StatelessWidget {
  const OwnerScaffold(
      {super.key,
      required this.title,
      required this.body,
      this.actions,
      this.floatingActionButton,
      this.index = 0});
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: title.isEmpty
          ? null
          : AppBar(
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              actions: actions),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home, Icons.home_outlined,
                  'Beranda', AppRoutes.ownerHome),
              _buildNavItem(context, 1, Icons.pets, Icons.pets_outlined,
                  'Hewan', AppRoutes.ownerPets),
              _buildCenterNavItem(
                  context, 2, 'Konsultasi', AppRoutes.doctorList),
              _buildNavItem(
                  context,
                  3,
                  Icons.chat_bubble,
                  Icons.chat_bubble_outline,
                  'Pesan',
                  AppRoutes.ownerConsultations),
              _buildNavItem(context, 4, Icons.person, Icons.person_outline,
                  'Akun', AppRoutes.ownerProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int itemIndex, IconData activeIcon,
      IconData inactiveIcon, String label, String route) {
    final isSelected = index == itemIndex;
    final color =
        isSelected ? const Color(0xFF45A5C7) : const Color(0xFFB0C4D9);
    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : inactiveIcon,
                color: color, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem(
      BuildContext context, int itemIndex, String label, String route) {
    final isSelected = index == itemIndex;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF45A5C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Color(0xFFB0C4D9), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class DoctorScaffold extends StatelessWidget {
  const DoctorScaffold(
      {super.key, required this.title, required this.body, this.index = 0});
  final String title;
  final Widget body;
  final int index;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w800))),
        body: body,
        bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) {
              final route = [
                AppRoutes.doctorHome,
                AppRoutes.doctorPatients,
                AppRoutes.doctorSchedule,
                AppRoutes.doctorConsultations,
                AppRoutes.doctorProfile
              ][i];
              if (ModalRoute.of(context)?.settings.name != route)
                Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Beranda'),
              NavigationDestination(
                  icon: Icon(Icons.pets_outlined),
                  selectedIcon: Icon(Icons.pets),
                  label: 'Pasien'),
              NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Jadwal'),
              NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: 'Pesan'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Akun'),
            ]),
      );
}

class AdminScaffold extends StatelessWidget {
  const AdminScaffold(
      {super.key, required this.title, required this.body, this.index = 0});
  final String title;
  final Widget body;
  final int index;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: title.isEmpty
            ? null
            : AppBar(
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800))),
        body: body,
        bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) {
              final route = [
                AppRoutes.adminHome,
                AppRoutes.adminPatients,
                AppRoutes.adminConsultations,
                AppRoutes.adminReports,
                AppRoutes.adminSettings
              ][i];
              if (ModalRoute.of(context)?.settings.name != route)
                Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.pets), label: 'Pasien'),
              NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline), label: 'Konsultasi'),
              NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined), label: 'Laporan'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline), label: 'Akun'),
            ]),
      );
}
