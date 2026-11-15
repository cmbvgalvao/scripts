#!/bin/bash

# ==========================================
# CONFIGURATION SECTION
# ==========================================

# The email address being migrated (The one clients send emails to)
TARGET_EMAIL="marketing@example.com"

# The new name for the old history
ARCHIVE_EMAIL="marketing-archive@example.com"

# List of users who need access (Space separated)
# REPLACE THESE WITH YOUR REAL EMAILS
DELEGATES=("delegate1@example.com" "delegate2@example.com" "delegate3@example.com" "delegate4@example.com")

# Display name of the new account (what people see on emails from this inbox)
USER_FIRST_NAME=""
USER_LAST_NAME=""

# Path to your GAM executable
GAM="$HOME/bin/gamadv-xtd3/gam"

# ==========================================
# CHECKS (nothing is changed until these pass)
# ==========================================
for v in TARGET_EMAIL ARCHIVE_EMAIL USER_FIRST_NAME USER_LAST_NAME; do
    if [ -z "${!v}" ]; then
        echo "Set $v in the configuration section first." >&2
        exit 1
    fi
done
if [[ " $TARGET_EMAIL $ARCHIVE_EMAIL ${DELEGATES[*]} " == *"@example.com "* ]]; then
    echo "The configuration still has example.com addresses. Replace them first." >&2
    exit 1
fi
if [ ! -x "$GAM" ]; then
    echo "GAM not found at $GAM" >&2
    exit 1
fi

# Stop at the first failed GAM command and say where, so a half-done
# cut-over (group renamed, no new user) never carries on silently.
STEP="checks"
gam_run() {
    if ! "$GAM" "$@"; then
        echo "!!! GAM failed during step: $STEP" >&2
        echo "!!! Stopped. Check the group, alias and user in the Admin console before re-running." >&2
        exit 1
    fi
}

# ==========================================
# PHASE 1: THE CUT-OVER
# ==========================================

echo "=========================================="
echo "STARTING MIGRATION FOR: $TARGET_EMAIL"
echo "Target User Name: $USER_FIRST_NAME $USER_LAST_NAME"
echo "=========================================="

echo ">>> [1/7] Renaming Group to Archive..."
STEP="[1/7] Renaming Group to Archive"
gam_run update group "$TARGET_EMAIL" email "$ARCHIVE_EMAIL"

echo ">>> [2/7] Securing Archive (Read-Only Mode)..."
STEP="[2/7] Securing Archive (Read-Only Mode)"
# 'Managers Can Post' prevents public/team spam. 'Members Can View' keeps history accessible.
gam_run update group "$ARCHIVE_EMAIL" who_can_post_message ALL_MANAGERS_CAN_POST who_can_view_group ALL_MEMBERS_CAN_VIEW

echo ">>> [3/7] Removing Automatic Alias..."
STEP="[3/7] Removing Automatic Alias"
# We must delete the alias immediately so the username is free.
gam_run delete alias "$TARGET_EMAIL"

echo ">>> Waiting 30 seconds for Alias release (Google Directory)..."
sleep 30

echo ">>> [4/7] Creating New User Account..."
STEP="[4/7] Creating New User Account"
# Uses the variables configured above
# 'changepassword off' is CRITICAL to make the account active immediately
gam_run create user "$TARGET_EMAIL" firstname "$USER_FIRST_NAME" lastname "$USER_LAST_NAME" password random changepassword off

echo ">>> Waiting 30 seconds for User propagation (CRITICAL)..."
# This wait prevents the "User does not exist" error during delegation
sleep 30

# ==========================================
# PHASE 2: DELEGATION & CALENDAR
# ==========================================

echo ">>> [5/7] Assigning Access to Delegates..."
STEP="[5/7] Assigning Access to Delegates"

for user in "${DELEGATES[@]}"; do
    echo "------------------------------------------"
    echo "Processing user: $user"
    
    # 1. Email Delegation
    # Grants access to the inbox via the User Icon > Switch Account
    echo "   > Granting Inbox Delegation..."
    gam_run user "$TARGET_EMAIL" delegate to "$user"
    
    # 2. Calendar Permission (ACL)
    # This grants the user the RIGHT to edit the calendar
    echo "   > Granting Calendar Editor Permissions..."
    gam_run calendar "$TARGET_EMAIL" add editor "$user"
    
    # 3. Calendar Subscription (Force add to view)
    # This forces the calendar to appear in their 'My Calendars' list
    # We set a distinct color (Teal) so it stands out
    echo "   > Subscribing user to the Calendar..."
    gam_run user "$user" add calendar "$TARGET_EMAIL" selected true backgroundColor "#16a765"
    
done

echo "------------------------------------------"
echo ">>> [6/7] Verifying Setup..."
STEP="[6/7] Verifying Setup"
gam_run user "$TARGET_EMAIL" show delegates

echo "=========================================="
echo "MIGRATION COMPLETE!"
echo "1. Users must LOG OUT and LOG BACK IN to see the changes."
echo "2. Check the Profile Picture menu for '$USER_FIRST_NAME $USER_LAST_NAME (delegated)'."
echo "3. The Calendar should appear under 'My Calendars' automatically."
echo "=========================================="
