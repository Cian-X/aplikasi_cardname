import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../user_profile_storage.dart';

class AktivitasHarianPage extends StatefulWidget {
  const AktivitasHarianPage({super.key});

  @override
  State<AktivitasHarianPage> createState() => _AktivitasHarianPageState();
}

class _AktivitasHarianPageState extends State<AktivitasHarianPage> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = UserProfileStorage.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data ?? UserProfile.empty();
          final aktivitas = profile.activities;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 48.0 : 16.0,
              vertical: 24.0,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: FutureBuilder<UserProfile>(
                    future: _profileFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final profile = snapshot.data!;
                      return IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Tambah Aktivitas',
                        onPressed: () => _addOrEditActivity(activities: profile.activities, profile: profile),
                      );
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    Expanded(
                      child: isLargeScreen
                          ? GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: aktivitas.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    _buildActivityCard(context, aktivitas[index]),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'Edit',
                                            onPressed: () => _addOrEditActivity(activity: aktivitas[index], activities: aktivitas, profile: profile, editIndex: index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            tooltip: 'Hapus',
                                            onPressed: () => _deleteActivity(index, aktivitas, profile),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : ListView.separated(
                              itemCount: aktivitas.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    _buildActivityCard(context, aktivitas[index]),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'Edit',
                                            onPressed: () => _addOrEditActivity(activity: aktivitas[index], activities: aktivitas, profile: profile, editIndex: index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            tooltip: 'Hapus',
                                            onPressed: () => _deleteActivity(index, aktivitas, profile),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _iconFromString(activity.icon),
                    color: Colors.indigo,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.time,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        activity.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              activity.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'sun':
        return Icons.bedtime;
      case 'coffee':
        return Icons.breakfast_dining;
      case 'broom':
        return Icons.local_laundry_service;
      case 'student':
        return Icons.menu_book;
      case 'book':
        return Icons.school_outlined;
      case 'work':
        return Icons.work_outline;
      case 'rest':
        return Icons.self_improvement;
      default:
        return Icons.circle;
    }
  }

  void _addOrEditActivity({Activity? activity, required List<Activity> activities, required UserProfile profile, int? editIndex}) async {
    final timeController = TextEditingController(text: activity?.time ?? '');
    final nameController = TextEditingController(text: activity?.name ?? '');
    final descController = TextEditingController(text: activity?.description ?? '');
    String selectedIcon = activity?.icon ?? 'sun';
    final result = await showDialog<Activity>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(activity == null ? 'Tambah Aktivitas' : 'Edit Aktivitas'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: 'Waktu'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Aktivitas'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedIcon,
                  items: const [
                    DropdownMenuItem(value: 'sun', child: Row(children: [Icon(Icons.bedtime, color: Colors.indigo, size: 24), SizedBox(width: 8), Text('Tidur')])),
                    DropdownMenuItem(value: 'coffee', child: Row(children: [Icon(Icons.breakfast_dining, color: Colors.indigo, size: 24), SizedBox(width: 8), Text('Makan')])),
                    DropdownMenuItem(value: 'broom', child: Row(children: [Icon(Icons.local_laundry_service, color: Colors.indigo, size: 24), SizedBox(width: 8), Text('Beres Rumah')])),
                    DropdownMenuItem(value: 'student', child: Row(children: [Icon(Icons.menu_book, color: Colors.indigo, size: 24), SizedBox(width: 8), Text('Belajar')])),
                    DropdownMenuItem(value: 'book', child: Row(children: [Icon(Icons.school_outlined, color: Colors.indigo, size: 24), SizedBox(width: 8), Text('Kuliah')])),
                    DropdownMenuItem(value: 'work', child: Row(children: [Icon(Icons.work_outline, color: Colors.indigo, size: 24), SizedBox(width: 8), Text('Bekerja')])),
                    DropdownMenuItem(value: 'rest', child: Row(children: [Icon(Icons.self_improvement, color: Colors.indigo, size: 24), SizedBox(width: 8), Text('Istirahat')])),
                  ],
                  onChanged: (val) => selectedIcon = val ?? 'sun',
                  decoration: const InputDecoration(labelText: 'Icon'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (timeController.text.isNotEmpty && nameController.text.isNotEmpty) {
                  Navigator.pop(context, Activity(
                    time: timeController.text,
                    name: nameController.text,
                    description: descController.text,
                    icon: selectedIcon,
                  ));
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      final newActivities = List<Activity>.from(activities);
      if (editIndex != null) {
        newActivities[editIndex] = result;
      } else {
        newActivities.add(result);
      }
      final updatedProfile = UserProfile(
        name: profile.name,
        photoPath: profile.photoPath,
        email: profile.email,
        phone: profile.phone,
        address: profile.address,
        bio: profile.bio,
        skills: profile.skills,
        education: profile.education,
        experiences: profile.experiences,
        hobbies: profile.hobbies,
        instagram: profile.instagram,
        characteristics: profile.characteristics,
        activities: newActivities,
        characteristicsLabel: profile.characteristicsLabel,
      );
      await UserProfileStorage.saveUserProfile(updatedProfile);
      setState(() {
        _profileFuture = UserProfileStorage.loadUserProfile();
      });
    }
  }

  void _deleteActivity(int index, List<Activity> activities, UserProfile profile) async {
    final newActivities = List<Activity>.from(activities)..removeAt(index);
    final updatedProfile = UserProfile(
      name: profile.name,
      photoPath: profile.photoPath,
      email: profile.email,
      phone: profile.phone,
      address: profile.address,
      bio: profile.bio,
      skills: profile.skills,
      education: profile.education,
      experiences: profile.experiences,
      hobbies: profile.hobbies,
      instagram: profile.instagram,
      characteristics: profile.characteristics,
      activities: newActivities,
      characteristicsLabel: profile.characteristicsLabel,
    );
    await UserProfileStorage.saveUserProfile(updatedProfile);
    setState(() {
      _profileFuture = UserProfileStorage.loadUserProfile();
    });
  }
} 