cat > filename_parser.sh << 'EOF'
#!/bin/bash

read -p "Enter filepath: " filepath

filename="${filepath##*/}"
directory="${filepath%/*}"
extension="${filename##*.}"
basename="${filename%.*}"

echo ""
echo "======================================"
echo "        FILENAME PARSER"
echo "======================================"
echo "  Input     : $filepath"
echo "  Filename  : $filename"
echo "  Directory : $directory"
echo "  Basename  : $basename"
echo "  Extension : $extension"
echo "======================================"
EOF
chmod +x filename_parser.sh
bash filename_parser.sh
```

Run that full block in your Kali terminal. Test with:
```
/home/hacker/scripts/deploy.sh