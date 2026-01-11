// FILE: lib/config/translations/lang_de.dart
// LANGUAGE: German (DE) - Deutsch
// VERSION: 3.1.0 - Complete with all hardcoded strings covered
// DATE: 2026-01-11

class LangDE {
  static const Map<String, String> translations = {
    // =========================================================================
    // NAVIGATION
    // =========================================================================
    'nav_reception': 'Rezeption',
    'nav_calendar': 'Kalender',
    'nav_settings': 'Einstellungen',
    'nav_logout': 'Abmelden',

    // =========================================================================
    // DASHBOARD
    // =========================================================================
    'dash_title': 'Einheitenübersicht',
    'dash_subtitle': 'Gästestatus in Echtzeit',
    'status_free': 'FREI',
    'status_check_in': 'WARTET AUF CHECK-IN',
    'status_scanned': 'EINGECHECKT',
    'label_id': 'Einheiten-ID',
    'label_name': 'Einheitenname',
    'label_address': 'Adresse',
    'label_wifi_ssid': 'WiFi-Name',
    'label_wifi_pass': 'WiFi-Passwort',
    'label_cleaner_pin': 'Reiniger-PIN',
    'label_review_link': 'Bewertungslink',
    'label_unit': 'Einheit',
    'label_checkin': 'Anreise',
    'label_checkout': 'Abreise',
    'label_guests': 'Gäste',
    'label_guest_name': 'Gastname',
    'label_status': 'Status',
    'label_notes': 'Notizen',

    // =========================================================================
    // DIALOGS & BUTTONS
    // =========================================================================
    'dialog_new_unit': 'Neue Einheit',
    'dialog_edit_unit': 'Einheit Bearbeiten',
    'dialog_delete_unit': 'Einheit Löschen',
    'section_identification': 'Identifikation',
    'section_connectivity': 'Konnektivität',
    'section_operations': 'Betrieb',
    'btn_edit': 'Bearbeiten',
    'btn_print': 'Drucken',
    'btn_delete': 'Löschen',
    'btn_save': 'SPEICHERN',
    'btn_cancel': 'Abbrechen',
    'btn_close': 'Schließen',
    'btn_upload_images': 'Bilder Hochladen',
    'btn_preview': 'Vorschau',
    'btn_add_task': 'Aufgabe Hinzufügen',
    'btn_change': 'ÄNDERN',
    'btn_retry': 'Wiederholen',
    'btn_export': 'Exportieren',
    'btn_send': 'Senden',
    'btn_add': 'Hinzufügen',
    'btn_create': 'Erstellen',
    'btn_update': 'Aktualisieren',
    'btn_confirm': 'Bestätigen',
    'btn_got_it': 'VERSTANDEN',
    'btn_lock': 'Sperren',
    'btn_unlock': 'Entsperren',
    'btn_remove': 'Entfernen',
    'btn_activate': 'Aktivieren',
    'btn_deactivate': 'Deaktivieren',
    'msg_confirm_delete': 'Diese Einheit dauerhaft löschen?',

    // =========================================================================
    // SETTINGS - TABS
    // =========================================================================
    'tab_general': 'Allgemein',
    'tab_info': 'Info-Buch',
    'tab_gallery': 'Galerie',
    'tab_feedback': 'Feedback',

    // =========================================================================
    // SETTINGS - GENERAL
    // =========================================================================
    'header_personalization': 'Panel-Personalisierung',
    'label_language': 'Sprache',
    'label_theme_color': 'Themenfarbe',
    'label_bg_tone': 'Hintergrundton',
    'label_cleaner_pin_global': 'Globaler Reiniger-PIN',
    'label_reset_pin': 'Master Reset PIN',
    'header_password': 'Admin-Passwort Ändern',
    'label_current_password': 'Aktuelles Passwort',
    'label_new_password': 'Neues Passwort',
    'label_confirm_password': 'Passwort Bestätigen',

    // =========================================================================
    // SETTINGS - INFO BOOK
    // =========================================================================
    'header_digital_book': 'Inhalt & KI-Wissen',
    'digital_book_subtitle': 'Verwalten Sie für Gäste sichtbare Inhalte auf Tablets',
    'section_guest_info': '1. FÜR GÄSTE (Regeln & Info)',
    'section_cleaner_info': '2. FÜR REINIGER (Interne Liste)',
    'section_ai_knowledge': '3. LOKALES WISSEN (KI-Kontext)',
    'label_house_rules': 'Hausordnung (Übersetzungen)',
    'label_checklist_item': 'Aufgabe',
    'label_welcome_msg': 'Willkommensnachricht',
    'label_ai_concierge': 'Concierge-Wissen',
    'label_ai_housekeeper': 'Hauswirtschafts-Wissen',
    'label_ai_tech': 'Technisches Wissen',
    'label_ai_guide': 'Führer-Wissen',

    // =========================================================================
    // CALENDAR
    // =========================================================================
    'calendar_title': 'Buchungsplan',
    'sort_options': 'Sortieroptionen',
    'sort_by_name': 'Name',
    'sort_by_occupancy': 'Belegung',
    'sort_by_created': 'Erstellt',
    'sort_units': 'EINHEITEN',
    'sort_zones': 'ZONEN',
    'zone_none': 'Keine Zone',
    'new_zone': 'Neue Zone',
    'period_days': 'Tage',
    'period_all': 'ALLE',
    'tooltip_sort': 'Sortieroptionen',
    'tooltip_visibility': 'Zonensichtbarkeit',
    'tooltip_rotate': 'Ansicht Drehen',
    'tooltip_period': 'Zeitraum Wählen',
    'tooltip_print': 'Druckoptionen',
    'msg_booking_moved': 'Buchung erfolgreich verschoben!',
    'msg_booking_overlap': 'Verschieben nicht möglich - Termin belegt!',
    'day_today': 'HEUTE',
    'day_tomorrow': 'MORGEN',
    'check_ins': 'Check-ins',
    'check_outs': 'Check-outs',
    'no_activity': 'Keine Aktivität',
    'needs_cleaning': 'Reinigung Erforderlich',
    'cleaner_arrived': 'Reiniger Angekommen',
    'cleaning_done': 'Gereinigt',
    'hide_category': 'Kategorie ausblenden',
    'show_category': 'Kategorie anzeigen',
    'show_all': 'Alle Anzeigen',
    'hide_all': 'Alle Ausblenden',

    // =========================================================================
    // PRINT OPTIONS
    // =========================================================================
    'print_options': 'Druckoptionen',
    'print_evisitor': 'eVisitor Gescannte Daten',
    'print_house_rules': 'Unterschriebene Hausordnung',
    'print_cleaning_log': 'Reinigungsprotokoll',
    'print_unit_schedule': 'Einheitenplan (30 Tage)',
    'print_text_full': 'Textliste (Vollständig)',
    'print_text_anon': 'Textliste (Anonym)',
    'print_cleaning_sched': 'Reinigungsplan',
    'print_graphic_full': 'Grafische Ansicht (Vollständig)',
    'print_graphic_anon': 'Grafische Ansicht (Anonym)',
    'print_history': 'Buchungshistorie (Vollarchiv)',
    'print_all': 'Alles Drucken',
    'print_selected': 'Auswahl Drucken',

    // =========================================================================
    // BOOKING
    // =========================================================================
    'booking_details': 'Buchungsdetails',
    'guest_name': 'Gastname',
    'guest_count': 'Gäste',
    'check_in_date': 'Anreise',
    'check_out_date': 'Abreise',
    'nights': 'Nächte',
    'status': 'Status',
    'notes': 'Notizen',
    'new_booking': 'Neue Buchung',
    'edit_booking': 'Buchung Bearbeiten',
    'delete_booking': 'Buchung Löschen',
    'booking_saved': 'Buchung gespeichert!',
    'booking_deleted': 'Buchung gelöscht!',

    // =========================================================================
    // BOOKING STATUS (workflow states)
    // =========================================================================
    'status_confirmed': 'Bestätigt',
    'status_pending': 'Ausstehend',
    'status_checked_in': 'Eingecheckt',
    'status_checked_out': 'Ausgecheckt',
    'status_cancelled': 'Storniert',
    'status_blocked': 'Blockiert',
    'status_private': 'Privat',

    // =========================================================================
    // BOOKING SOURCE (platforms)
    // =========================================================================
    'label_source': 'Quelle',
    'source_manual': 'Manuell',
    'source_airbnb': 'Airbnb',
    'source_booking': 'Booking.com',
    'source_vrbo': 'VRBO',
    'source_expedia': 'Expedia',
    'source_private': 'Privat',
    'source_other': 'Sonstige',

    // =========================================================================
    // MESSAGES
    // =========================================================================
    'msg_no_guests': 'Noch keine registrierten Gäste.',
    'msg_no_booking': 'Keine aktive Buchung.',
    'msg_preparing_pdf': 'PDF wird vorbereitet...',
    'msg_error': 'Fehler',
    'msg_success': 'Erfolg',
    'msg_saved': 'Gespeichert!',
    'msg_deleted': 'Gelöscht!',
    'msg_loading': 'Lädt...',
    'msg_no_units': 'Keine Einheiten gefunden.',
    'msg_unit_created': 'Einheit erstellt!',
    'msg_unit_updated': 'Einheit aktualisiert!',
    'msg_unit_deleted': 'Einheit gelöscht!',
    'msg_confirm_zone': 'Neue Zone bestätigen oder abbrechen',
    'editable_fields': 'Bearbeitbare Felder:',
    'label_category': 'Kategorie',
    'hint_no_zone': 'Keine Zone',
    'msg_emergency_saved': 'Notfallkontakt gespeichert!',
    'msg_timers_saved': 'Timer gespeichert!',
    'msg_checklist_saved': 'Aufgabenliste gespeichert!',
    'msg_ai_saved': 'KI-Kontext gespeichert!',
    'msg_house_rules_missing': 'Hausordnung nicht konfiguriert.',
    'msg_no_cleaning_logs': 'Keine Reinigungsprotokolle gefunden.',
    'msg_export_ready': 'Export bereit!',
    'msg_export_failed': 'Export fehlgeschlagen',
    'msg_required_fields': 'Bitte füllen Sie alle erforderlichen Felder aus',
    'msg_email_required': 'E-Mail ist erforderlich',
    'msg_no_owners': 'Keine Eigentümer gefunden',

    // =========================================================================
    // THEMES
    // =========================================================================
    'theme_luxury': 'Luxus-Kollektion',
    'theme_neon': 'Neon / Tech',
    'theme_dark': 'Dunkle Themen',
    'theme_light': 'Helle Themen',

    // =========================================================================
    // ANALYTICS
    // =========================================================================
    'analytics_title': 'Gäste-Einblicke',
    'analytics_subtitle': 'Buchungsstatistiken und Gäste-Feedback',
    'bookings_this_month': 'Buchungen Diesen Monat',
    'bookings_this_year': 'Buchungen Dieses Jahr',
    'occupancy_rate': 'Belegungsrate',
    'avg_stay_nights': 'Durchschn. Aufenthalt',
    'recent_reviews': 'Aktuelle Bewertungen',
    'average_rating': 'Durchschnittsbewertung',
    'top_ai_questions': 'Häufigste KI-Fragen',
    'no_ai_questions': 'Noch keine KI-Fragen protokolliert.',
    'no_reviews': 'Noch keine Bewertungen.',
    'loading_data': 'Daten werden geladen...',

    // =========================================================================
    // REVENUE ANALYTICS
    // =========================================================================
    'revenue_section': 'Umsatzübersicht',
    'total_revenue': 'Gesamtumsatz',
    'revenue_this_month': 'Diesen Monat',
    'average_daily_rate': 'Durchschnittlicher Tagespreis',
    'total_nights_sold': 'Gesamte Verkaufte Nächte',
    'monthly_revenue_chart': 'Monatlicher Umsatz',
    'loading_revenue': 'Umsatzdaten werden geladen...',

    // =========================================================================
    // CALENDAR EXPORT
    // =========================================================================
    'calendar_export': 'Kalender-Export',
    'export_bookings_calendar': 'Buchungen Exportieren',
    'export_calendar_description': 'Exportieren Sie Buchungen in externe Kalender',
    'export_ical': 'iCal Exportieren',
    'add_to_calendar': 'Zum Kalender Hinzufügen',
    'ical_copied_clipboard': 'iCal-Daten kopiert!',
    'export_failed': 'Export fehlgeschlagen',
    'choose_calendar_app': 'Kalender-App Wählen',
    'open_in_browser': 'Im Browser Öffnen',
    'copy_ical_data': 'iCal-Daten Kopieren',
    'paste_in_any_calendar': 'In beliebige Kalender-App einfügen',
    'google_calendar_instructions': 'Google Kalender',
    'google_calendar_steps': 'Google Kalender öffnen → Einstellungen → Importieren',
    'outlook_instructions': 'Outlook',
    'outlook_steps': 'Datei → Öffnen & Exportieren → Importieren',

    // =========================================================================
    // SUPER ADMIN - GENERAL
    // =========================================================================
    'super_admin_title': 'Super Admin',
    'super_admin_access_denied': 'Sie haben keinen Super Admin Zugang',
    'super_admin_deactivated': 'Ihr Admin-Zugang wurde deaktiviert',

    // =========================================================================
    // SUPER ADMIN - OWNER MANAGEMENT
    // =========================================================================
    'create_new_owner': 'Neuen Eigentümer Erstellen',
    'new_owner': 'Neuer Eigentümer',
    'delete_owner': 'Eigentümer Löschen',
    'delete_owner_confirm': 'Eigentümer Löschen?',
    'owner_created': 'Eigentümer erstellt!',
    'owner_deleted': 'Eigentümer gelöscht',
    'temp_password': 'Temp. Passwort',
    'reset_password': 'Passwort Zurücksetzen',
    'new_password_generated': 'Neues Passwort',

    // =========================================================================
    // SUPER ADMIN - TABLET MANAGEMENT
    // =========================================================================
    'lock_all_tablets': 'Alle Tablets Sperren',
    'lock_all_tablets_confirm': 'Alle Tablets Sperren?',
    'unlock_tablet': 'Tablet Entsperren',
    'unlock_tablet_confirm': 'Tablet Entsperren?',
    'no_tablets_registered': 'Keine Tablets registriert',
    'tablets_online': 'online',
    'tablets_count': 'Tablets',
    'edit_tablet': 'Tablet Bearbeiten',
    'kiosk_settings': 'KIOSK-EINSTELLUNGEN',
    'exit_pin_label': 'Exit-PIN (6 Ziffern)',
    'pin_6_digits_required': 'PIN muss genau 6 Ziffern haben',
    'tablet_locked': 'Tablet gesperrt',
    'tablet_unlocked': 'Tablet entsperrt',
    'failed_to_lock': 'Sperren fehlgeschlagen',
    'failed_to_unlock': 'Entsperren fehlgeschlagen',

    // =========================================================================
    // SUPER ADMIN - NOTIFICATIONS
    // =========================================================================
    'notification_sent': 'Benachrichtigung gesendet!',
    'notification_deleted': 'Benachrichtigung gelöscht',
    'title_required': 'Titel und Nachricht sind erforderlich',
    'notification_type': 'Typ',
    'notification_recipients': 'Empfänger',
    'all_owners': 'Alle Eigentümer',
    'select_specific': 'Bestimmte Auswählen',
    'send_notification': 'Benachrichtigung Senden',
    'system_notification': 'Systembenachrichtigung',
    'no_notifications': 'Noch keine Benachrichtigungen gesendet',
    'notification_title': 'Titel',
    'notification_message': 'Nachricht',

    // =========================================================================
    // SUPER ADMIN - ADMIN MANAGEMENT
    // =========================================================================
    'add_super_admin': 'Super Admin Hinzufügen',
    'add_admin': 'Admin Hinzufügen',
    'admin_level': 'Admin-Stufe',
    'assigned_brand': 'Zugewiesene Marke',
    'select_brand': 'Marke auswählen',
    'select_brand_required': 'Bitte wählen Sie eine Marke für Level 2 Admin',
    'super_admin_added': 'Super Admin hinzugefügt!',
    'cannot_modify_master': 'Master-Konto kann nicht geändert werden',
    'cannot_remove_master': 'Master-Konto kann nicht entfernt werden',
    'admin_activated': 'Admin aktiviert',
    'admin_deactivated': 'Admin deaktiviert',
    'remove_admin_confirm': 'Admin Entfernen?',
    'admin_removed': 'Admin entfernt',

    // =========================================================================
    // SUPER ADMIN - WHITE LABEL / BRANDS
    // =========================================================================
    'create_new_brand': 'Neue Marke Erstellen',
    'edit_brand': 'Marke Bearbeiten',
    'brand_name': 'Markenname',
    'brand_domain': 'Domain',
    'primary_color': 'Primärfarbe',
    'brand_created': 'Marke erfolgreich erstellt!',
    'brand_updated': 'Marke aktualisiert!',
    'brand_deleted': 'Marke gelöscht',
    'name_domain_required': 'Name und Domain sind erforderlich',
    'cannot_delete_brand': 'Marke mit bestehenden Kunden kann nicht gelöscht werden',
    'delete_brand_confirm': 'Marke Löschen?',

    // =========================================================================
    // SUPER ADMIN - SETTINGS & BACKUP
    // =========================================================================
    'default_brand_updated': 'Standardmarke aktualisiert!',
    'backup_started': 'Backup gestartet!',
    'pricing_saved': 'Preiskonfiguration gespeichert!',

    // =========================================================================
    // COMMON / MISC
    // =========================================================================
    'ok': 'OK',
    'yes': 'Ja',
    'no': 'Nein',
    'or': 'oder',
    'and': 'und',
    'all': 'Alle',
    'none': 'Keine',
    'select': 'Auswählen',
    'search': 'Suchen',
    'filter': 'Filter',
    'clear': 'Löschen',
    'refresh': 'Aktualisieren',
    'back': 'Zurück',
    'next': 'Weiter',
    'previous': 'Zurück',
    'finish': 'Fertig',
    'done': 'Erledigt',
    'version': 'Version',
    'pending_update': 'Update ausstehend',
    'email': 'E-Mail',
    'password': 'Passwort',
    'name': 'Name',
    'description': 'Beschreibung',
    'active': 'Aktiv',
    'inactive': 'Inaktiv',
    'enabled': 'Aktiviert',
    'disabled': 'Deaktiviert',
  };
}
