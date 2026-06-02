# CMD — Users, Groups & Permissions
> Quick reference notes for Windows CMD security concepts

---

## 1. User Accounts

A **user account** = identity that controls login + what you can do on the system.

| Type | Description |
|---|---|
| Local | Only on that machine |
| Microsoft | Cloud-linked (email login) |
| Domain | Managed by Active Directory |
| Built-in | Pre-made by Windows (Administrator, Guest) |
| Service | Used by background services |

### Key Commands

```cmd
net user                          # list all users
net user john                     # details of specific user
net user alice Pass123 /add       # create user
net user alice /delete            # delete user
net user alice NewPass /          # change password
net user alice /active:no         # disable account
whoami                            # current logged-in user
whoami /all                       # user + SID + groups + privileges
query user                        # all active sessions
```

---

## 2. User Groups

A **group** = collection of users sharing the same permissions.
Instead of setting permissions per-user, set them per-group.

| Type | Scope |
|---|---|
| Local Group | Single machine |
| Domain Local | Same domain |
| Global | Users within domain |
| Universal | Cross-domain (enterprise) |

### Key Commands

```cmd
whoami /groups                         # groups your account belongs to
net localgroup                         # list all groups on machine
net localgroup Administrators          # members of a specific group
net localgroup Administrators alice /add     # add user to group
net localgroup Administrators alice /delete  # remove user from group
```

---

## 3. Important Built-in Local Groups

| Group | What it does |
|---|---|
| Administrators | Full system access |
| Users | Standard — can use apps, can't install |
| Guests | Very restricted |
| Remote Desktop Users | Can RDP into the machine |
| Backup Operators | Can read/write files bypassing NTFS perms |
| Event Log Readers | Can read Windows Event Logs |

### Key Commands

```cmd
net localgroup DevTeam /add                         # create new group
net localgroup DevTeam /comment:"Dev Members"       # add description
net localgroup DevTeam /delete                      # delete group
net localgroup DevTeam alice /add                   # add user to group
net localgroup "Backup Operators"                   # check members
```

---

## 4. Permissions (NTFS)

**Permissions** = what actions are allowed on a file/folder.
Stored in an **ACL (Access Control List)** attached to every object.

| Permission | What it allows |
|---|---|
| Full Control | Everything — read, write, delete, change perms |
| Modify | Read + write + delete. No perm changes |
| Read & Execute | View + run files |
| Read | View only |
| Write | Create files, write data. No delete |

> **Rule:** When NTFS + Share permissions both apply → Windows enforces the **most restrictive** one.

### icacls — View & Manage Permissions

```cmd
icacls C:\Users\alice\Documents     # view permissions

# Permission flags in output:
# (F) = Full Control
# (M) = Modify
# (RX) = Read & Execute
# (R) = Read
# (W) = Write
# (I) = Inherited
# (OI) = Object Inherit (applies to files inside)
# (CI) = Container Inherit (applies to subfolders)
```

---

## 5. Access Control

Windows uses a **Security Reference Monitor** to allow/deny access.

### Key Concepts

| Term | Meaning |
|---|---|
| SID | Unique ID for every user/group. Never changes even if renamed |
| Access Token | Created at login. Contains your SID + groups + privileges |
| ACL | List of ACEs attached to every object |
| DACL | Controls who can access a resource |
| SACL | Controls auditing (logging access attempts) |

```cmd
whoami /user                              # your SID
wmic useraccount get name,sid             # all users + SIDs
```

### How Access Check Works

1. User tries to access a resource
2. Windows checks user's **access token**
3. Windows reads the **DACL** of the resource
4. Matches SIDs in token vs ACEs in DACL
5. **Deny → immediate block** (even if Allow exists)
6. Enough Allow ACEs → access granted
7. No match → denied by default

### icacls for Access Control

```cmd
icacls C:\Data /grant alice:(F)             # give alice full control
icacls C:\Data /grant alice:(OI)(CI)(F)     # + inherit to subfolders/files
icacls C:\Data /deny alice:(W)              # deny write
icacls C:\Data /remove alice               # remove alice's permissions
icacls C:\Data /reset                      # reset to inherited defaults
icacls C:\Data /save perms_backup.txt      # backup permissions
icacls C:\Data /restore perms_backup.txt   # restore permissions
```

---

## 6. Administrator Privileges

| Type | Description |
|---|---|
| Built-in Administrator | Disabled by default. No UAC restrictions |
| Local Admin Member | User added to Administrators group. Has UAC prompts |
| Domain Admin | Controls all machines in the domain |

### UAC (User Account Control)
Even if you're in the Administrators group, processes run as standard user by default. UAC prompts you to elevate when needed.

```cmd
# check if CMD is elevated
whoami /groups | findstr /i "S-1-16-12288"   # returns output = elevated
net session                                   # no error = admin | "Access denied" = not admin

# run as different user
runas /user:Administrator cmd
runas /user:MACHINE\alice "notepad C:\Windows\System32\drivers\etc\hosts"

# enable/disable built-in admin
net user Administrator /active:yes
net user Administrator /active:no

# give/remove admin rights
net localgroup Administrators alice /add
net localgroup Administrators alice /delete

# check your privileges
whoami /priv
```

### Key Privileges to Know

| Privilege | Risk Level |
|---|---|
| SeDebugPrivilege | Very High — can access any process |
| SeImpersonatePrivilege | High — exploited in Potato attacks |
| SeBackupPrivilege | High — read any file bypassing NTFS |
| SeTakeOwnershipPrivilege | High — take ownership of any object |
| SeLoadDriverPrivilege | Very High — load kernel drivers |
| SeShutdownPrivilege | Low — shut down the system |

---

## 7. File Permissions (Practical)

```cmd
icacls C:\secret.txt                              # view perms on file
icacls C:\Reports /grant "Domain Users":(R)       # grant read to group
icacls C:\app.exe /grant bob:(M)                  # grant modify to user
icacls C:\Projects /remove:g bob                  # remove grant entries

# take ownership of locked file
takeown /f C:\locked_file.txt
takeown /f C:\SomeFolder /r /d y                  # recursive

# give yourself full control after taking ownership
icacls C:\locked_file.txt /grant "%username%":(F)
```

### attrib — File Attributes

```cmd
attrib +R +H C:\secret.txt      # make read-only + hidden
attrib -H C:\secret.txt         # unhide
attrib /s /d C:\MyFolder        # view attributes recursively

dir /a C:\Windows               # show all files including hidden + system
dir /ah C:\Users                # show only hidden files
```

---

## 8. Privilege Escalation (Concepts)

**Vertical** = standard user → admin/SYSTEM
**Horizontal** = access another user's data at same level

| Vector | Check Command |
|---|---|
| Unquoted service paths | `wmic service get name,pathname,startmode \| findstr /i /v "C:\\Windows\\"` |
| AlwaysInstallElevated | `reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated` |
| Stored credentials | `cmdkey /list` |
| Scheduled tasks | `schtasks /query /fo LIST /v \| findstr /i "Run As User"` |
| SeImpersonatePrivilege | `whoami /priv \| findstr /i "SeImpersonatePrivilege"` |
| Service binary path | `sc qc <servicename>` |

---

## 9. Security Best Practices

```cmd
net localgroup Administrators              # audit who has admin rights
net accounts                               # check password policy
net user                                   # list all users, spot unused ones
icacls C:\ProgramData                      # check for Everyone:(F) — dangerous
icacls "C:\Program Files"                  # same check
whoami /priv                               # check for dangerous privileges
auditpol /get /category:*                  # check audit policies

# verify UAC is enabled
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA
# Value 1 = enabled (good), Value 0 = disabled (bad)
```

### Integrity Levels (MIC)

| Level | Who |
|---|---|
| Untrusted | Anonymous, sandboxed |
| Low | Browser in protected mode |
| Medium | Standard user processes |
| High | Elevated admin processes |
| System | Kernel, services |

> Lower integrity process **cannot write** to higher integrity objects — even if NTFS allows it.

---

## Quick Cheat Sheet

```cmd
# USER MANAGEMENT
net user                              # list users
net user <name> <pass> /add           # create user
net user <name> /delete               # delete user
net user <name> /active:no            # disable user
whoami /all                           # full current user info

# GROUP MANAGEMENT
net localgroup                        # list groups
net localgroup <group> <user> /add    # add user to group
net localgroup <group> <user> /delete # remove user from group

# PERMISSIONS
icacls <path>                         # view permissions
icacls <path> /grant <user>:(F)       # grant full control
icacls <path> /deny <user>:(W)        # deny write
icacls <path> /remove <user>          # remove permissions
takeown /f <path>                     # take ownership

# PRIVILEGE CHECK
whoami /priv                          # list your privileges
whoami /groups                        # list your groups
net session                           # check if admin
auditpol /get /category:*             # audit policy status
```