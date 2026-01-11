// FILE: lib/config/translations/lang_en.dart
// LANGUAGE: English (EN) - MASTER
// VERSION: 3.1.0 - Complete with all hardcoded strings covered
// DATE: 2026-01-11
// NOTE: This is the master language file. All keys must exist here.

class LangEN {
  static const Map<String, String> translations = {
    // =========================================================================
    // NAVIGATION
    // =========================================================================
    'nav_reception': 'Reception',
    'nav_calendar': 'Calendar',
    'nav_settings': 'Settings',
    'nav_logout': 'Logout',

    // =========================================================================
    // DASHBOARD
    // =========================================================================
    'dash_title': 'Units Overview',
    'dash_subtitle': 'Real-time guest status',
    'status_free': 'VACANT',
    'status_check_in': 'AWAITING CHECK-IN',
    'status_scanned': 'CHECKED-IN',
    'label_id': 'Unit ID',
    'label_name': 'Unit Name',
    'label_address': 'Address',
    'label_wifi_ssid': 'WiFi Name',
    'label_wifi_pass': 'WiFi Password',
    'label_cleaner_pin': 'Cleaner PIN',
    'label_review_link': 'Review Link',
    'label_unit': 'Unit',
    'label_checkin': 'Check-in',
    'label_checkout': 'Check-out',
    'label_guests': 'Guests',
    'label_guest_name': 'Guest Name',
    'label_status': 'Status',
    'label_notes': 'Notes',

    // =========================================================================
    // DIALOGS & BUTTONS
    // =========================================================================
    'dialog_new_unit': 'New Unit',
    'dialog_edit_unit': 'Edit Unit',
    'dialog_delete_unit': 'Delete Unit',
    'section_identification': 'Identification',
    'section_connectivity': 'Connectivity',
    'section_operations': 'Operations',
    'btn_edit': 'Edit',
    'btn_print': 'Print',
    'btn_delete': 'Delete',
    'btn_save': 'SAVE',
    'btn_cancel': 'Cancel',
    'btn_close': 'Close',
    'btn_upload_images': 'Upload Images',
    'btn_preview': 'Preview',
    'btn_add_task': 'Add Task',
    'btn_change': 'CHANGE',
    'btn_retry': 'Retry',
    'btn_export': 'Export',
    'btn_send': 'Send',
    'btn_add': 'Add',
    'btn_create': 'Create',
    'btn_update': 'Update',
    'btn_confirm': 'Confirm',
    'btn_got_it': 'GOT IT',
    'btn_lock': 'Lock',
    'btn_unlock': 'Unlock',
    'btn_remove': 'Remove',
    'btn_activate': 'Activate',
    'btn_deactivate': 'Deactivate',
    'msg_confirm_delete': 'Permanently delete this unit?',

    // =========================================================================
    // SETTINGS - TABS
    // =========================================================================
    'tab_general': 'General',
    'tab_info': 'Info Book',
    'tab_gallery': 'Gallery',
    'tab_feedback': 'Feedback',

    // =========================================================================
    // SETTINGS - GENERAL
    // =========================================================================
    'header_personalization': 'Panel Personalization',
    'label_language': 'Language',
    'label_theme_color': 'Theme Color',
    'label_bg_tone': 'Background Tone',
    'label_cleaner_pin_global': 'Global Cleaner PIN',
    'label_reset_pin': 'Master Reset PIN',
    'header_password': 'Change Admin Password',
    'label_current_password': 'Current Password',
    'label_new_password': 'New Password',
    'label_confirm_password': 'Confirm Password',

    // =========================================================================
    // SETTINGS - INFO BOOK
    // =========================================================================
    'header_digital_book': 'Content & AI Knowledge',
    'digital_book_subtitle': 'Manage content visible to guests on tablets',
    'section_guest_info': '1. FOR GUESTS (Rules & Info)',
    'section_cleaner_info': '2. FOR CLEANERS (Internal Checklist)',
    'section_ai_knowledge': '3. LOCAL KNOWLEDGE (AI Context)',
    'label_house_rules': 'House Rules (Translations)',
    'label_checklist_item': 'Task',
    'label_welcome_msg': 'Welcome Message',
    'label_ai_concierge': 'Concierge Knowledge',
    'label_ai_housekeeper': 'Housekeeper Knowledge',
    'label_ai_tech': 'Tech Knowledge',
    'label_ai_guide': 'Guide Knowledge',

    // =========================================================================
    // CALENDAR
    // =========================================================================
    'calendar_title': 'Booking Schedule',
    'sort_options': 'Sort Options',
    'sort_by_name': 'Name',
    'sort_by_occupancy': 'Occupancy',
    'sort_by_created': 'Created',
    'sort_units': 'UNITS',
    'sort_zones': 'ZONES',
    'zone_none': 'No Zone',
    'new_zone': 'New Zone',
    'period_days': 'Days',
    'period_all': 'ALL',
    'tooltip_sort': 'Sort Options',
    'tooltip_visibility': 'Toggle Zone Visibility',
    'tooltip_rotate': 'Rotate View',
    'tooltip_period': 'Select Period',
    'tooltip_print': 'Print Options',
    'msg_booking_moved': 'Booking moved successfully!',
    'msg_booking_overlap': 'Cannot move - slot occupied!',
    'day_today': 'TODAY',
    'day_tomorrow': 'TOMORROW',
    'check_ins': 'Check-ins',
    'check_outs': 'Check-outs',
    'no_activity': 'No activity',
    'needs_cleaning': 'Needs Cleaning',
    'cleaner_arrived': 'Cleaner Arrived',
    'cleaning_done': 'Cleaned',
    'hide_category': 'Hide category',
    'show_category': 'Show category',
    'show_all': 'Show All',
    'hide_all': 'Hide All',

    // =========================================================================
    // PRINT OPTIONS
    // =========================================================================
    'print_options': 'Print Options',
    'print_evisitor': 'eVisitor Scanned Data',
    'print_house_rules': 'Signed House Rules',
    'print_cleaning_log': 'Cleaning Log',
    'print_unit_schedule': 'Unit Schedule (30 Days)',
    'print_text_full': 'Textual List (Full)',
    'print_text_anon': 'Textual List (Anonymous)',
    'print_cleaning_sched': 'Cleaning Schedule',
    'print_graphic_full': 'Graphic View (Full)',
    'print_graphic_anon': 'Graphic View (Anonymous)',
    'print_history': 'Booking History (Full Archive)',
    'print_all': 'Print All',
    'print_selected': 'Print Selected',

    // =========================================================================
    // BOOKING
    // =========================================================================
    'booking_details': 'Booking Details',
    'guest_name': 'Guest Name',
    'guest_count': 'Guests',
    'check_in_date': 'Check-in',
    'check_out_date': 'Check-out',
    'nights': 'Nights',
    'status': 'Status',
    'notes': 'Notes',
    'new_booking': 'New Booking',
    'edit_booking': 'Edit Booking',
    'delete_booking': 'Delete Booking',
    'booking_saved': 'Booking saved!',
    'booking_deleted': 'Booking deleted!',

    // =========================================================================
    // BOOKING STATUS (workflow states)
    // =========================================================================
    'status_confirmed': 'Confirmed',
    'status_pending': 'Pending',
    'status_checked_in': 'Checked In',
    'status_checked_out': 'Checked Out',
    'status_cancelled': 'Cancelled',
    'status_blocked': 'Blocked',
    'status_private': 'Private',

    // =========================================================================
    // BOOKING SOURCE (platforms) - v3.0
    // =========================================================================
    'label_source': 'Source',
    'source_manual': 'Manual',
    'source_airbnb': 'Airbnb',
    'source_booking': 'Booking.com',
    'source_vrbo': 'VRBO',
    'source_expedia': 'Expedia',
    'source_private': 'Private',
    'source_other': 'Other',

    // =========================================================================
    // MESSAGES
    // =========================================================================
    'msg_no_guests': 'No guests registered yet.',
    'msg_no_booking': 'No active booking.',
    'msg_preparing_pdf': 'Preparing PDF...',
    'msg_error': 'Error',
    'msg_success': 'Success',
    'msg_saved': 'Saved!',
    'msg_deleted': 'Deleted!',
    'msg_loading': 'Loading...',
    'msg_no_units': 'No units found.',
    'msg_unit_created': 'Unit created!',
    'msg_unit_updated': 'Unit updated!',
    'msg_unit_deleted': 'Unit deleted!',
    'msg_confirm_zone': 'Confirm new zone or cancel',
    'editable_fields': 'Editable Fields:',
    'label_category': 'Category',
    'hint_no_zone': 'No zone',
    'msg_emergency_saved': 'Emergency Contact saved!',
    'msg_timers_saved': 'Timers saved!',
    'msg_checklist_saved': 'Checklist saved!',
    'msg_ai_saved': 'AI Context saved!',
    'msg_house_rules_missing': 'House rules not configured.',
    'msg_no_cleaning_logs': 'No cleaning logs found.',
    'msg_export_ready': 'Export ready!',
    'msg_export_failed': 'Export failed',
    'msg_required_fields': 'Please fill all required fields',
    'msg_email_required': 'Email is required',
    'msg_no_owners': 'No owners found',

    // =========================================================================
    // THEMES
    // =========================================================================
    'theme_luxury': 'Luxury Collection',
    'theme_neon': 'Neon / Tech',
    'theme_dark': 'Dark Themes',
    'theme_light': 'Light Themes',

    // =========================================================================
    // ANALYTICS
    // =========================================================================
    'analytics_title': 'Guest Insights',
    'analytics_subtitle': 'Booking statistics and guest feedback',
    'bookings_this_month': 'Bookings This Month',
    'bookings_this_year': 'Bookings This Year',
    'occupancy_rate': 'Occupancy Rate',
    'avg_stay_nights': 'Avg. Stay',
    'recent_reviews': 'Recent Reviews',
    'average_rating': 'Average Rating',
    'top_ai_questions': 'Top AI Questions',
    'no_ai_questions': 'No AI questions logged yet.',
    'no_reviews': 'No reviews yet.',
    'loading_data': 'Loading data...',

    // =========================================================================
    // REVENUE ANALYTICS
    // =========================================================================
    'revenue_section': 'Revenue Overview',
    'total_revenue': 'Total Revenue',
    'revenue_this_month': 'This Month',
    'average_daily_rate': 'Average Daily Rate',
    'total_nights_sold': 'Total Nights Sold',
    'monthly_revenue_chart': 'Monthly Revenue',
    'loading_revenue': 'Loading revenue data...',

    // =========================================================================
    // CALENDAR EXPORT
    // =========================================================================
    'calendar_export': 'Calendar Export',
    'export_bookings_calendar': 'Export Bookings',
    'export_calendar_description': 'Export your bookings to external calendar apps',
    'export_ical': 'Export iCal',
    'add_to_calendar': 'Add to Calendar',
    'ical_copied_clipboard': 'iCal data copied!',
    'export_failed': 'Export failed',
    'choose_calendar_app': 'Choose Calendar App',
    'open_in_browser': 'Open in Browser',
    'copy_ical_data': 'Copy iCal Data',
    'paste_in_any_calendar': 'Paste in any calendar app',
    'google_calendar_instructions': 'Google Calendar',
    'google_calendar_steps': 'Open Google Calendar → Settings → Import',
    'outlook_instructions': 'Outlook',
    'outlook_steps': 'File → Open & Export → Import',

    // =========================================================================
    // SUPER ADMIN - GENERAL
    // =========================================================================
    'super_admin_title': 'Super Admin',
    'super_admin_access_denied': 'You do not have Super Admin access',
    'super_admin_deactivated': 'Your admin access has been deactivated',

    // =========================================================================
    // SUPER ADMIN - OWNER MANAGEMENT
    // =========================================================================
    'create_new_owner': 'Create New Owner',
    'new_owner': 'New Owner',
    'delete_owner': 'Delete Owner',
    'delete_owner_confirm': 'Delete Owner?',
    'owner_created': 'Owner created!',
    'owner_deleted': 'Owner deleted',
    'temp_password': 'Temp password',
    'reset_password': 'Reset Password',
    'new_password_generated': 'New password',

    // =========================================================================
    // SUPER ADMIN - TABLET MANAGEMENT
    // =========================================================================
    'lock_all_tablets': 'Lock All Tablets',
    'lock_all_tablets_confirm': 'Lock All Tablets?',
    'unlock_tablet': 'Unlock Tablet',
    'unlock_tablet_confirm': 'Unlock Tablet?',
    'no_tablets_registered': 'No tablets registered',
    'tablets_online': 'online',
    'tablets_count': 'tablets',
    'edit_tablet': 'Edit Tablet',
    'kiosk_settings': 'KIOSK SETTINGS',
    'exit_pin_label': 'Exit PIN (6 digits)',
    'pin_6_digits_required': 'PIN must be exactly 6 digits',
    'tablet_locked': 'Tablet locked',
    'tablet_unlocked': 'Tablet unlocked',
    'failed_to_lock': 'Failed to lock tablet',
    'failed_to_unlock': 'Failed to unlock tablet',

    // =========================================================================
    // SUPER ADMIN - NOTIFICATIONS
    // =========================================================================
    'notification_sent': 'Notification sent!',
    'notification_deleted': 'Notification deleted',
    'title_required': 'Title and message are required',
    'notification_type': 'Type',
    'notification_recipients': 'Recipients',
    'all_owners': 'All Owners',
    'select_specific': 'Select Specific',
    'send_notification': 'Send Notification',
    'system_notification': 'System Notification',
    'no_notifications': 'No notifications sent yet',
    'notification_title': 'Title',
    'notification_message': 'Message',

    // =========================================================================
    // SUPER ADMIN - ADMIN MANAGEMENT
    // =========================================================================
    'add_super_admin': 'Add Super Admin',
    'add_admin': 'Add Admin',
    'admin_level': 'Admin Level',
    'assigned_brand': 'Assigned Brand',
    'select_brand': 'Select brand',
    'select_brand_required': 'Please select a brand for Level 2 admin',
    'super_admin_added': 'Super Admin added!',
    'cannot_modify_master': 'Cannot modify Master account',
    'cannot_remove_master': 'Cannot remove Master account',
    'admin_activated': 'Admin activated',
    'admin_deactivated': 'Admin deactivated',
    'remove_admin_confirm': 'Remove Admin?',
    'admin_removed': 'Admin removed',

    // =========================================================================
    // SUPER ADMIN - WHITE LABEL / BRANDS
    // =========================================================================
    'create_new_brand': 'Create New Brand',
    'edit_brand': 'Edit Brand',
    'brand_name': 'Brand Name',
    'brand_domain': 'Domain',
    'primary_color': 'Primary Color',
    'brand_created': 'Brand created successfully!',
    'brand_updated': 'Brand updated!',
    'brand_deleted': 'Brand deleted',
    'name_domain_required': 'Name and Domain are required',
    'cannot_delete_brand': 'Cannot delete brand with existing clients',
    'delete_brand_confirm': 'Delete Brand?',

    // =========================================================================
    // SUPER ADMIN - SETTINGS & BACKUP
    // =========================================================================
    'default_brand_updated': 'Default brand updated!',
    'backup_started': 'Backup started!',
    'pricing_saved': 'Pricing config saved!',

    // =========================================================================
    // COMMON / MISC
    // =========================================================================
    'ok': 'OK',
    'yes': 'Yes',
    'no': 'No',
    'or': 'or',
    'and': 'and',
    'all': 'All',
    'none': 'None',
    'select': 'Select',
    'search': 'Search',
    'filter': 'Filter',
    'clear': 'Clear',
    'refresh': 'Refresh',
    'back': 'Back',
    'next': 'Next',
    'previous': 'Previous',
    'finish': 'Finish',
    'done': 'Done',
    'version': 'Version',
    'pending_update': 'Pending Update',
    'email': 'Email',
    'password': 'Password',
    'name': 'Name',
    'description': 'Description',
    'active': 'Active',
    'inactive': 'Inactive',
    'enabled': 'Enabled',
    'disabled': 'Disabled',
  };
}
