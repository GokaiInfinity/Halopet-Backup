import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'package:halopet_vetcare/screens/admin/admin_doctors_screen.dart';
import 'package:halopet_vetcare/core/app_theme.dart';
import 'package:halopet_vetcare/widgets/ui_components.dart';
import 'package:halopet_vetcare/screens/admin/admin_products_screen.dart';
import 'package:halopet_vetcare/screens/owner/products_screen.dart';
import 'package:halopet_vetcare/screens/admin/admin_dashboard.dart';
import 'package:halopet_vetcare/screens/home/home_router.dart';
import 'package:halopet_vetcare/screens/owner/doctor_list_screen.dart';
import 'package:halopet_vetcare/screens/owner/owner_profile_tab.dart';
import 'package:halopet_vetcare/screens/owner/owner_dashboard.dart';
import 'package:halopet_vetcare/screens/doctor/doctor_profile_tab.dart';
import 'package:halopet_vetcare/screens/owner/notifications_screen.dart';
import 'package:halopet_vetcare/screens/owner/pets_screen.dart';
import 'package:halopet_vetcare/screens/owner/cart_screen.dart';
import 'package:halopet_vetcare/core/database.dart';
import 'package:halopet_vetcare/screens/owner/create_consultation_screen.dart';
import 'package:halopet_vetcare/screens/auth/login_screen.dart';
import 'package:halopet_vetcare/screens/auth/register_screen.dart';
import 'package:halopet_vetcare/screens/admin/reports_screen.dart';
import 'package:halopet_vetcare/screens/owner/medical_records_screen.dart';
import 'package:halopet_vetcare/screens/doctor/doctor_schedule_screen.dart';
import 'package:halopet_vetcare/screens/admin/admin_profile_tab.dart';
import 'package:halopet_vetcare/core/helpers.dart';
import 'package:halopet_vetcare/screens/owner/orders_screen.dart';
import 'package:halopet_vetcare/screens/admin/admin_users_screen.dart';
import 'package:halopet_vetcare/screens/doctor/doctor_dashboard.dart';
import 'package:halopet_vetcare/screens/owner/chat_screen.dart';

class HomeRouter extends StatefulWidget {
  const HomeRouter({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<HomeRouter> createState() => _HomeRouterState();
}
class _HomeRouterState extends State<HomeRouter> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] as String;
    List<Widget> pages;
    List<BottomNavigationBarItem> items;
    
    if (role == 'admin') {
      pages = [
        AdminDashboard(user: widget.user),
        AdminUsersScreen(user: widget.user),
        AdminDoctorsScreen(user: widget.user),
        AdminProductsScreen(user: widget.user),
        AdminProfileTab(user: widget.user),
      ];
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pengguna'),
        BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Dokter'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else if (role == 'dokter') {
      pages = [
        DoctorDashboard(user: widget.user),
        DoctorScheduleScreen(user: widget.user, doctor: null),
        DoctorProfileTab(user: widget.user),
      ];
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Jadwal'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else {
      pages = [
        OwnerDashboard(user: widget.user),
        PetsScreen(user: widget.user),
        DoctorListScreen(user: widget.user),
        ProductsScreen(user: widget.user),
        OwnerProfileTab(user: widget.user),
      ];
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Hewan'),
        BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Konsul'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Toko'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    }

    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: AppColors.primaryBlue),
              selectedLabelTextStyle: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              destinations: items.map((e) => NavigationRailDestination(icon: e.icon, label: Text(e.label!))).toList(),
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide ? null : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        items: items,
      ),
    );
  }
}
