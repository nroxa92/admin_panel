// FILE: lib/config/translations/lang_it.dart
// LANGUAGE: Italian (IT) - Italiano
// VERSION: 3.1.0 - Complete 307 keys
// DATE: 2026-01-11

class LangIT {
  static const Map<String, String> translations = {
    // =========================================================================
    // NAVIGATION
    // =========================================================================
    'nav_reception': 'Reception',
    'nav_calendar': 'Calendario',
    'nav_settings': 'Impostazioni',
    'nav_logout': 'Esci',

    // =========================================================================
    // DASHBOARD
    // =========================================================================
    'dash_title': 'Panoramica Unità',
    'dash_subtitle': 'Stato ospiti in tempo reale',
    'status_free': 'LIBERO',
    'status_check_in': 'IN ATTESA CHECK-IN',
    'status_scanned': 'REGISTRATO',
    'label_id': 'ID Unità',
    'label_name': 'Nome Unità',
    'label_address': 'Indirizzo',
    'label_wifi_ssid': 'Nome WiFi',
    'label_wifi_pass': 'Password WiFi',
    'label_cleaner_pin': 'PIN Addetto Pulizie',
    'label_review_link': 'Link Recensione',
    'label_unit': 'Unità',
    'label_checkin': 'Arrivo',
    'label_checkout': 'Partenza',
    'label_guests': 'Ospiti',
    'label_guest_name': 'Nome Ospite',
    'label_status': 'Stato',
    'label_notes': 'Note',

    // =========================================================================
    // DIALOGS & BUTTONS
    // =========================================================================
    'dialog_new_unit': 'Nuova Unità',
    'dialog_edit_unit': 'Modifica Unità',
    'dialog_delete_unit': 'Elimina Unità',
    'section_identification': 'Identificazione',
    'section_connectivity': 'Connettività',
    'section_operations': 'Operazioni',
    'btn_edit': 'Modifica',
    'btn_print': 'Stampa',
    'btn_delete': 'Elimina',
    'btn_save': 'SALVA',
    'btn_cancel': 'Annulla',
    'btn_close': 'Chiudi',
    'btn_upload_images': 'Carica Immagini',
    'btn_preview': 'Anteprima',
    'btn_add_task': 'Aggiungi Attività',
    'btn_change': 'CAMBIA',
    'btn_retry': 'Riprova',
    'btn_export': 'Esporta',
    'btn_send': 'Invia',
    'btn_add': 'Aggiungi',
    'btn_create': 'Crea',
    'btn_update': 'Aggiorna',
    'btn_confirm': 'Conferma',
    'btn_got_it': 'CAPITO',
    'btn_lock': 'Blocca',
    'btn_unlock': 'Sblocca',
    'btn_remove': 'Rimuovi',
    'btn_activate': 'Attiva',
    'btn_deactivate': 'Disattiva',
    'msg_confirm_delete': 'Eliminare definitivamente questa unità?',

    // =========================================================================
    // SETTINGS - TABS
    // =========================================================================
    'tab_general': 'Generale',
    'tab_info': 'Libro Info',
    'tab_gallery': 'Galleria',
    'tab_feedback': 'Feedback',

    // =========================================================================
    // SETTINGS - GENERAL
    // =========================================================================
    'header_personalization': 'Personalizzazione Pannello',
    'label_language': 'Lingua',
    'label_theme_color': 'Colore Tema',
    'label_bg_tone': 'Tonalità Sfondo',
    'label_cleaner_pin_global': 'PIN Globale Pulizie',
    'label_reset_pin': 'PIN Master Reset',
    'header_password': 'Cambia Password Admin',
    'label_current_password': 'Password Attuale',
    'label_new_password': 'Nuova Password',
    'label_confirm_password': 'Conferma Password',

    // =========================================================================
    // SETTINGS - INFO BOOK
    // =========================================================================
    'header_digital_book': 'Contenuto e Conoscenza IA',
    'digital_book_subtitle': 'Gestisci contenuti visibili agli ospiti sui tablet',
    'section_guest_info': '1. PER OSPITI (Regole e Info)',
    'section_cleaner_info': '2. PER PULIZIE (Lista Interna)',
    'section_ai_knowledge': '3. CONOSCENZA LOCALE (Contesto IA)',
    'label_house_rules': 'Regole della Casa (Traduzioni)',
    'label_checklist_item': 'Attività',
    'label_welcome_msg': 'Messaggio di Benvenuto',
    'label_ai_concierge': 'Conoscenza Concierge',
    'label_ai_housekeeper': 'Conoscenza Governante',
    'label_ai_tech': 'Conoscenza Tecnica',
    'label_ai_guide': 'Conoscenza Guida',

    // =========================================================================
    // CALENDAR
    // =========================================================================
    'calendar_title': 'Programma Prenotazioni',
    'sort_options': 'Opzioni Ordinamento',
    'sort_by_name': 'Nome',
    'sort_by_occupancy': 'Occupazione',
    'sort_by_created': 'Creato',
    'sort_units': 'UNITÀ',
    'sort_zones': 'ZONE',
    'zone_none': 'Nessuna Zona',
    'new_zone': 'Nuova Zona',
    'period_days': 'Giorni',
    'period_all': 'TUTTO',
    'tooltip_sort': 'Opzioni Ordinamento',
    'tooltip_visibility': 'Visibilità Zona',
    'tooltip_rotate': 'Ruota Vista',
    'tooltip_period': 'Seleziona Periodo',
    'tooltip_print': 'Opzioni Stampa',
    'msg_booking_moved': 'Prenotazione spostata con successo!',
    'msg_booking_overlap': 'Impossibile spostare - slot occupato!',
    'day_today': 'OGGI',
    'day_tomorrow': 'DOMANI',
    'check_ins': 'Check-in',
    'check_outs': 'Check-out',
    'no_activity': 'Nessuna attività',
    'needs_cleaning': 'Da Pulire',
    'cleaner_arrived': 'Addetto Arrivato',
    'cleaning_done': 'Pulito',
    'hide_category': 'Nascondi categoria',
    'show_category': 'Mostra categoria',
    'show_all': 'Mostra Tutto',
    'hide_all': 'Nascondi Tutto',

    // =========================================================================
    // PRINT OPTIONS
    // =========================================================================
    'print_options': 'Opzioni Stampa',
    'print_evisitor': 'Dati eVisitor Scansionati',
    'print_house_rules': 'Regole Firmate',
    'print_cleaning_log': 'Registro Pulizie',
    'print_unit_schedule': 'Programma Unità (30 Giorni)',
    'print_text_full': 'Lista Testuale (Completa)',
    'print_text_anon': 'Lista Testuale (Anonima)',
    'print_cleaning_sched': 'Programma Pulizie',
    'print_graphic_full': 'Vista Grafica (Completa)',
    'print_graphic_anon': 'Vista Grafica (Anonima)',
    'print_history': 'Storico Prenotazioni (Archivio)',
    'print_all': 'Stampa Tutto',
    'print_selected': 'Stampa Selezionati',

    // =========================================================================
    // BOOKING
    // =========================================================================
    'booking_details': 'Dettagli Prenotazione',
    'guest_name': 'Nome Ospite',
    'guest_count': 'Ospiti',
    'check_in_date': 'Arrivo',
    'check_out_date': 'Partenza',
    'nights': 'Notti',
    'status': 'Stato',
    'notes': 'Note',
    'new_booking': 'Nuova Prenotazione',
    'edit_booking': 'Modifica Prenotazione',
    'delete_booking': 'Elimina Prenotazione',
    'booking_saved': 'Prenotazione salvata!',
    'booking_deleted': 'Prenotazione eliminata!',

    // =========================================================================
    // BOOKING STATUS
    // =========================================================================
    'status_confirmed': 'Confermato',
    'status_pending': 'In Attesa',
    'status_checked_in': 'Registrato',
    'status_checked_out': 'Partito',
    'status_cancelled': 'Cancellato',
    'status_blocked': 'Bloccato',
    'status_private': 'Privato',

    // =========================================================================
    // BOOKING SOURCE
    // =========================================================================
    'label_source': 'Fonte',
    'source_manual': 'Manuale',
    'source_airbnb': 'Airbnb',
    'source_booking': 'Booking.com',
    'source_vrbo': 'VRBO',
    'source_expedia': 'Expedia',
    'source_private': 'Privato',
    'source_other': 'Altro',

    // =========================================================================
    // MESSAGES
    // =========================================================================
    'msg_no_guests': 'Nessun ospite registrato.',
    'msg_no_booking': 'Nessuna prenotazione attiva.',
    'msg_preparing_pdf': 'Preparazione PDF...',
    'msg_error': 'Errore',
    'msg_success': 'Successo',
    'msg_saved': 'Salvato!',
    'msg_deleted': 'Eliminato!',
    'msg_loading': 'Caricamento...',
    'msg_no_units': 'Nessuna unità trovata.',
    'msg_unit_created': 'Unità creata!',
    'msg_unit_updated': 'Unità aggiornata!',
    'msg_unit_deleted': 'Unità eliminata!',
    'msg_confirm_zone': 'Conferma nuova zona o annulla',
    'editable_fields': 'Campi Modificabili:',
    'label_category': 'Categoria',
    'hint_no_zone': 'Nessuna zona',
    'msg_emergency_saved': 'Contatto Emergenza salvato!',
    'msg_timers_saved': 'Timer salvati!',
    'msg_checklist_saved': 'Lista attività salvata!',
    'msg_ai_saved': 'Contesto IA salvato!',
    'msg_house_rules_missing': 'Regole della casa non configurate.',
    'msg_no_cleaning_logs': 'Nessun registro pulizie trovato.',
    'msg_export_ready': 'Esportazione pronta!',
    'msg_export_failed': 'Esportazione fallita',
    'msg_required_fields': 'Compila tutti i campi obbligatori',
    'msg_email_required': 'Email obbligatoria',
    'msg_no_owners': 'Nessun proprietario trovato',

    // =========================================================================
    // THEMES
    // =========================================================================
    'theme_luxury': 'Collezione Lusso',
    'theme_neon': 'Neon / Tech',
    'theme_dark': 'Temi Scuri',
    'theme_light': 'Temi Chiari',

    // =========================================================================
    // ANALYTICS
    // =========================================================================
    'analytics_title': 'Approfondimenti Ospiti',
    'analytics_subtitle': 'Statistiche prenotazioni e feedback ospiti',
    'bookings_this_month': 'Prenotazioni Questo Mese',
    'bookings_this_year': 'Prenotazioni Quest\'Anno',
    'occupancy_rate': 'Tasso Occupazione',
    'avg_stay_nights': 'Soggiorno Medio',
    'recent_reviews': 'Recensioni Recenti',
    'average_rating': 'Valutazione Media',
    'top_ai_questions': 'Domande IA Frequenti',
    'no_ai_questions': 'Nessuna domanda IA registrata.',
    'no_reviews': 'Nessuna recensione.',
    'loading_data': 'Caricamento dati...',

    // =========================================================================
    // REVENUE
    // =========================================================================
    'revenue_section': 'Panoramica Ricavi',
    'total_revenue': 'Ricavi Totali',
    'revenue_this_month': 'Questo Mese',
    'average_daily_rate': 'Tariffa Giornaliera Media',
    'total_nights_sold': 'Notti Totali Vendute',
    'monthly_revenue_chart': 'Ricavi Mensili',
    'loading_revenue': 'Caricamento dati ricavi...',

    // =========================================================================
    // CALENDAR EXPORT
    // =========================================================================
    'calendar_export': 'Esporta Calendario',
    'export_bookings_calendar': 'Esporta Prenotazioni',
    'export_calendar_description': 'Esporta prenotazioni in calendari esterni',
    'export_ical': 'Esporta iCal',
    'add_to_calendar': 'Aggiungi al Calendario',
    'ical_copied_clipboard': 'Dati iCal copiati!',
    'export_failed': 'Esportazione fallita',
    'choose_calendar_app': 'Scegli App Calendario',
    'open_in_browser': 'Apri nel Browser',
    'copy_ical_data': 'Copia Dati iCal',
    'paste_in_any_calendar': 'Incolla in qualsiasi app calendario',
    'google_calendar_instructions': 'Google Calendar',
    'google_calendar_steps': 'Apri Google Calendar → Impostazioni → Importa',
    'outlook_instructions': 'Outlook',
    'outlook_steps': 'File → Apri ed Esporta → Importa',

    // =========================================================================
    // SUPER ADMIN - GENERAL
    // =========================================================================
    'super_admin_title': 'Super Admin',
    'super_admin_access_denied': 'Non hai accesso Super Admin',
    'super_admin_deactivated': 'Il tuo accesso admin è stato disattivato',

    // =========================================================================
    // SUPER ADMIN - OWNER MANAGEMENT
    // =========================================================================
    'create_new_owner': 'Crea Nuovo Proprietario',
    'new_owner': 'Nuovo Proprietario',
    'delete_owner': 'Elimina Proprietario',
    'delete_owner_confirm': 'Eliminare Proprietario?',
    'owner_created': 'Proprietario creato!',
    'owner_deleted': 'Proprietario eliminato',
    'temp_password': 'Password temporanea',
    'reset_password': 'Reimposta Password',
    'new_password_generated': 'Nuova password',

    // =========================================================================
    // SUPER ADMIN - TABLET MANAGEMENT
    // =========================================================================
    'lock_all_tablets': 'Blocca Tutti i Tablet',
    'lock_all_tablets_confirm': 'Bloccare Tutti i Tablet?',
    'unlock_tablet': 'Sblocca Tablet',
    'unlock_tablet_confirm': 'Sbloccare Tablet?',
    'no_tablets_registered': 'Nessun tablet registrato',
    'tablets_online': 'online',
    'tablets_count': 'tablet',
    'edit_tablet': 'Modifica Tablet',
    'kiosk_settings': 'IMPOSTAZIONI KIOSK',
    'exit_pin_label': 'PIN Uscita (6 cifre)',
    'pin_6_digits_required': 'Il PIN deve avere esattamente 6 cifre',
    'tablet_locked': 'Tablet bloccato',
    'tablet_unlocked': 'Tablet sbloccato',
    'failed_to_lock': 'Blocco fallito',
    'failed_to_unlock': 'Sblocco fallito',

    // =========================================================================
    // SUPER ADMIN - NOTIFICATIONS
    // =========================================================================
    'notification_sent': 'Notifica inviata!',
    'notification_deleted': 'Notifica eliminata',
    'title_required': 'Titolo e messaggio sono obbligatori',
    'notification_type': 'Tipo',
    'notification_recipients': 'Destinatari',
    'all_owners': 'Tutti i Proprietari',
    'select_specific': 'Seleziona Specifici',
    'send_notification': 'Invia Notifica',
    'system_notification': 'Notifica di Sistema',
    'no_notifications': 'Nessuna notifica inviata',
    'notification_title': 'Titolo',
    'notification_message': 'Messaggio',

    // =========================================================================
    // SUPER ADMIN - ADMIN MANAGEMENT
    // =========================================================================
    'add_super_admin': 'Aggiungi Super Admin',
    'add_admin': 'Aggiungi Admin',
    'admin_level': 'Livello Admin',
    'assigned_brand': 'Brand Assegnato',
    'select_brand': 'Seleziona brand',
    'select_brand_required': 'Seleziona un brand per admin Level 2',
    'super_admin_added': 'Super Admin aggiunto!',
    'cannot_modify_master': 'Impossibile modificare account Master',
    'cannot_remove_master': 'Impossibile rimuovere account Master',
    'admin_activated': 'Admin attivato',
    'admin_deactivated': 'Admin disattivato',
    'remove_admin_confirm': 'Rimuovere Admin?',
    'admin_removed': 'Admin rimosso',

    // =========================================================================
    // SUPER ADMIN - WHITE LABEL / BRANDS
    // =========================================================================
    'create_new_brand': 'Crea Nuovo Brand',
    'edit_brand': 'Modifica Brand',
    'brand_name': 'Nome Brand',
    'brand_domain': 'Dominio',
    'primary_color': 'Colore Primario',
    'brand_created': 'Brand creato con successo!',
    'brand_updated': 'Brand aggiornato!',
    'brand_deleted': 'Brand eliminato',
    'name_domain_required': 'Nome e Dominio sono obbligatori',
    'cannot_delete_brand': 'Impossibile eliminare brand con clienti esistenti',
    'delete_brand_confirm': 'Eliminare Brand?',

    // =========================================================================
    // SUPER ADMIN - SETTINGS & BACKUP
    // =========================================================================
    'default_brand_updated': 'Brand predefinito aggiornato!',
    'backup_started': 'Backup avviato!',
    'pricing_saved': 'Configurazione prezzi salvata!',

    // =========================================================================
    // COMMON
    // =========================================================================
    'ok': 'OK',
    'yes': 'Sì',
    'no': 'No',
    'or': 'o',
    'and': 'e',
    'all': 'Tutto',
    'none': 'Nessuno',
    'select': 'Seleziona',
    'search': 'Cerca',
    'filter': 'Filtra',
    'clear': 'Cancella',
    'refresh': 'Aggiorna',
    'back': 'Indietro',
    'next': 'Avanti',
    'previous': 'Precedente',
    'finish': 'Fine',
    'done': 'Fatto',
    'version': 'Versione',
    'pending_update': 'Aggiornamento in Sospeso',
    'email': 'Email',
    'password': 'Password',
    'name': 'Nome',
    'description': 'Descrizione',
    'active': 'Attivo',
    'inactive': 'Inattivo',
    'enabled': 'Abilitato',
    'disabled': 'Disabilitato',
  };
}
