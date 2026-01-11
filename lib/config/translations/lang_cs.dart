// FILE: lib/config/translations/lang_cs.dart
// LANGUAGE: Czech (CS) - Čeština
// VERSION: 3.1.0 - Complete 307 keys
// DATE: 2026-01-11

class LangCS {
  static const Map<String, String> translations = {
    // =========================================================================
    // NAVIGATION
    // =========================================================================
    'nav_reception': 'Recepce',
    'nav_calendar': 'Kalendář',
    'nav_settings': 'Nastavení',
    'nav_logout': 'Odhlásit',

    // =========================================================================
    // DASHBOARD
    // =========================================================================
    'dash_title': 'Přehled Jednotek',
    'dash_subtitle': 'Stav hostů v reálném čase',
    'status_free': 'VOLNÉ',
    'status_check_in': 'ČEKÁ NA CHECK-IN',
    'status_scanned': 'PŘIHLÁŠEN',
    'label_id': 'ID Jednotky',
    'label_name': 'Název Jednotky',
    'label_address': 'Adresa',
    'label_wifi_ssid': 'WiFi Název',
    'label_wifi_pass': 'WiFi Heslo',
    'label_cleaner_pin': 'PIN Uklízečky',
    'label_review_link': 'Odkaz na Recenzi',
    'label_unit': 'Jednotka',
    'label_checkin': 'Příjezd',
    'label_checkout': 'Odjezd',
    'label_guests': 'Hosté',
    'label_guest_name': 'Jméno Hosta',
    'label_status': 'Stav',
    'label_notes': 'Poznámky',

    // =========================================================================
    // DIALOGS & BUTTONS
    // =========================================================================
    'dialog_new_unit': 'Nová Jednotka',
    'dialog_edit_unit': 'Upravit Jednotku',
    'dialog_delete_unit': 'Smazat Jednotku',
    'section_identification': 'Identifikace',
    'section_connectivity': 'Připojení',
    'section_operations': 'Operace',
    'btn_edit': 'Upravit',
    'btn_print': 'Tisk',
    'btn_delete': 'Smazat',
    'btn_save': 'ULOŽIT',
    'btn_cancel': 'Zrušit',
    'btn_close': 'Zavřít',
    'btn_upload_images': 'Nahrát Obrázky',
    'btn_preview': 'Náhled',
    'btn_add_task': 'Přidat Úkol',
    'btn_change': 'ZMĚNIT',
    'btn_retry': 'Zkusit Znovu',
    'btn_export': 'Exportovat',
    'btn_send': 'Odeslat',
    'btn_add': 'Přidat',
    'btn_create': 'Vytvořit',
    'btn_update': 'Aktualizovat',
    'btn_confirm': 'Potvrdit',
    'btn_got_it': 'ROZUMÍM',
    'btn_lock': 'Zamknout',
    'btn_unlock': 'Odemknout',
    'btn_remove': 'Odstranit',
    'btn_activate': 'Aktivovat',
    'btn_deactivate': 'Deaktivovat',
    'msg_confirm_delete': 'Trvale smazat tuto jednotku?',

    // =========================================================================
    // SETTINGS - TABS
    // =========================================================================
    'tab_general': 'Obecné',
    'tab_info': 'Info Kniha',
    'tab_gallery': 'Galerie',
    'tab_feedback': 'Zpětná Vazba',

    // =========================================================================
    // SETTINGS - GENERAL
    // =========================================================================
    'header_personalization': 'Personalizace Panelu',
    'label_language': 'Jazyk',
    'label_theme_color': 'Barva Tématu',
    'label_bg_tone': 'Tón Pozadí',
    'label_cleaner_pin_global': 'Globální PIN Uklízečky',
    'label_reset_pin': 'Master Reset PIN',
    'header_password': 'Změna Admin Hesla',
    'label_current_password': 'Aktuální Heslo',
    'label_new_password': 'Nové Heslo',
    'label_confirm_password': 'Potvrdit Heslo',

    // =========================================================================
    // SETTINGS - INFO BOOK
    // =========================================================================
    'header_digital_book': 'Obsah a AI Znalosti',
    'digital_book_subtitle': 'Spravujte obsah viditelný hostům na tabletech',
    'section_guest_info': '1. PRO HOSTY (Pravidla a Info)',
    'section_cleaner_info': '2. PRO UKLÍZEČKY (Interní Seznam)',
    'section_ai_knowledge': '3. MÍSTNÍ ZNALOSTI (AI Kontext)',
    'label_house_rules': 'Domovní Pravidla (Překlady)',
    'label_checklist_item': 'Úkol',
    'label_welcome_msg': 'Uvítací Zpráva',
    'label_ai_concierge': 'Znalosti Concierge',
    'label_ai_housekeeper': 'Znalosti Hospodyně',
    'label_ai_tech': 'Technické Znalosti',
    'label_ai_guide': 'Znalosti Průvodce',

    // =========================================================================
    // CALENDAR
    // =========================================================================
    'calendar_title': 'Rozvrh Rezervací',
    'sort_options': 'Možnosti Řazení',
    'sort_by_name': 'Jméno',
    'sort_by_occupancy': 'Obsazenost',
    'sort_by_created': 'Vytvořeno',
    'sort_units': 'JEDNOTKY',
    'sort_zones': 'ZÓNY',
    'zone_none': 'Bez Zóny',
    'new_zone': 'Nová Zóna',
    'period_days': 'Dní',
    'period_all': 'VŠE',
    'tooltip_sort': 'Možnosti Řazení',
    'tooltip_visibility': 'Viditelnost Zóny',
    'tooltip_rotate': 'Otočit Zobrazení',
    'tooltip_period': 'Vybrat Období',
    'tooltip_print': 'Možnosti Tisku',
    'msg_booking_moved': 'Rezervace úspěšně přesunuta!',
    'msg_booking_overlap': 'Nelze přesunout - termín obsazen!',
    'day_today': 'DNES',
    'day_tomorrow': 'ZÍTRA',
    'check_ins': 'Příjezdy',
    'check_outs': 'Odjezdy',
    'no_activity': 'Žádná aktivita',
    'needs_cleaning': 'Potřebuje Úklid',
    'cleaner_arrived': 'Uklízečka Přišla',
    'cleaning_done': 'Uklizeno',
    'hide_category': 'Skrýt kategorii',
    'show_category': 'Zobrazit kategorii',
    'show_all': 'Zobrazit Vše',
    'hide_all': 'Skrýt Vše',

    // =========================================================================
    // PRINT OPTIONS
    // =========================================================================
    'print_options': 'Možnosti Tisku',
    'print_evisitor': 'eVisitor Naskenovaná Data',
    'print_house_rules': 'Podepsaná Domovní Pravidla',
    'print_cleaning_log': 'Deník Úklidu',
    'print_unit_schedule': 'Rozvrh Jednotky (30 Dní)',
    'print_text_full': 'Textový Seznam (Plný)',
    'print_text_anon': 'Textový Seznam (Anonymní)',
    'print_cleaning_sched': 'Rozvrh Úklidu',
    'print_graphic_full': 'Grafické Zobrazení (Plné)',
    'print_graphic_anon': 'Grafické Zobrazení (Anonymní)',
    'print_history': 'Historie Rezervací (Plný Archiv)',
    'print_all': 'Tisknout Vše',
    'print_selected': 'Tisknout Vybrané',

    // =========================================================================
    // BOOKING
    // =========================================================================
    'booking_details': 'Detaily Rezervace',
    'guest_name': 'Jméno Hosta',
    'guest_count': 'Hosté',
    'check_in_date': 'Příjezd',
    'check_out_date': 'Odjezd',
    'nights': 'Nocí',
    'status': 'Stav',
    'notes': 'Poznámky',
    'new_booking': 'Nová Rezervace',
    'edit_booking': 'Upravit Rezervaci',
    'delete_booking': 'Smazat Rezervaci',
    'booking_saved': 'Rezervace uložena!',
    'booking_deleted': 'Rezervace smazána!',

    // =========================================================================
    // BOOKING STATUS
    // =========================================================================
    'status_confirmed': 'Potvrzeno',
    'status_pending': 'Čekající',
    'status_checked_in': 'Přihlášen',
    'status_checked_out': 'Odhlášen',
    'status_cancelled': 'Zrušeno',
    'status_blocked': 'Blokováno',
    'status_private': 'Soukromé',

    // =========================================================================
    // BOOKING SOURCE
    // =========================================================================
    'label_source': 'Zdroj',
    'source_manual': 'Manuálně',
    'source_airbnb': 'Airbnb',
    'source_booking': 'Booking.com',
    'source_vrbo': 'VRBO',
    'source_expedia': 'Expedia',
    'source_private': 'Soukromé',
    'source_other': 'Jiné',

    // =========================================================================
    // MESSAGES
    // =========================================================================
    'msg_no_guests': 'Zatím žádní registrovaní hosté.',
    'msg_no_booking': 'Žádná aktivní rezervace.',
    'msg_preparing_pdf': 'Připravuji PDF...',
    'msg_error': 'Chyba',
    'msg_success': 'Úspěch',
    'msg_saved': 'Uloženo!',
    'msg_deleted': 'Smazáno!',
    'msg_loading': 'Načítám...',
    'msg_no_units': 'Žádné jednotky nenalezeny.',
    'msg_unit_created': 'Jednotka vytvořena!',
    'msg_unit_updated': 'Jednotka aktualizována!',
    'msg_unit_deleted': 'Jednotka smazána!',
    'msg_confirm_zone': 'Potvrdit novou zónu nebo zrušit',
    'editable_fields': 'Editovatelná Pole:',
    'label_category': 'Kategorie',
    'hint_no_zone': 'Bez zóny',
    'msg_emergency_saved': 'Nouzový Kontakt uložen!',
    'msg_timers_saved': 'Časovače uloženy!',
    'msg_checklist_saved': 'Seznam úkolů uložen!',
    'msg_ai_saved': 'AI Kontext uložen!',
    'msg_house_rules_missing': 'Domovní pravidla nejsou nakonfigurována.',
    'msg_no_cleaning_logs': 'Žádné záznamy o úklidu.',
    'msg_export_ready': 'Export připraven!',
    'msg_export_failed': 'Export selhal',
    'msg_required_fields': 'Prosím vyplňte všechna povinná pole',
    'msg_email_required': 'Email je povinný',
    'msg_no_owners': 'Žádní vlastníci nenalezeni',

    // =========================================================================
    // THEMES
    // =========================================================================
    'theme_luxury': 'Luxusní Kolekce',
    'theme_neon': 'Neon / Tech',
    'theme_dark': 'Tmavá Témata',
    'theme_light': 'Světlá Témata',

    // =========================================================================
    // ANALYTICS
    // =========================================================================
    'analytics_title': 'Přehledy Hostů',
    'analytics_subtitle': 'Statistiky rezervací a zpětná vazba hostů',
    'bookings_this_month': 'Rezervace Tento Měsíc',
    'bookings_this_year': 'Rezervace Tento Rok',
    'occupancy_rate': 'Míra Obsazenosti',
    'avg_stay_nights': 'Prům. Pobyt',
    'recent_reviews': 'Nedávné Recenze',
    'average_rating': 'Průměrné Hodnocení',
    'top_ai_questions': 'Nejčastější AI Otázky',
    'no_ai_questions': 'Zatím žádné AI otázky.',
    'no_reviews': 'Zatím žádné recenze.',
    'loading_data': 'Načítám data...',

    // =========================================================================
    // REVENUE
    // =========================================================================
    'revenue_section': 'Přehled Příjmů',
    'total_revenue': 'Celkové Příjmy',
    'revenue_this_month': 'Tento Měsíc',
    'average_daily_rate': 'Průměrná Denní Sazba',
    'total_nights_sold': 'Celkem Prodaných Nocí',
    'monthly_revenue_chart': 'Měsíční Příjmy',
    'loading_revenue': 'Načítám data o příjmech...',

    // =========================================================================
    // CALENDAR EXPORT
    // =========================================================================
    'calendar_export': 'Export Kalendáře',
    'export_bookings_calendar': 'Exportovat Rezervace',
    'export_calendar_description': 'Exportujte rezervace do externích kalendářů',
    'export_ical': 'Export iCal',
    'add_to_calendar': 'Přidat do Kalendáře',
    'ical_copied_clipboard': 'iCal data zkopírována!',
    'export_failed': 'Export selhal',
    'choose_calendar_app': 'Vyberte Kalendářovou Aplikaci',
    'open_in_browser': 'Otevřít v Prohlížeči',
    'copy_ical_data': 'Kopírovat iCal Data',
    'paste_in_any_calendar': 'Vložte do jakékoliv kalendářové aplikace',
    'google_calendar_instructions': 'Google Kalendář',
    'google_calendar_steps': 'Otevřete Google Kalendář → Nastavení → Import',
    'outlook_instructions': 'Outlook',
    'outlook_steps': 'Soubor → Otevřít a Exportovat → Import',

    // =========================================================================
    // SUPER ADMIN - GENERAL
    // =========================================================================
    'super_admin_title': 'Super Admin',
    'super_admin_access_denied': 'Nemáte přístup k Super Adminovi',
    'super_admin_deactivated': 'Váš admin přístup byl deaktivován',

    // =========================================================================
    // SUPER ADMIN - OWNER MANAGEMENT
    // =========================================================================
    'create_new_owner': 'Vytvořit Nového Vlastníka',
    'new_owner': 'Nový Vlastník',
    'delete_owner': 'Smazat Vlastníka',
    'delete_owner_confirm': 'Smazat Vlastníka?',
    'owner_created': 'Vlastník vytvořen!',
    'owner_deleted': 'Vlastník smazán',
    'temp_password': 'Dočasné heslo',
    'reset_password': 'Resetovat Heslo',
    'new_password_generated': 'Nové heslo',

    // =========================================================================
    // SUPER ADMIN - TABLET MANAGEMENT
    // =========================================================================
    'lock_all_tablets': 'Zamknout Všechny Tablety',
    'lock_all_tablets_confirm': 'Zamknout Všechny Tablety?',
    'unlock_tablet': 'Odemknout Tablet',
    'unlock_tablet_confirm': 'Odemknout Tablet?',
    'no_tablets_registered': 'Žádné registrované tablety',
    'tablets_online': 'online',
    'tablets_count': 'tabletů',
    'edit_tablet': 'Upravit Tablet',
    'kiosk_settings': 'KIOSK NASTAVENÍ',
    'exit_pin_label': 'Výstupní PIN (6 číslic)',
    'pin_6_digits_required': 'PIN musí mít přesně 6 číslic',
    'tablet_locked': 'Tablet zamknut',
    'tablet_unlocked': 'Tablet odemknut',
    'failed_to_lock': 'Zamknutí selhalo',
    'failed_to_unlock': 'Odemknutí selhalo',

    // =========================================================================
    // SUPER ADMIN - NOTIFICATIONS
    // =========================================================================
    'notification_sent': 'Notifikace odeslána!',
    'notification_deleted': 'Notifikace smazána',
    'title_required': 'Název a zpráva jsou povinné',
    'notification_type': 'Typ',
    'notification_recipients': 'Příjemci',
    'all_owners': 'Všichni Vlastníci',
    'select_specific': 'Vybrat Konkrétní',
    'send_notification': 'Odeslat Notifikaci',
    'system_notification': 'Systémová Notifikace',
    'no_notifications': 'Zatím žádné odeslané notifikace',
    'notification_title': 'Název',
    'notification_message': 'Zpráva',

    // =========================================================================
    // SUPER ADMIN - ADMIN MANAGEMENT
    // =========================================================================
    'add_super_admin': 'Přidat Super Admina',
    'add_admin': 'Přidat Admina',
    'admin_level': 'Úroveň Admina',
    'assigned_brand': 'Přiřazená Značka',
    'select_brand': 'Vybrat značku',
    'select_brand_required': 'Prosím vyberte značku pro Level 2 admina',
    'super_admin_added': 'Super Admin přidán!',
    'cannot_modify_master': 'Nelze upravit Master účet',
    'cannot_remove_master': 'Nelze odstranit Master účet',
    'admin_activated': 'Admin aktivován',
    'admin_deactivated': 'Admin deaktivován',
    'remove_admin_confirm': 'Odstranit Admina?',
    'admin_removed': 'Admin odstraněn',

    // =========================================================================
    // SUPER ADMIN - WHITE LABEL / BRANDS
    // =========================================================================
    'create_new_brand': 'Vytvořit Novou Značku',
    'edit_brand': 'Upravit Značku',
    'brand_name': 'Název Značky',
    'brand_domain': 'Doména',
    'primary_color': 'Primární Barva',
    'brand_created': 'Značka úspěšně vytvořena!',
    'brand_updated': 'Značka aktualizována!',
    'brand_deleted': 'Značka smazána',
    'name_domain_required': 'Název a Doména jsou povinné',
    'cannot_delete_brand': 'Nelze smazat značku s existujícími klienty',
    'delete_brand_confirm': 'Smazat Značku?',

    // =========================================================================
    // SUPER ADMIN - SETTINGS & BACKUP
    // =========================================================================
    'default_brand_updated': 'Výchozí značka aktualizována!',
    'backup_started': 'Záloha spuštěna!',
    'pricing_saved': 'Konfigurace cen uložena!',

    // =========================================================================
    // COMMON
    // =========================================================================
    'ok': 'OK',
    'yes': 'Ano',
    'no': 'Ne',
    'or': 'nebo',
    'and': 'a',
    'all': 'Vše',
    'none': 'Žádné',
    'select': 'Vybrat',
    'search': 'Hledat',
    'filter': 'Filtr',
    'clear': 'Vymazat',
    'refresh': 'Obnovit',
    'back': 'Zpět',
    'next': 'Další',
    'previous': 'Předchozí',
    'finish': 'Dokončit',
    'done': 'Hotovo',
    'version': 'Verze',
    'pending_update': 'Čeká na Aktualizaci',
    'email': 'Email',
    'password': 'Heslo',
    'name': 'Jméno',
    'description': 'Popis',
    'active': 'Aktivní',
    'inactive': 'Neaktivní',
    'enabled': 'Povoleno',
    'disabled': 'Zakázáno',
  };
}
