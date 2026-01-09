// FILE: lib/screens/gallery_screen.dart
// STATUS: UPDATED - Added translations for UI strings

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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.read<AppProvider>().translate('msg_saved')),
            backgroundColor: Colors.green,
          ));
        }
      }
    } catch (e) {
      debugPrint("Error saving config: $e");
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
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _isUploading = true;
      _totalFiles = result.files.length;
      _uploadedFiles = 0;
    });

    final storage = FirebaseStorage.instance;
    final firestore = FirebaseFirestore.instance;

    for (var file in result.files) {
      if (file.bytes == null) continue;

      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final ref = storage.ref('screensaver/$tenantId/$fileName');

        await ref.putData(
          Uint8List.fromList(file.bytes!),
          SettableMetadata(contentType: 'image/${file.extension ?? 'jpeg'}'),
        );

        final url = await ref.getDownloadURL();

        await firestore.collection('screensaver_images').add({
          'ownerId': tenantId,
          'url': url,
          'path': ref.fullPath,
          'fileName': file.name,
          'uploadedAt': FieldValue.serverTimestamp(),
        });

        setState(() => _uploadedFiles++);
      } catch (e) {
        debugPrint("Upload error: $e");
      }
    }

    setState(() => _isUploading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Success: $_uploadedFiles/$_totalFiles uploaded."),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> _deleteImage(String docId, String path) async {
    final t = context.read<AppProvider>().translate;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('confirm_delete_image')),
        content: Text(t('msg_confirm_delete')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t('btn_cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t('btn_delete'),
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseStorage.instance.ref(path).delete();
      await FirebaseFirestore.instance
          .collection('screensaver_images')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t('image_deleted')), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void _showTransitionPreview(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<AppProvider>().translate('no_images')),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TransitionPreviewScreen(
          imageUrls: imageUrls,
          transitions: _selectedTransitions.toList(),
          duration: _slideDuration.toInt(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppProvider>().translate;
    final provider = context.watch<AppProvider>();
    final isDark = provider.backgroundColor.computeLuminance() < 0.5;
    final primaryColor = provider.primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return FutureBuilder<String?>(
      future: _getTenantId(),
      builder: (context, tenantSnapshot) {
        if (!tenantSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tenantId = tenantSnapshot.data!;

        return FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Text(t('gallery_title'),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor)),
                const SizedBox(height: 8),
                Text(t('gallery_subtitle'),
                    style: TextStyle(
                        color: textColor.withValues(alpha: 0.7), fontSize: 14)),
                const SizedBox(height: 30),

                // SETTINGS CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('screensaver_settings'),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor)),
                      const SizedBox(height: 20),

                      // DELAY SLIDER
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t('delay_before_start'),
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w500)),
                                Slider(
                                  value: _screensaverDelay,
                                  min: 30,
                                  max: 300,
                                  divisions: 27,
                                  activeColor: primaryColor,
                                  label:
                                      "${_screensaverDelay.toInt()} ${t('seconds')}",
                                  onChanged: (val) =>
                                      setState(() => _screensaverDelay = val),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                                "${_screensaverDelay.toInt()} ${t('seconds')}",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // SLIDE DURATION SLIDER
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t('slide_duration'),
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w500)),
                                Slider(
                                  value: _slideDuration,
                                  min: 3,
                                  max: 30,
                                  divisions: 27,
                                  activeColor: primaryColor,
                                  label:
                                      "${_slideDuration.toInt()} ${t('seconds')}",
                                  onChanged: (val) =>
                                      setState(() => _slideDuration = val),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                                "${_slideDuration.toInt()} ${t('seconds')}",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // TRANSITIONS
                      Text(t('transitions'),
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildTransitionCheckbox('fade', t('transition_fade'),
                              isDark, textColor, primaryColor),
                          _buildTransitionCheckbox(
                              'slide',
                              t('transition_slide'),
                              isDark,
                              textColor,
                              primaryColor),
                          _buildTransitionCheckbox('zoom', t('transition_zoom'),
                              isDark, textColor, primaryColor),
                          _buildTransitionCheckbox('kenburns', 'Ken Burns',
                              isDark, textColor, primaryColor),
                          _buildTransitionCheckbox(
                              'rotate',
                              t('transition_rotate'),
                              isDark,
                              textColor,
                              primaryColor),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // SAVE BUTTON
                      ElevatedButton.icon(
                        onPressed:
                            _isSavingConfig ? null : _saveScreensaverConfig,
                        icon: _isSavingConfig
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save),
                        label: Text(t('btn_save')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // GALLERY SECTION
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t('tab_gallery'),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                          Row(
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('screensaver_images')
                                    .where('ownerId', isEqualTo: tenantId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  }
                                  final imageUrls = snapshot.data!.docs
                                      .map((d) =>
                                          (d.data() as Map)['url'] as String)
                                      .toList();
                                  return ElevatedButton.icon(
                                    onPressed: () =>
                                        _showTransitionPreview(imageUrls),
                                    icon: const Icon(Icons.play_arrow),
                                    label: Text(t('btn_preview')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          primaryColor.withValues(alpha: 0.2),
                                      foregroundColor: primaryColor,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: _isUploading ? null : _uploadImages,
                                icon: _isUploading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Icon(Icons.upload),
                                label: Text(_isUploading
                                    ? "..."
                                    : t('btn_upload_images')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_isUploading) ...[
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: _totalFiles > 0
                              ? _uploadedFiles / _totalFiles
                              : 0,
                          backgroundColor: Colors.grey.withValues(alpha: 0.3),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                        const SizedBox(height: 5),
                        Text("${t('msg_loading')} $_uploadedFiles/$_totalFiles",
                            style: TextStyle(
                                color: textColor.withValues(alpha: 0.7),
                                fontSize: 12)),
                      ],
                      const SizedBox(height: 20),

                      // IMAGE GRID
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('screensaver_images')
                            .where('ownerId', isEqualTo: tenantId)
                            .orderBy('uploadedAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}",
                                    style: const TextStyle(color: Colors.red)));
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final docs = snapshot.data!.docs;
                          if (docs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(40),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Icon(Icons.image_not_supported,
                                      size: 60,
                                      color: textColor.withValues(alpha: 0.3)),
                                  const SizedBox(height: 10),
                                  Text(t('no_images'),
                                      style: TextStyle(
                                          color: textColor.withValues(
                                              alpha: 0.5))),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final url = data['url'] as String;
                              final path = data['path'] as String;

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                        if (progress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: progress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? progress
                                                        .cumulativeBytesLoaded /
                                                    progress.expectedTotalBytes!
                                                : null,
                                            color: primaryColor,
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.white54),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: InkWell(
                                      onTap: () => _deleteImage(doc.id, path),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red.withValues(alpha: 0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.delete,
                                            size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
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

// =====================================================
// TRANSITION PREVIEW SCREEN
// =====================================================
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

class _TransitionPreviewScreenState extends State<_TransitionPreviewScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _transitionIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _startSlideshow();
  }

  void _startSlideshow() {
    Future.delayed(Duration(seconds: widget.duration), () {
      if (!mounted) return;
      _controller.forward().then((_) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.imageUrls.length;
          _transitionIndex = (_transitionIndex + 1) % widget.transitions.length;
        });
        _controller.reset();
        _startSlideshow();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTransition = widget.transitions[_transitionIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "${currentTransition.toUpperCase()} | ${_currentIndex + 1}/${widget.imageUrls.length}",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return _buildTransitionWidget(currentTransition);
        },
      ),
    );
  }

  Widget _buildTransitionWidget(String transition) {
    final currentImage = Image.network(
      widget.imageUrls[_currentIndex],
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );

    final nextIndex = (_currentIndex + 1) % widget.imageUrls.length;
    final nextImage = Image.network(
      widget.imageUrls[nextIndex],
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );

    switch (transition) {
      case 'fade':
        return Stack(
          children: [
            currentImage,
            Opacity(opacity: _controller.value, child: nextImage),
          ],
        );

      case 'slide':
        return Stack(
          children: [
            Transform.translate(
              offset: Offset(
                  -MediaQuery.of(context).size.width * _controller.value, 0),
              child: currentImage,
            ),
            Transform.translate(
              offset: Offset(
                  MediaQuery.of(context).size.width * (1 - _controller.value),
                  0),
              child: nextImage,
            ),
          ],
        );

      case 'zoom':
        return Stack(
          children: [
            Transform.scale(
              scale: 1 + (_controller.value * 0.5),
              child: Opacity(
                opacity: 1 - _controller.value,
                child: currentImage,
              ),
            ),
            Transform.scale(
              scale: 0.5 + (_controller.value * 0.5),
              child: Opacity(
                opacity: _controller.value,
                child: nextImage,
              ),
            ),
          ],
        );

      case 'rotate':
        return Stack(
          children: [
            Transform.rotate(
              angle: _controller.value * 0.5,
              child: Opacity(
                opacity: 1 - _controller.value,
                child: currentImage,
              ),
            ),
            Transform.rotate(
              angle: -0.5 + (_controller.value * 0.5),
              child: Opacity(
                opacity: _controller.value,
                child: nextImage,
              ),
            ),
          ],
        );

      case 'kenburns':
        return Stack(
          children: [
            Transform.scale(
              scale: 1 + (_controller.value * 0.1),
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: 1 - _controller.value,
                child: currentImage,
              ),
            ),
            Transform.scale(
              scale: 1.1 - (_controller.value * 0.1),
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: _controller.value,
                child: nextImage,
              ),
            ),
          ],
        );

      default:
        return currentImage;
    }
  }
}
