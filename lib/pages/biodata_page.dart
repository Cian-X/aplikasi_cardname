import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../user_profile_storage.dart';
import 'edit_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class BiodataPage extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final ThemeMode? currentThemeMode;
  const BiodataPage({Key? key, this.onThemeToggle, this.currentThemeMode}) : super(key: key);

  @override
  State<BiodataPage> createState() => _BiodataPageState();
}

class _BiodataPageState extends State<BiodataPage> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = UserProfileStorage.loadUserProfile();
  }

  Future<void> _editProfile(UserProfile profile) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(initialProfile: profile),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _loadProfile();
      });
    }
  }

  Future<void> _pickProfilePhoto(UserProfile profile) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final updatedProfile = UserProfile(
        name: profile.name,
        photoPath: picked.path,
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
        activities: profile.activities,
        characteristicsLabel: profile.characteristicsLabel,
      );
      await UserProfileStorage.saveUserProfile(updatedProfile);
      if (!mounted) return;
      setState(() {
        _loadProfile();
      });
    }
  }

  void _editCharacteristicsAndLabel(UserProfile profile) async {
    final characteristics = Map<String, double>.from(profile.characteristics);
    final controllers = <String, TextEditingController>{};
    final nameControllers = <String, TextEditingController>{};
    characteristics.forEach((key, value) {
      controllers[key] = TextEditingController(text: (value * 100).toInt().toString());
      nameControllers[key] = TextEditingController(text: key);
    });
    final labelController = TextEditingController(text: profile.characteristicsLabel);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Karakteristik'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(labelText: 'Judul/Label'),
                    ),
                    const SizedBox(height: 16),
                    ...characteristics.keys.map((key) => Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: nameControllers[key],
                                decoration: const InputDecoration(labelText: 'Label'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: controllers[key],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(suffixText: '%', labelText: 'Nilai'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Hapus',
                              onPressed: () {
                                setStateDialog(() {
                                  characteristics.remove(key);
                                  controllers.remove(key);
                                  nameControllers.remove(key);
                                });
                              },
                            ),
                          ],
                        )),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final newKey = 'Skill Baru';
                        int i = 1;
                        String label = newKey;
                        while (characteristics.containsKey(label)) {
                          label = '$newKey $i';
                          i++;
                        }
                        setStateDialog(() {
                          characteristics[label] = 1.0;
                          controllers[label] = TextEditingController(text: '100');
                          nameControllers[label] = TextEditingController(text: label);
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah'),
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
                  onPressed: () async {
                    final updated = <String, double>{};
                    for (final key in characteristics.keys) {
                      final label = nameControllers[key]?.text.trim() ?? key;
                      final val = double.tryParse(controllers[key]?.text ?? '0');
                      if (label.isNotEmpty) {
                        updated[label] = (val != null) ? (val.clamp(0, 100) / 100) : 0.0;
                      }
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
                      characteristics: updated,
                      activities: profile.activities,
                      characteristicsLabel: labelController.text.trim(),
                    );
                    await UserProfileStorage.saveUserProfile(updatedProfile);
                    if (!mounted) return;
                    setState(() { _loadProfile(); });
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _safeLaunchUrl(Uri uri, String errorMessage, {String? fallbackCopy}) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (fallbackCopy != null) {
          await Clipboard.setData(ClipboardData(text: fallbackCopy));
          _showLaunchError(context, '$errorMessage\nTeks disalin ke clipboard.');
        } else {
          _showLaunchError(context, errorMessage);
        }
      }
    } catch (e) {
      if (fallbackCopy != null) {
        await Clipboard.setData(ClipboardData(text: fallbackCopy));
        _showLaunchError(context, '$errorMessage\nTeks disalin ke clipboard.');
      } else {
        _showLaunchError(context, errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);

    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final profile = snapshot.data ?? UserProfile.empty();
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 48.0 : 16.0,
                  vertical: 32.0,
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withAlpha(30),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: isLargeScreen ? 96 : 64,
                                backgroundImage: profile.photoPath.isNotEmpty
                                    ? Image.file(
                                        File(profile.photoPath),
                                        fit: BoxFit.cover,
                                      ).image
                                        : const AssetImage('assets/images/default_avatar.png'),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _pickProfilePhoto(profile),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          profile.name.isNotEmpty ? profile.name : 'Nama Belum Diisi',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.bio.isNotEmpty ? profile.bio : 'Belum ada bio',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        if (isLargeScreen)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildInfoCard(context, profile)),
                              const SizedBox(width: 24),
                              Expanded(child: _buildCharacteristicsCard(context, profile)),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildInfoCard(context, profile),
                              const SizedBox(height: 24),
                              _buildCharacteristicsCard(context, profile),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Informasi Pribadi',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.map, 'Alamat', profile.address.isNotEmpty ? profile.address : 'Belum diisi'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.mark_email_read, 'Email', profile.email.isNotEmpty ? profile.email : 'Belum diisi'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone_android, 'Telepon', profile.phone.isNotEmpty ? profile.phone : 'Belum diisi'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.workspace_premium, 'Pendidikan', profile.education.isNotEmpty ? profile.education.last.schoolName : 'Belum diisi'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.interests, 'Hobby', profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : 'Belum diisi'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.alternate_email, 'Instagram', profile.instagram.isNotEmpty ? profile.instagram : 'Belum diisi'),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profil',
              onPressed: () => _editProfile(profile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsCard(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    final characteristics = profile.characteristics;

    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      profile.characteristicsLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (characteristics.isEmpty)
                  Text(
                    'Kosong',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  ...characteristics.entries.map((char) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            char.key,
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            '${(char.value * 100).toInt()}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: char.value,
                        backgroundColor: theme.colorScheme.primary.withAlpha(10),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                    ],
                  )).toList(),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Karakteristik',
              onPressed: () => _editCharacteristicsAndLabel(profile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    void Function()? onTap;
    TextStyle? valueStyle;
    if (label == 'Email' && value != 'Belum diisi') {
      final uri = Uri(scheme: 'mailto', path: value);
      onTap = () {
        _safeLaunchUrl(uri, 'Tidak bisa membuka email.', fallbackCopy: value);
      };
      valueStyle = const TextStyle(
        color: Colors.blue,
      );
    } else if (label == 'Telepon' && value != 'Belum diisi') {
      final uri = Uri(scheme: 'tel', path: value);
      onTap = () {
        _safeLaunchUrl(uri, 'Tidak bisa membuka telepon.', fallbackCopy: value);
      };
      valueStyle = const TextStyle(
        color: Colors.blue,
      );
    } else if (label == 'Instagram' && value != 'Belum diisi') {
      String username = value.trim();
      if (username.startsWith('@')) username = username.substring(1);
      final url = username.startsWith('http') ? username : 'https://instagram.com/$username';
      final uri = Uri.parse(url);
      onTap = () {
        _safeLaunchUrl(uri, 'Tidak bisa membuka Instagram.', fallbackCopy: url);
      };
      valueStyle = const TextStyle(
        color: Colors.blue,
      );
    }
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.indigo),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLaunchError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
} 