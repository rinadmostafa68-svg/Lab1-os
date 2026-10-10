# Simple Antivirus Daemon & Quarantine Tool

This project is a Bash-based file system monitoring daemon and quarantine manager built for our Operating Systems lab. It watches a target directory for changes, flags malicious files based on hardcoded rules, moves them to quarantine, and provides an interactive tool to review or restore false positives.

## Project Structure
- `antivirus` - Background daemon script that polls the folder and handles threat detection and quarantine.
- `restore.sh` - Interactive script to review quarantined files, restore safe files, or delete genuine threats.
- `Makefile` - Automates directory setup, running the daemon, and cleaning status files.
- `README.md` - Project documentation and usage guide.

---

## Step-by-Step Guide

### Step 1: Make Scripts Executable
Before running anything, make sure your shell scripts have execution permissions. Open your terminal in the project folder and run:
```bash
chmod +x antivirus restore.sh

to run --> /antivirus dir quarantine 5