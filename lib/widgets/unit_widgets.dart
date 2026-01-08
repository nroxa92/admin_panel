// FILE: lib/widgets/unit_widgets.dart
// OPIS: Unit-related widgets extracted from dashboard_screen.dart
// SADRŽAJ:
//   - UnitStatusMixin (print menu, delete, signature helpers)
//   - UnitStatusCard (grid view - currently unused but kept)
//   - UnitListItem (list view - used in LiveMonitorView)
//   - UnitDialog (CRUD dialog for units)
//   - PrintOptionRow (helper widget)

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../services/units_service.dart';
import '../services/booking_service.dart';
import '../services/pdf_service.dart';
import '../services/cleaning_service.dart';
import '../services/settings_service.dart';
import '../providers/app_provider.dart';
import '../models/unit_model.dart';
import '../models/booking_model.dart';
import '../models/cleaning_log_model.dart';

// =====================================================
// EDIT UNIT DIALOG - StatelessWidget verzija za produkciju
// =====================================================
class EditUnitDialog extends StatelessWidget {
  final Unit unitToEdit;

  const EditUnitDialog({super.key, required this.unitToEdit});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final primaryColor = provider.primaryColor;

    final wifiNameCtrl = TextEditingController(text: unitToEdit.wifiSsid);
    final wifiPassCtrl = TextEditingController(text: unitToEdit.wifiPass);
    final reviewLinkCtrl = TextEditingController(text: unitToEdit.reviewLink);

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Edit Unit", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Read-only: Unit ID
              _buildLockedField("Unit ID", unitToEdit.id),
              const SizedBox(height: 10),
              // Read-only: Zona
              _buildLockedField("Zona", unitToEdit.category ?? "Bez zone"),
              const SizedBox(height: 10),
              // Read-only: Name
              _buildLockedField("Name", unitToEdit.name),
              const SizedBox(height: 10),
              // Read-only: Address
              _buildLockedField("Address", unitToEdit.address),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Editable Fields:",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // WiFi SSID
              TextFormField(
                controller: wifiNameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "WiFi SSID",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              // WiFi Pass
              TextFormField(
                controller: wifiPassCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "WiFi Pass",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              // Review Link
              TextFormField(
                controller: reviewLinkCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Review Link (Optional)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // DELETE - identično kao SAVE, sve inline
        TextButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Text("Delete Unit",
                    style: TextStyle(color: Colors.white)),
                content: Text(
                  "Jeste li sigurni da želite obrisati '${unitToEdit.name}'?",
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(c, true),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("DELETE",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              try {
                await UnitsService().deleteUnit(unitToEdit.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Unit deleted!"),
                        backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Error: $e"),
                        backgroundColor: Colors.red),
                  );
                }
              }
            }
          },
          child: const Text("DELETE",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
        // Cancel
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        // SAVE
        ElevatedButton(
          onPressed: () async {
            try {
              final unit = Unit(
                id: unitToEdit.id,
                ownerId: unitToEdit.ownerId,
                ownerEmail: unitToEdit.ownerEmail,
                name: unitToEdit.name,
                address: unitToEdit.address,
                wifiSsid: wifiNameCtrl.text.trim(),
                wifiPass: wifiPassCtrl.text.trim(),
                cleanerPin: unitToEdit.cleanerPin,
                reviewLink: reviewLinkCtrl.text.trim(),
                contactOptions: unitToEdit.contactOptions,
                category: unitToEdit.category,
                createdAt: unitToEdit.createdAt,
              );
              await UnitsService().saveUnit(unit);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Unit updated!"),
                      backgroundColor: Colors.green),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: const Text("SAVE",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildLockedField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper funkcija za pozivanje dialoga
void showEditUnitDialog(BuildContext context, Unit unitToEdit) {
  showDialog(
    context: context,
    builder: (ctx) => EditUnitDialog(unitToEdit: unitToEdit),
  );
}

// =====================================================
// UNIT STATUS MIXIN
// Shared logic for UnitStatusCard and UnitListItem
// =====================================================
mixin UnitStatusMixin {
  DateTime stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // =====================================================
  // DELETE UNIT LOGIC
  // =====================================================
  Future<void> deleteUnitLogic(BuildContext context, Unit unit) async {
    final t = context.read<AppProvider>().translate;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title:
            Text(t('btn_delete'), style: const TextStyle(color: Colors.white)),
        content: Text("${t('msg_confirm_delete')}\n${unit.name}",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t('btn_cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("DELETE",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) {
        return;
      }
      await UnitsService().deleteUnit(unit.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Unit deleted"), backgroundColor: Colors.red));
      }
    }
  }

  // =====================================================
  // GET LATEST SIGNATURE FROM FIRESTORE
  // =====================================================
  Future<Map<String, dynamic>?> _getLatestSignature(
      String unitId, String bookingId) async {
    try {
      // Query signatures collection for this unit and booking
      final querySnapshot = await FirebaseFirestore.instance
          .collection('signatures')
          .where('unit_id', isEqualTo: unitId)
          .where('booking_id', isEqualTo: bookingId)
          .orderBy('signed_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }

      // Fallback: try without booking_id (for old signatures)
      final fallbackQuery = await FirebaseFirestore.instance
          .collection('signatures')
          .where('unit_id', isEqualTo: unitId)
          .orderBy('signed_at', descending: true)
          .limit(1)
          .get();

      if (fallbackQuery.docs.isNotEmpty) {
        return fallbackQuery.docs.first.data();
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching signature: $e');
      return null;
    }
  }

  // =====================================================
  // DOWNLOAD SIGNATURE IMAGE FROM URL
  // =====================================================
  Future<Uint8List?> _downloadSignatureImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout downloading signature');
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('Failed to download signature: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error downloading signature: $e');
      return null;
    }
  }

  // =====================================================
  // PRINT MENU (4 Options)
  // =====================================================
  void showPrintMenuLogic(
      BuildContext context, Unit unit, Booking? activeBooking) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text("Print Options: ${unit.name}",
            style: const TextStyle(color: Colors.white)),
        children: [
          // 1. eVISITOR
          SimpleDialogOption(
            child: const PrintOptionRow(
                icon: Icons.people,
                text: "1. eVisitor List",
                color: Colors.blue),
            onPressed: () async {
              Navigator.pop(ctx);
              if (activeBooking == null) {
                _snack(context, "No active booking for guest list.");
                return;
              }
              final guests =
                  await BookingService().getGuestsOnce(activeBooking.id);

              if (!context.mounted) {
                return;
              }
              if (guests.isNotEmpty) {
                PdfService.printEvisitorForm(unit.name, guests);
              } else {
                _snack(context, "No guests registered yet.");
              }
            },
          ),

          // 2. SIGNED HOUSE RULES
          SimpleDialogOption(
            child: const PrintOptionRow(
                icon: Icons.gavel,
                text: "2. Signed House Rules",
                color: Colors.orange),
            onPressed: () async {
              Navigator.pop(ctx);
              if (activeBooking == null) {
                _snack(context, "No active booking.");
                return;
              }

              // Show loading indicator
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text("Preparing PDF..."),
                      ],
                    ),
                    duration: Duration(seconds: 10),
                  ),
                );
              }

              try {
                // 1. Get settings for house rules text
                final settings =
                    await SettingsService().getSettingsStream().first;
                final appLanguage = settings.appLanguage;

                // Get house rules in app language, fallback to English
                String houseRulesText =
                    settings.houseRulesTranslations[appLanguage] ??
                        settings.houseRulesTranslations['en'] ??
                        'House rules not configured.';

                // 2. Get signature from Firestore
                final signatureData =
                    await _getLatestSignature(unit.id, activeBooking.id);

                Uint8List? signatureImage;
                String guestNameForPdf = activeBooking.guestName;

                if (signatureData != null) {
                  // Update guest name from signature if available
                  if (signatureData['guest_name'] != null) {
                    guestNameForPdf = signatureData['guest_name'];
                  }

                  // Try to get signature image
                  // First check for signature_url (new format - Firebase Storage)
                  if (signatureData['signature_url'] != null &&
                      signatureData['signature_url'].toString().isNotEmpty) {
                    signatureImage = await _downloadSignatureImage(
                        signatureData['signature_url']);
                  }
                  // Fallback to signature_image (old format - base64)
                  else if (signatureData['signature_image'] != null &&
                      signatureData['signature_image'].toString().isNotEmpty) {
                    try {
                      String base64String =
                          signatureData['signature_image'].toString();
                      // Remove data URL prefix if present
                      if (base64String.contains(',')) {
                        base64String = base64String.split(',').last;
                      }
                      signatureImage =
                          Uint8List.fromList(base64Decode(base64String));
                    } catch (e) {
                      debugPrint('Error decoding base64 signature: $e');
                    }
                  }
                }

                // Hide loading snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }

                // 3. Print PDF
                if (context.mounted) {
                  PdfService.printHouseRules(
                    unit.name,
                    guestNameForPdf,
                    houseRulesText,
                    signatureImage,
                  );
                }
              } catch (e) {
                debugPrint('Error preparing House Rules PDF: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _snack(context, "Error preparing PDF: $e");
                }
              }
            },
          ),

          // 3. CLEANING LOG
          SimpleDialogOption(
            child: const PrintOptionRow(
                icon: Icons.cleaning_services,
                text: "3. Last Cleaning Report",
                color: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx);
              final log = await CleaningService().getLastLog(unit.id);

              if (!context.mounted) {
                return;
              }
              if (log != null) {
                final tasks = log.tasksCompleted.entries
                    .map((entry) => {
                          'name': entry.key,
                          'checked': entry.value,
                        })
                    .toList();

                PdfService.printCleaningReport(
                  unit.name,
                  log.cleanerName,
                  tasks,
                  log.notes,
                  null,
                );
              } else {
                _snack(context, "No cleaning logs found.");
              }
            },
          ),

          // 4. UNIT SCHEDULE
          SimpleDialogOption(
            child: const PrintOptionRow(
                icon: Icons.calendar_month,
                text: "4. Unit Schedule (30 Days)",
                color: Colors.purple),
            onPressed: () async {
              Navigator.pop(ctx);
              final bookings = await BookingService().getBookingsStream().first;
              if (!context.mounted) {
                return;
              }

              final unitBookings =
                  bookings.where((b) => b.unitId == unit.id).toList();
              PdfService.printUnitSchedule(unit, unitBookings);
            },
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}

// =====================================================
// PRINT OPTION ROW (Helper Widget)
// =====================================================
class PrintOptionRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const PrintOptionRow({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white))
      ]),
    );
  }
}

// =====================================================
// UNIT STATUS CARD (Grid View)
// Currently unused but kept for future use
// =====================================================
class UnitStatusCard extends StatelessWidget with UnitStatusMixin {
  final Unit unit;
  const UnitStatusCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    final cleaningService = CleaningService();
    final provider = context.watch<AppProvider>();
    final t = provider.translate;
    final isDark = provider.backgroundColor.computeLuminance() < 0.5;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final primaryColor = provider.primaryColor;

    return StreamBuilder<List<Booking>>(
      stream: bookingService.getBookingsStream(),
      builder: (context, snapshot) {
        Booking? activeBooking;
        Color statusColor = Colors.grey;
        String statusText = t('status_free');
        IconData statusIcon = Icons.night_shelter_outlined;

        String guestName = "---";
        String period = "---";
        String pax = "-";

        bool isCheckoutToday = false;

        if (snapshot.hasData) {
          final now = DateTime.now();
          final today = stripTime(now);

          try {
            activeBooking = snapshot.data!.firstWhere((b) {
              if (b.unitId != unit.id) return false;
              final start = stripTime(b.startDate);
              final end = stripTime(b.endDate);
              return (today.isAfter(start) || today.isAtSameMomentAs(start)) &&
                  (today.isBefore(end) || today.isAtSameMomentAs(end));
            });

            guestName = activeBooking.guestName;
            period =
                "${DateFormat('dd.MM.').format(activeBooking.startDate)} ${activeBooking.checkInTime} - ${DateFormat('dd.MM.').format(activeBooking.endDate)} ${activeBooking.checkOutTime}";
            pax = "${activeBooking.guestCount} pax";

            if (activeBooking.isScanned) {
              statusColor = Colors.green;
              statusText = "SCANNED";
              statusIcon = Icons.check_circle;
            } else {
              if (stripTime(activeBooking.startDate).isAtSameMomentAs(today)) {
                statusColor = Colors.red;
                statusText = "CHECK-IN";
                statusIcon = Icons.warning;
              } else if (today.isBefore(stripTime(activeBooking.startDate))) {
                statusColor = Colors.blue;
                statusText = "COMING";
                statusIcon = Icons.access_time;
              } else {
                statusColor = Colors.red;
                statusText = "MISSING DOCS";
                statusIcon = Icons.error;
              }
            }

            if (stripTime(activeBooking.endDate).isAtSameMomentAs(today)) {
              isCheckoutToday = true;
            }
          } catch (e) {
            activeBooking = null;
          }
        }

        return StreamBuilder<List<CleaningLog>>(
          stream: cleaningService.getLogsForUnit(unit.id),
          builder: (context, logSnap) {
            Color broomColor = Colors.grey;
            String broomText = "Occupied";

            bool cleanedToday = false;
            if (logSnap.hasData && logSnap.data!.isNotEmpty) {
              final lastLog = logSnap.data!.first;
              if (stripTime(lastLog.timestamp)
                  .isAtSameMomentAs(stripTime(DateTime.now()))) {
                cleanedToday = true;
              }
            }

            if (activeBooking == null) {
              broomColor = Colors.green;
              broomText = "Ready";
            } else {
              if (isCheckoutToday) {
                if (cleanedToday) {
                  broomColor = Colors.green;
                  broomText = "Cleaned";
                } else {
                  broomColor = Colors.red;
                  broomText = "Checkout";
                }
              } else {
                broomColor = Colors.grey;
                broomText = "Occupied";
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  // HEADER (ID + Name + Statuses)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(unit.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor),
                                  overflow: TextOverflow.ellipsis),
                              Text(unit.id,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: textColor.withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                        // ICONS ROW
                        Row(
                          children: [
                            Tooltip(
                              message: broomText,
                              child: Icon(Icons.cleaning_services,
                                  size: 20, color: broomColor),
                            ),
                            const SizedBox(width: 10),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    Icon(statusIcon,
                                        size: 10, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(statusText,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),

                  // BODY
                  Expanded(
                    child: Center(
                      child: activeBooking == null
                          ? Text("NO GUESTS",
                              style: TextStyle(
                                  color: Colors.grey.withValues(alpha: 0.3),
                                  fontWeight: FontWeight.bold))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(guestName,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor)),
                                const SizedBox(height: 5),
                                Text(period,
                                    style: TextStyle(
                                        fontSize: 12, color: primaryColor)),
                                Text(pax,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            textColor.withValues(alpha: 0.6))),
                              ],
                            ),
                    ),
                  ),

                  const Divider(height: 1),

                  // FOOTER GUMBI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionBtn(Icons.edit, t('btn_edit'), Colors.grey,
                          () => _editUnit(context, unit)),
                      Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.withValues(alpha: 0.1)),
                      _actionBtn(
                          Icons.print,
                          t('btn_print'),
                          Colors.blue,
                          () =>
                              showPrintMenuLogic(context, unit, activeBooking)),
                      Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.withValues(alpha: 0.1)),
                      _actionBtn(Icons.delete, t('btn_delete'), Colors.red,
                          () => deleteUnitLogic(context, unit)),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editUnit(BuildContext context, Unit unit) {
    showEditUnitDialog(context, unit);
  }

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: color))
        ]),
      ),
    );
  }
}

// =====================================================
// UNIT LIST ITEM (List View)
// Used in LiveMonitorView
// =====================================================
class UnitListItem extends StatelessWidget with UnitStatusMixin {
  final Unit unit;
  const UnitListItem({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    final cleaningService = CleaningService();
    final provider = context.watch<AppProvider>();
    final isDark = provider.backgroundColor.computeLuminance() < 0.5;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final primaryColor = provider.primaryColor;

    return StreamBuilder<List<Booking>>(
      stream: bookingService.getBookingsStream(),
      builder: (context, snapshot) {
        Booking? activeBooking;
        Color statusColor = Colors.grey;
        String statusText = "FREE";
        IconData statusIcon = Icons.circle_outlined;

        String guestName = "---";
        String period = "";
        String pax = "";

        bool isCheckoutToday = false;

        if (snapshot.hasData) {
          final today = stripTime(DateTime.now());
          try {
            activeBooking = snapshot.data!.firstWhere((b) {
              if (b.unitId != unit.id) return false;
              final start = stripTime(b.startDate);
              final end = stripTime(b.endDate);
              return (today.isAfter(start) || today.isAtSameMomentAs(start)) &&
                  (today.isBefore(end) || today.isAtSameMomentAs(end));
            });

            guestName = activeBooking.guestName;
            period =
                "${DateFormat('dd.MM.').format(activeBooking.startDate)} ${activeBooking.checkInTime} - ${DateFormat('dd.MM.').format(activeBooking.endDate)} ${activeBooking.checkOutTime}";
            pax = "${activeBooking.guestCount} pax";

            if (activeBooking.isScanned) {
              statusColor = Colors.green;
              statusText = "SCANNED";
              statusIcon = Icons.check_circle;
            } else {
              if (stripTime(activeBooking.startDate).isAtSameMomentAs(today)) {
                statusColor = Colors.red;
                statusText = "CHECK-IN";
                statusIcon = Icons.warning;
              } else if (today.isBefore(stripTime(activeBooking.startDate))) {
                statusColor = Colors.blue;
                statusText = "COMING";
                statusIcon = Icons.access_time;
              } else {
                statusColor = Colors.red;
                statusText = "DOCS?";
                statusIcon = Icons.error;
              }
            }
            if (stripTime(activeBooking.endDate).isAtSameMomentAs(today)) {
              isCheckoutToday = true;
            }
          } catch (e) {
            activeBooking = null;
          }
        }

        return StreamBuilder<List<CleaningLog>>(
          stream: cleaningService.getLogsForUnit(unit.id),
          builder: (context, logSnap) {
            Color broomColor = Colors.grey;
            if (logSnap.hasData && logSnap.data!.isNotEmpty) {
              if (stripTime(logSnap.data!.first.timestamp)
                  .isAtSameMomentAs(stripTime(DateTime.now()))) {
                // Cleaned today
              }
            }
            if (activeBooking == null) {
              broomColor = Colors.green;
            } else if (isCheckoutToday) {
              broomColor = Colors.red;
            }

            return Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: statusColor, width: 4)),
              ),
              child: Row(
                children: [
                  // 1. NAZIV & STATUS
                  Expanded(
                    flex: 3,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(unit.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor)),
                          Row(children: [
                            Icon(statusIcon, size: 10, color: statusColor),
                            const SizedBox(width: 4),
                            Text(statusText,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: statusColor,
                                    fontWeight: FontWeight.bold))
                          ])
                        ]),
                  ),

                  // 2. GOST PODACI
                  Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guestName,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                          if (activeBooking != null) ...[
                            const SizedBox(height: 2),
                            Text(period,
                                style: TextStyle(
                                    color: primaryColor, fontSize: 11)),
                            Text(pax,
                                style: TextStyle(
                                    color: textColor.withValues(alpha: 0.6),
                                    fontSize: 10)),
                          ]
                        ],
                      )),

                  // 3. ICONS & GUMBI
                  Icon(Icons.cleaning_services, color: broomColor, size: 18),
                  const SizedBox(width: 15),
                  IconButton(
                      icon: const Icon(Icons.print, size: 20),
                      onPressed: () =>
                          showPrintMenuLogic(context, unit, activeBooking)),
                  IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editUnit(context, unit)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editUnit(BuildContext context, Unit unit) {
    showEditUnitDialog(context, unit);
  }
}

// =====================================================
// UNIT DIALOG (CRUD) - Simplified version that works in production
// Features: Category support, Auto ID, Delete button
// =====================================================
class UnitDialog extends StatefulWidget {
  final Unit? unitToEdit;
  const UnitDialog({super.key, this.unitToEdit});

  @override
  State<UnitDialog> createState() => _UnitDialogState();
}

class _UnitDialogState extends State<UnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _wifiNameCtrl = TextEditingController();
  final _wifiPassCtrl = TextEditingController();
  final _reviewLinkCtrl = TextEditingController();

  bool _isLoading = false;
  String? _selectedCategory;
  List<String> _categories = [];
  String _ownerFirstName = '';
  String _ownerLastName = '';

  @override
  void initState() {
    super.initState();
    if (widget.unitToEdit != null) {
      final u = widget.unitToEdit!;
      _nameCtrl.text = u.name;
      _addrCtrl.text = u.address;
      _wifiNameCtrl.text = u.wifiSsid;
      _wifiPassCtrl.text = u.wifiPass;
      _reviewLinkCtrl.text = u.reviewLink;
      _selectedCategory = u.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _wifiNameCtrl.dispose();
    _wifiPassCtrl.dispose();
    _reviewLinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = UnitsService();
      final isEdit = widget.unitToEdit != null;

      String unitId;
      if (isEdit) {
        unitId = widget.unitToEdit!.id;
      } else {
        unitId = await service.generateUnitId(
          ownerFirstName: _ownerFirstName,
          ownerLastName: _ownerLastName,
          category: _selectedCategory,
          unitName: _nameCtrl.text.trim(),
        );
      }

      final unit = Unit(
        id: unitId,
        ownerId: '',
        ownerEmail: '',
        name: _nameCtrl.text.trim(),
        address: _addrCtrl.text.trim(),
        wifiSsid: _wifiNameCtrl.text.trim(),
        wifiPass: _wifiPassCtrl.text.trim(),
        cleanerPin: widget.unitToEdit?.cleanerPin ?? '',
        reviewLink: _reviewLinkCtrl.text.trim(),
        contactOptions: widget.unitToEdit?.contactOptions ?? {},
        category: _selectedCategory,
        createdAt: widget.unitToEdit?.createdAt,
      );

      await service.saveUnit(unit);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? "Unit updated!" : "Unit created: $unitId"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final unit = widget.unitToEdit;
    if (unit == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Delete Unit", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to delete '${unit.name}'?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await UnitsService().deleteUnit(unit.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Unit deleted"), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.unitToEdit != null;
    final provider = Provider.of<AppProvider>(context);
    final primaryColor = provider.primaryColor;

    // Load settings data
    final settings = provider.settings;
    _ownerFirstName = settings.ownerFirstName;
    _ownerLastName = settings.ownerLastName;
    _categories = List<String>.from(settings.categories);

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Text(
        isEdit ? "Edit Unit" : "New Unit",
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EDIT MODE - Read only fields
                if (isEdit) ...[
                  _staticField("Unit ID", widget.unitToEdit!.id),
                  const SizedBox(height: 10),
                  _staticField("Category", widget.unitToEdit!.categoryDisplay),
                  const SizedBox(height: 10),
                  _staticField("Name", widget.unitToEdit!.name),
                  const SizedBox(height: 10),
                  _staticField("Address", widget.unitToEdit!.address),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                ],

                // CREATE MODE - Editable fields
                if (!isEdit) ...[
                  // Category dropdown
                  const Text("Category",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2C2C2C),
                        hint: const Text("Bez zone",
                            style: TextStyle(color: Colors.white70)),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text("Bez zone",
                                style: TextStyle(color: Colors.white70)),
                          ),
                          ..._categories.map((cat) => DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat),
                              )),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _textField(_nameCtrl, "Unit Name *"),
                  const SizedBox(height: 10),
                  _textField(_addrCtrl, "Address *"),
                  const SizedBox(height: 10),
                ],

                // SHARED - WiFi and Review
                Row(
                  children: [
                    Expanded(
                        child: _textField(_wifiNameCtrl, "WiFi SSID",
                            required: false)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _textField(_wifiPassCtrl, "WiFi Pass",
                            required: false)),
                  ],
                ),
                const SizedBox(height: 10),
                _textField(_reviewLinkCtrl, "Review Link", required: false),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (isEdit)
          TextButton(
            onPressed: _isLoading ? null : _delete,
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2),
                )
              : Text(
                  isEdit ? "SAVE" : "CREATE",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _staticField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String label,
      {bool required = true}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      validator:
          required ? (v) => (v == null || v.isEmpty) ? "Required" : null : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
