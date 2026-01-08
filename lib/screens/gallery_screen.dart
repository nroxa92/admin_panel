// FILE: lib/screens/gallery_screen.dart
// STATUS: CLEAN - No ImageNetwork package, pure Flutter Image.network

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Future<String?> _getTenantId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final tokenResult = await user.getIdTokenResult();
    return tokenResult.claims?['ownerId'] as String?;
  }

  bool _isSavingConfig = false;
  double _screensaverDelay = 60;
  double _slideDuration = 10;
  Set<String> _selectedTransitions = {'fade'};

  bool _isUploading = false;
  int _totalFiles = 0;
  int _uploadedFiles = 0;

  @override
  void initState() {
    super.initState();
    _loadScreensaverConfig();
  }

  Future<void> _loadScreensaverConfig() async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('settings')
          .where('ownerId', isEqualTo: tenantId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        if (data.containsKey('screensaver_config')) {
          final config = data['screensaver_config'] as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              _screensaverDelay = (config['delay'] ?? 60).toDouble();
              _slideDuration = (config['duration'] ?? 10).toDouble();

              if (config['transitions'] != null) {
                _selectedTransitions =
                    Set<String>.from(config['transitions'] as List);
              } else if (config['transition'] != null) {
                _selectedTransitions = {config['transition'] as String};
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading config: $e");
    }
  }

  Future<void> _saveScreensaverConfig() async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return;

    setState(() => _isSavingConfig = true);
    try {
      final query = await FirebaseFirestore.instance
          .collection('settings')
          .where('ownerId', isEqualTo: tenantId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'screensaver_config': {
            'delay': _screensaverDelay.toInt(),
            'duration': _slideDuration.toInt(),
            'transitions': _selectedTransitions.toList(),
          }
        });
        if (mounted) {
          final provider = Provider.of<AppProvider>(context, listen: false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Screensaver configuration saved!"),
              backgroundColor: provider.primaryColor));
        }
      }
    } catch (e) {
      debugPrint("Save error: $e");
    } finally {
      if (mounted) setState(() => _isSavingConfig = false);
    }
  }

  Future<void> _uploadImages() async {
    final tenantId = await _getTenantId();

    if (tenantId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error: Tenant ID not found."),
            backgroundColor: Colors.red));
      }
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _isUploading = true;
        _totalFiles = result.files.length;
        _uploadedFiles = 0;
      });

      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;

      for (var file in result.files) {
        try {
          Uint8List? fileBytes = file.bytes;
          if (fileBytes == null) continue;

          String fileName =
              "screensaver/$tenantId/${DateTime.now().millisecondsSinceEpoch}_${file.name}";

          final ref = storage.ref().child(fileName);
          await ref.putData(
              fileBytes, SettableMetadata(contentType: 'image/jpeg'));
          String downloadUrl = await ref.getDownloadURL();

          await firestore.collection('gallery').add({
            'ownerId': tenantId,
            'url': downloadUrl,
            'path': fileName,
            'uploaded_at': FieldValue.serverTimestamp(),
            'type': 'screensaver',
          });

          if (mounted) {
            setState(() => _uploadedFiles++);
          }
        } catch (e) {
          debugPrint("Error uploading: $e");
        }
      }

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Success: $_uploadedFiles/$_totalFiles uploaded."),
            backgroundColor: Colors.green));
      }
    }
  }

  Future<void> _deleteImage(String docId, String path) async {
    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Image?"),
            content: const Text("This cannot be undone."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Delete",
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await FirebaseStorage.instance.ref().child(path).delete();
      await FirebaseFirestore.instance
          .collection('gallery')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Image deleted."), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void _showTransitionPreview(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Upload some images first!"),
          backgroundColor: Colors.orange));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _TransitionPreviewScreen(
          imageUrls: imageUrls,
          transitions: _selectedTransitions.toList(),
          duration: _slideDuration.toInt(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.translate;
    final primaryColor = provider.primaryColor;
    final backgroundColor = provider.backgroundColor;

    final isDark = backgroundColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);

    return FutureBuilder<String?>(
      future: _getTenantId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final tenantId = snapshot.data;

        return Scaffold(
          backgroundColor: backgroundColor,
          floatingActionButton: _isSavingConfig
              ? null
              : FloatingActionButton.extended(
                  onPressed: _saveScreensaverConfig,
                  backgroundColor: primaryColor,
                  label: Text(t('btn_save'),
                      style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold)),
                  icon: Icon(Icons.save,
                      color: isDark ? Colors.black : Colors.white),
                ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Gallery & Screensaver",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 10),
                Text("Upload images for tablet screensaver.",
                    style: TextStyle(color: textColor.withValues(alpha: 0.6))),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Screensaver Settings",
                          style: TextStyle(
                              color: primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Delay (seconds)",
                                    style: TextStyle(
                                        color:
                                            textColor.withValues(alpha: 0.7))),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: _screensaverDelay,
                                        min: 10,
                                        max: 300,
                                        divisions: 29,
                                        activeColor: primaryColor,
                                        label: "${_screensaverDelay.toInt()}s",
                                        onChanged: (val) => setState(
                                            () => _screensaverDelay = val),
                                      ),
                                    ),
                                    Text("${_screensaverDelay.toInt()}s",
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Slide Duration (seconds)",
                                    style: TextStyle(
                                        color:
                                            textColor.withValues(alpha: 0.7))),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: _slideDuration,
                                        min: 3,
                                        max: 60,
                                        divisions: 19,
                                        activeColor: primaryColor,
                                        label: "${_slideDuration.toInt()}s",
                                        onChanged: (val) => setState(
                                            () => _slideDuration = val),
                                      ),
                                    ),
                                    Text("${_slideDuration.toInt()}s",
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text("Transition Effects (select multiple)",
                          style: TextStyle(
                              color: textColor.withValues(alpha: 0.7))),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 15,
                        runSpacing: 10,
                        children: [
                          _buildTransitionCheckbox('fade', 'Cross Fade', isDark,
                              textColor, primaryColor),
                          _buildTransitionCheckbox('slide', 'Slide', isDark,
                              textColor, primaryColor),
                          _buildTransitionCheckbox(
                              'zoom', 'Zoom', isDark, textColor, primaryColor),
                          _buildTransitionCheckbox('kenburns', 'Ken Burns',
                              isDark, textColor, primaryColor),
                          _buildTransitionCheckbox(
                              'blur', 'Blur', isDark, textColor, primaryColor),
                        ],
                      ),
                      if (_selectedTransitions.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "Selected transitions will play in sequence",
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.grey),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Gallery Images",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    Row(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('gallery')
                              .where('ownerId', isEqualTo: tenantId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final imageUrls = snapshot.hasData
                                ? snapshot.data!.docs
                                    .map((doc) => (doc.data()
                                            as Map<String, dynamic>)['url']
                                        as String)
                                    .toList()
                                : <String>[];

                            return ElevatedButton.icon(
                              onPressed: imageUrls.isEmpty
                                  ? null
                                  : () => _showTransitionPreview(imageUrls),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                              ),
                              icon: const Icon(Icons.play_circle_outline),
                              label: Text(t('btn_preview')),
                            );
                          },
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _uploadImages,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor:
                                isDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                          icon: _isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.add_photo_alternate),
                          label: Text(
                              _isUploading ? "..." : t('btn_upload_images')),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _totalFiles > 0
                              ? _uploadedFiles / _totalFiles
                              : 0,
                          color: primaryColor,
                          backgroundColor: cardColor,
                        ),
                        const SizedBox(height: 10),
                        Text("Uploading: $_uploadedFiles/$_totalFiles",
                            style: TextStyle(
                                color: textColor.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('gallery')
                        .where('ownerId', isEqualTo: tenantId)
                        .orderBy('uploaded_at', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: Text("Error: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red)));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child:
                                CircularProgressIndicator(color: primaryColor));
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library_outlined,
                                  size: 64,
                                  color: textColor.withValues(alpha: 0.2)),
                              const SizedBox(height: 10),
                              Text("No images uploaded yet.",
                                  style: TextStyle(
                                      color: textColor.withValues(alpha: 0.5))),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final url = data['url'] ?? '';
                          final path = data['path'] ?? '';
                          final docId = docs[index].id;

                          return FadeInUp(
                            duration: const Duration(milliseconds: 300),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: borderColor),
                                    color: Colors.black,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.error,
                                              color: Colors.red, size: 32),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: InkWell(
                                    onTap: () => _deleteImage(docId, path),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withValues(alpha: 0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.delete_outline,
                                          size: 16, color: Colors.redAccent),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransitionCheckbox(String value, String label, bool isDark,
      Color textColor, Color primaryColor) {
    final isSelected = _selectedTransitions.contains(value);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            if (_selectedTransitions.length > 1) {
              _selectedTransitions.remove(value);
            }
          } else {
            _selectedTransitions.add(value);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.2)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : textColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color:
                  isSelected ? primaryColor : textColor.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransitionPreviewScreen extends StatefulWidget {
  final List<String> imageUrls;
  final List<String> transitions;
  final int duration;

  const _TransitionPreviewScreen({
    required this.imageUrls,
    required this.transitions,
    required this.duration,
  });

  @override
  State<_TransitionPreviewScreen> createState() =>
      _TransitionPreviewScreenState();
}

class _TransitionPreviewScreenState extends State<_TransitionPreviewScreen> {
  int _currentIndex = 0;
  int _transitionIndex = 0;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  void _startSlideshow() {
    Future.delayed(Duration(seconds: widget.duration), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.imageUrls.length;
          _transitionIndex = (_transitionIndex + 1) % widget.transitions.length;
        });
        _startSlideshow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTransition =
        widget.transitions[_transitionIndex % widget.transitions.length];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: Duration(seconds: (widget.duration * 0.3).toInt()),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                switch (currentTransition) {
                  case 'fade':
                    return FadeTransition(opacity: animation, child: child);
                  case 'slide':
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  case 'zoom':
                    return ScaleTransition(scale: animation, child: child);
                  case 'blur':
                    return FadeTransition(opacity: animation, child: child);
                  case 'kenburns':
                    return ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.2)
                          .animate(animation),
                      child: child,
                    );
                  default:
                    return FadeTransition(opacity: animation, child: child);
                }
              },
              child: Image.network(
                widget.imageUrls[_currentIndex],
                key: ValueKey(_currentIndex),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Transition: ${currentTransition.toUpperCase()} | ${_currentIndex + 1}/${widget.imageUrls.length}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
