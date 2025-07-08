import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../user_profile_storage.dart';

class PengalamanPage extends StatefulWidget {
  const PengalamanPage({super.key});

  @override
  State<PengalamanPage> createState() => _PengalamanPageState();
}

class _PengalamanPageState extends State<PengalamanPage> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = UserProfileStorage.loadUserProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = UserProfileStorage.loadUserProfile();
    });
  }

  void _addOrEditExperience({Experience? experience, required List<Experience> experiences, required UserProfile profile, int? editIndex}) async {
    final titleController = TextEditingController(text: experience?.title ?? '');
    final companyController = TextEditingController(text: experience?.company ?? '');
    final yearController = TextEditingController(text: experience?.year ?? '');
    final descController = TextEditingController(text: experience?.description ?? '');
    final result = await showDialog<Experience>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(experience == null ? 'Tambah Pengalaman' : 'Edit Pengalaman'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Posisi/Jabatan'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: 'Perusahaan/Organisasi'),
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
                  maxLines: 2,
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
                if (titleController.text.isNotEmpty && companyController.text.isNotEmpty) {
                  Navigator.pop(context, Experience(
                    title: titleController.text,
                    company: companyController.text,
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
      final newExperiences = List<Experience>.from(experiences);
      if (editIndex != null) {
        newExperiences[editIndex] = result;
      } else {
        newExperiences.add(result);
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
        experiences: newExperiences,
        hobbies: profile.hobbies,
        instagram: profile.instagram,
        characteristics: profile.characteristics,
        activities: profile.activities,
        characteristicsLabel: profile.characteristicsLabel,
      );
      await UserProfileStorage.saveUserProfile(updatedProfile);
      _refreshProfile();
    }
  }

  void _deleteExperience(int index, List<Experience> experiences, UserProfile profile) async {
    final newExperiences = List<Experience>.from(experiences)..removeAt(index);
    final updatedProfile = UserProfile(
      name: profile.name,
      photoPath: profile.photoPath,
      email: profile.email,
      phone: profile.phone,
      address: profile.address,
      bio: profile.bio,
      skills: profile.skills,
      education: profile.education,
      experiences: newExperiences,
      hobbies: profile.hobbies,
      instagram: profile.instagram,
      characteristics: profile.characteristics,
      activities: profile.activities,
      characteristicsLabel: profile.characteristicsLabel,
    );
    await UserProfileStorage.saveUserProfile(updatedProfile);
    _refreshProfile();
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
          final pengalaman = profile.experiences;
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
                    icon: const Icon(Icons.add),
                    tooltip: 'Tambah Pengalaman',
                    onPressed: () => _addOrEditExperience(experiences: pengalaman, profile: profile),
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
                              itemCount: pengalaman.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    _buildExperienceCard(context, pengalaman[index], profile),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'Edit',
                                            onPressed: () => _addOrEditExperience(experience: pengalaman[index], experiences: pengalaman, profile: profile, editIndex: index),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            tooltip: 'Hapus',
                                            onPressed: () => _deleteExperience(index, pengalaman, profile),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : ListView.separated(
                              itemCount: pengalaman.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    _buildExperienceCard(context, pengalaman[index], profile),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'Edit',
                                            onPressed: () => _addOrEditExperience(experience: pengalaman[index], experiences: pengalaman, profile: profile, editIndex: index),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            tooltip: 'Hapus',
                                            onPressed: () => _deleteExperience(index, pengalaman, profile),
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

  Widget _buildExperienceCard(BuildContext context, Experience item, UserProfile profile) {
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
                      child: Icon(Icons.work, color: Colors.indigo, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
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
                  item.company,
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
                onPressed: () => _addOrEditExperience(experience: item, experiences: profile.experiences, profile: profile, editIndex: profile.experiences.indexOf(item)),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Hapus',
                onPressed: () => _deleteExperience(profile.experiences.indexOf(item), profile.experiences, profile),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 