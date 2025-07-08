import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../user_profile_storage.dart';

class RiwayatPendidikanPage extends StatefulWidget {
  const RiwayatPendidikanPage({super.key});

  @override
  State<RiwayatPendidikanPage> createState() => _RiwayatPendidikanPageState();
}

class _RiwayatPendidikanPageState extends State<RiwayatPendidikanPage> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = UserProfileStorage.loadUserProfile();
  }

  void _addOrEditEducation({Education? education, required List<Education> educations, required UserProfile profile, int? editIndex}) async {
    final levelController = TextEditingController(text: education?.level ?? '');
    final nameController = TextEditingController(text: education?.schoolName ?? '');
    final yearController = TextEditingController(text: education?.year ?? '');
    final descController = TextEditingController(text: education?.description ?? '');
    final result = await showDialog<Education>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(education == null ? 'Tambah Pendidikan' : 'Edit Pendidikan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: levelController,
                  decoration: const InputDecoration(labelText: 'Jenjang'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Sekolah'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Tahun'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
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
                if (levelController.text.isNotEmpty && nameController.text.isNotEmpty) {
                  Navigator.pop(context, Education(
                    level: levelController.text,
                    schoolName: nameController.text,
                    year: yearController.text,
                    description: descController.text,
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
      final newEducations = List<Education>.from(educations);
      if (editIndex != null) {
        newEducations[editIndex] = result;
      } else {
        newEducations.add(result);
      }
      final updatedProfile = UserProfile(
        name: profile.name,
        photoPath: profile.photoPath,
        email: profile.email,
        phone: profile.phone,
        address: profile.address,
        bio: profile.bio,
        skills: profile.skills,
        education: newEducations,
        experiences: profile.experiences,
        hobbies: profile.hobbies,
        instagram: profile.instagram,
        characteristics: profile.characteristics,
        characteristicsLabel: profile.characteristicsLabel,
        activities: profile.activities,
      );
      await UserProfileStorage.saveUserProfile(updatedProfile);
      setState(() {
        _profileFuture = UserProfileStorage.loadUserProfile();
      });
    }
  }

  void _deleteEducation(int index, List<Education> educations, UserProfile profile) async {
    final newEducations = List<Education>.from(educations)..removeAt(index);
    final updatedProfile = UserProfile(
      name: profile.name,
      photoPath: profile.photoPath,
      email: profile.email,
      phone: profile.phone,
      address: profile.address,
      bio: profile.bio,
      skills: profile.skills,
      education: newEducations,
      experiences: profile.experiences,
      hobbies: profile.hobbies,
      instagram: profile.instagram,
      characteristics: profile.characteristics,
      characteristicsLabel: profile.characteristicsLabel,
      activities: profile.activities,
    );
    await UserProfileStorage.saveUserProfile(updatedProfile);
    setState(() {
      _profileFuture = UserProfileStorage.loadUserProfile();
    });
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
          final pendidikan = profile.education;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 48.0 : 16.0,
              vertical: 24.0,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.add),
                    tooltip: 'Tambah Pendidikan',
                    onPressed: () => _addOrEditEducation(educations: pendidikan, profile: profile),
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
                              itemCount: pendidikan.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    _buildEducationCard(context, pendidikan[index]),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'Edit',
                                            onPressed: () => _addOrEditEducation(education: pendidikan[index], educations: pendidikan, profile: profile, editIndex: index),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            tooltip: 'Hapus',
                                            onPressed: () => _deleteEducation(index, pendidikan, profile),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : ListView.separated(
                              itemCount: pendidikan.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    _buildEducationCard(context, pendidikan[index]),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'Edit',
                                            onPressed: () => _addOrEditEducation(education: pendidikan[index], educations: pendidikan, profile: profile, editIndex: index),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            tooltip: 'Hapus',
                                            onPressed: () => _deleteEducation(index, pendidikan, profile),
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

  Widget _buildEducationCard(BuildContext context, Education item) {
    return Stack(
      children: [
        Card(
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
                        color: Theme.of(context).colorScheme.primary.withAlpha(128),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.school, color: Colors.indigo, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.level,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            item.year,
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
                  item.schoolName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () => _addOrEditEducation(education: item, educations: (ModalRoute.of(context)?.settings.arguments as UserProfile).education, profile: (ModalRoute.of(context)?.settings.arguments as UserProfile), editIndex: null),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Hapus',
                onPressed: () => _deleteEducation(0, (ModalRoute.of(context)?.settings.arguments as UserProfile).education, (ModalRoute.of(context)?.settings.arguments as UserProfile)),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 