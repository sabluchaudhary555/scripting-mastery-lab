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
