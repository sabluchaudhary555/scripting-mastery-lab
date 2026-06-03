# win-user-audit 🔍

A simple Windows batch script that audits local user accounts, group memberships, file permissions, and common privilege escalation vectors — and saves everything to a clean text report.

Built as a learning project while studying CMD-based Windows security.

---

## What it checks

| # | Check |
|---|---|
| 1 | Current logged-in user and full token info |
| 2 | All local user accounts |
| 3 | Members of the Administrators group |
| 4 | All local groups |
| 5 | Password policy (min length, max age, lockout) |
| 6 | Current user privileges (whoami /priv) |
| 7 | Dangerous privileges — SeDebugPrivilege, SeImpersonatePrivilege, SeTakeOwnershipPrivilege |
| 8 | UAC status (enabled or disabled) |
| 9 | NTFS permissions on ProgramData, Program Files, Windows\Temp |
| 10 | Stored credentials via cmdkey |
| 11 | Scheduled tasks running as SYSTEM |
| 12 | AlwaysInstallElevated registry check |

All output is saved to `audit_report.txt` in the same directory.

---

## How to run

> **Must be run as Administrator** for full results.

**Option 1 — Right-click**
Right-click `win-user-audit.bat` → Run as administrator

**Option 2 — Elevated CMD**
```cmd
cd path\to\script
win-user-audit.bat
```

After it finishes:
```cmd
notepad audit_report.txt
```

---

## Sample output (snippet)

```
------------------------------------------------------------
[7] DANGEROUS PRIVILEGE CHECK
------------------------------------------------------------
[OK] SeDebugPrivilege not present
[WARNING] SeImpersonatePrivilege is ENABLED
[OK] SeTakeOwnershipPrivilege not present

------------------------------------------------------------
[8] UAC STATUS
------------------------------------------------------------
HKEY_LOCAL_MACHINE\...\System
    EnableLUA    REG_DWORD    0x1
```

---

## Concepts covered

- `net user` / `net localgroup` — user and group enumeration
- `whoami /all` / `whoami /priv` — token and privilege inspection
- `icacls` — NTFS permission analysis
- `reg query` — registry-based security checks
- `cmdkey /list` — stored credential enumeration
- `schtasks` — scheduled task auditing
- UAC, DACL, SID, and integrity levels

---

## Requirements

- Windows 10 / 11 (or Windows Server)
- Run as Administrator for complete results
- No external tools or installs needed — pure CMD

---

## Related topics

- [NTFS Permissions and icacls](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/icacls)
- [Windows Privilege Escalation Concepts](https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation)
- [UAC Documentation](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/user-account-control/)

---

## Author

**Sabl Chaudhary** — Cybersecurity Lead @ GDSC Purvanchal University
GitHub: [sabluchaudhary555](https://github.com/sabluchaudhary555)
Site: [SSoft.in](https://SSoft.in)