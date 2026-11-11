# scripts

Bash scripts I wrote while running IT for a bootcamp and its sister companies (2024–2026): setting up classroom Macs, managing Google Workspace mailboxes, and automating AWS and Linux chores. Addresses and names are placeholders.

## What's here

| Folder | What it does |
|---|---|
| `bin/runScriptOnRemote/` | Run a script on many classroom Macs over SSH. `runOnHosts <hosts.csv> <script>` reads `username,hostname` pairs and runs the script on each machine. The small scripts next to it are the payloads: create a local admin or user, install Homebrew, VS Code or Blender, update everything, restart or shut down. Used to prepare each new cohort's iMacs, which saved 4–6 hours per intake. |
| `gam/` | Google Workspace with [GAM](https://github.com/GAM-team/GAM): turn a group address into a real mailbox shared by several people (delegated inbox), keeping the old history in an archive account. Includes a test version that runs against test accounts first. |
| `aws/` | AWS Cloud9 helpers for student environments: list every environment as JSON, and reset an environment's window layout. |
| `ec2_user_data/` | EC2 user data that prepares an Ubuntu server for [LibreDesk](https://github.com/abhinavxd/libredesk) (a self-hosted help desk): system update, Fail2ban, Docker, then the app via Docker Compose. |
| `n8n/` | Run the n8n automation tool in Docker with a persistent volume. |
| `bin/` | Linux admin helpers (fix `.gitconfig` ownership in home folders, remove old lab users, log Wi-Fi changes, set up SSH keys) and shell-scripting exercises (`inpath`, `niceNumber`, `normDate`, `validAlphaNum`). |

## Notes

- Scripts that create accounts read passwords from variables that are empty in this repo; set them at run time and never commit them.
- `bin/delete_users` removes every normal user account (UID 1000 and above) not in its exclude list. It was written for resetting lab machines between cohorts; don't run it anywhere else.
