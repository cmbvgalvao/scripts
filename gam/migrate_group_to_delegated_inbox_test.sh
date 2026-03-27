#!/bin/bash

# ==========================================
# CONFIGURATION SECTION
# ==========================================

# 1. Email Settings
# The email address being migrated (The one clients send emails to)
TARGET_EMAIL="test@example.com"
# The new name for the old history archive
ARCHIVE_EMAIL="test-archive@example.com"

# 2. Account Display Name
# This is the name people will see when receiving emails from this inbox
USER_FIRST_NAME="Testy"
USER_LAST_NAME="Test"

# 3. Access List
# Space separated list of user emails who need access
DELEGATES=("admin@example.com")

# 4. GAM Path
# Path to your GAM executable
GAM="$HOME/bin/gamadv-xtd3/gam"

# ==========================================
# PHASE 1: THE CUT-OVER
# ==========================================

echo "=========================================="
echo "STARTING MIGRATION FOR: $TARGET_EMAIL"
echo "Target User Name: $USER_FIRST_NAME $USER_LAST_NAME"
echo "=========================================="

echo ">>> [1/7] Renaming Group to Archive..."
$GAM update group "$TARGET_EMAIL" email "$ARCHIVE_EMAIL"

echo ">>> [2/7] Securing Archive (Read-Only Mode)..."
# 'Managers Can Post' prevents public/team spam. 'Members Can View' keeps history accessible.
$GAM update group "$ARCHIVE_EMAIL" who_can_post_message ALL_MANAGERS_CAN_POST who_can_view_group ALL_MEMBERS_CAN_VIEW

echo ">>> [3/7] Removing Automatic Alias..."
# We must delete the alias immediately so the username is free.
$GAM delete alias "$TARGET_EMAIL"

echo ">>> Waiting 30 seconds for Alias release (Google Directory)..."
sleep 30

echo ">>> [4/7] Creating New User Account..."
# Uses the variables configured above
# 'changepassword off' is CRITICAL to make the account active immediately
$GAM create user "$TARGET_EMAIL" firstname "$USER_FIRST_NAME" lastname "$USER_LAST_NAME" password random changepassword off

echo ">>> Waiting 30 seconds for User propagation (CRITICAL)..."
# This wait prevents the "User does not exist" error during delegation
sleep 30

# ==========================================
# PHASE 2: DELEGATION & CALENDAR
# ==========================================

echo ">>> [5/7] Assigning Access to Delegates..."

for user in "${DELEGATES[@]}"; do
    echo "------------------------------------------"
    echo "Processing user: $user"
    
    # 1. Email Delegation
    # Grants access to the inbox via the User Icon > Switch Account
    echo "   > Granting Inbox Delegation..."
    $GAM user "$TARGET_EMAIL" delegate to "$user"
    
    # 2. Calendar Permission (ACL)
    # This grants the user the RIGHT to edit the calendar
    echo "   > Granting Calendar Editor Permissions..."
    $GAM calendar "$TARGET_EMAIL" add editor "$user"
    
    # 3. Calendar Subscription (Force add to view)
    # This forces the calendar to appear in their 'My Calendars' list
    # We set a distinct color (Teal) so it stands out
    echo "   > Subscribing user to the Calendar..."
    $GAM user "$user" add calendar "$TARGET_EMAIL" selected true backgroundColor "#16a765"
    
done

echo "------------------------------------------"
echo ">>> [6/7] Verifying Setup..."
$GAM user "$TARGET_EMAIL" show delegates

echo "=========================================="
echo "MIGRATION COMPLETE!"
echo "1. Users must LOG OUT and LOG BACK IN to see the changes."
echo "2. Check the Profile Picture menu for '$USER_FIRST_NAME $USER_LAST_NAME (delegated)'."
echo "3. The Calendar should appear under 'My Calendars' automatically."
echo "=========================================="
