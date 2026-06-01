# CMD — File & Folder Management Notes

## 1. Creating Folders
```cmd
mkdir FolderName              :: create folder
mkdir C:\Dev\Projects\Web     :: creates all levels at once (no error if exists)
md FolderName                 :: same as mkdir
```

## 2. Creating Files
```cmd
echo Hello > file.txt         :: create file with text (> overwrites)
echo More >> file.txt         :: append to file
type nul > empty.txt          :: empty file
copy nul empty.txt            :: empty file (alternate)
fsutil file createnew f.txt 1024  :: file with exact size (bytes)
```

## 3. Removing Folders
```cmd
rmdir FolderName              :: remove EMPTY folder only
rmdir /s /q FolderName        :: remove folder + all contents (no prompt)
```
> ⚠️ No Recycle Bin — permanent delete!

## 4. Copying Files
```cmd
copy file.txt D:\Backup\                   :: basic copy
copy /y file.txt D:\Backup\               :: copy, no overwrite prompt
copy file1.txt + file2.txt merged.txt     :: merge two files
xcopy C:\Src D:\Dest /s /e /i /y          :: copy folders recursively
robocopy C:\Src D:\Dest /e /mir           :: mirror sync (best for backups)
```

| Tool | Use For |
|------|---------|
| `copy` | Single files |
| `xcopy` | Folder trees |
| `robocopy` | Production backups, large trees |

## 5. Moving Files
```cmd
move file.txt D:\Archive\               :: move file
move file.txt D:\Archive\newname.txt    :: move + rename
move *.log C:\Logs\                     :: move by pattern
move /y file.txt D:\Final\              :: no overwrite prompt
```

## 6. Renaming
```cmd
ren old.txt new.txt           :: rename file
ren OldFolder NewFolder       :: rename folder
ren *.txt *.bak               :: bulk rename extension
ren log_*.txt backup_*.txt    :: rename with prefix
```
> ❌ Can't change path with `ren` — use `move` for that

## 7. Deleting Files
```cmd
del file.txt              :: delete file
del /q file.txt           :: no confirmation
del *.tmp                 :: delete by pattern
del /s *.log              :: delete recursively in subfolders
del /f protected.txt      :: force delete read-only file
del /q /s C:\Temp\*       :: delete all files in folder (keeps folder)
```

## 8. Viewing Files
```cmd
type file.txt             :: print file to screen
type big.txt | more       :: page by page (Space = next, Q = quit)
find "error" app.log      :: search text in file
find /i /n "Error" app.log    :: case-insensitive + line numbers
findstr /r "[0-9]" file.txt   :: regex search
findstr /s "pass" *.txt       :: search recursively
```

## 9. Hidden & System Files
```cmd
dir /a        :: show all files including hidden/system
dir /ah       :: show only hidden files
dir /as       :: show only system files
```

## 10. File Attributes
```cmd
attrib file.txt           :: view attributes
attrib +h file.txt        :: hide file
attrib -h file.txt        :: unhide file
attrib +r file.txt        :: make read-only
attrib -r file.txt        :: remove read-only
attrib +h +s folder /s /d :: hide folder recursively
attrib -h -s /s /d C:\Path :: unhide everything (malware recovery)
```

| Attribute | Meaning |
|-----------|---------|
| `A` | Archive (modified since backup) |
| `H` | Hidden |
| `S` | System |
| `R` | Read-only |