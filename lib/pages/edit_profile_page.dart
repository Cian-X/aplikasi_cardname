import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../user_profile_storage.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile initialProfile;
  const EditProfilePage({Key? key, required this.initialProfile}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController bioController;
  late TextEditingController instagramController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialProfile.name);
    emailController = TextEditingController(text: widget.initialProfile.email);
    phoneController = TextEditingController(text: widget.initialProfile.phone);
    addressController = TextEditingController(text: widget.initialProfile.address);
    bioController = TextEditingController(text: widget.initialProfile.bio);
    instagramController = TextEditingController(text: widget.initialProfile.instagram);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final updatedProfile = UserProfile(
      name: nameController.text,
      photoPath: widget.initialProfile.photoPath,
      email: emailController.text,
      phone: phoneController.text,
      address: addressController.text,
      bio: bioController.text,
      skills: widget.initialProfile.skills,
      education: widget.initialProfile.education,
      experiences: widget.initialProfile.experiences,
      hobbies: widget.initialProfile.hobbies,
      instagram: instagramController.text,
      characteristics: widget.initialProfile.characteristics,
      activities: widget.initialProfile.activities,
      characteristicsLabel: widget.initialProfile.characteristicsLabel,
    );
    await UserProfileStorage.saveUserProfile(updatedProfile);
    if (mounted) Navigator.pop(context, updatedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telepon'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instagramController,
              decoration: const InputDecoration(labelText: 'Instagram'),
            ),
          ],
        ),
      ),
    );
  }
} 