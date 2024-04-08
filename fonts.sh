#!/usr/bin/env zsh

# Description: Automatically patch Apple's SF Mono Fonts selectively with nerdfonts patcher
# Dependencies: 7z, aria2

# Dependencies
sudo apt update
sudo apt install p7zip-full aria2 -y

# Variables
directory=$(pwd)

apple_fonts() {
	mkdir -p $directory/tmpdir $directory/tmpdir/SF-Mono $directory/tmpdir/AppleFonts $directory/tmpdir/src
	cd $directory/tmpdir

	download_links=(
		"https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg"
		"https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg"
		"https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg"
		"https://devimages-cdn.apple.com/design/resources/download/NY.dmg"
		"https://devimages-cdn.apple.com/design/resources/download/SF-Armenian.dmg"
		"https://devimages-cdn.apple.com/design/resources/download/SF-Georgian.dmg"
		"https://devimages-cdn.apple.com/design/resources/download/SF-Hebrew.dmg"
		"https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg"
	)

	for link in ${download_links[@]}; do
		aria2c -x16 -s16 --continue=true "$link"
	done

	for archive in *.dmg; do
		7z e "$archive" -y -osrc/
		cd src/
		7z x *.pkg -y
		7z x 'Payload~'
		if [[ $archive == *"Mono"* ]]; then
			mv Library/Fonts/* "$directory/tmpdir/SF-Mono/"
		else
			mv Library/Fonts/* "$directory/tmpdir/AppleFonts/"
		fi
		cd "$directory/tmpdir/"
		rm -rf src/*
	done
	rm -rf src/

	set +e && docker run --rm -v $directory/tmpdir/SF-Mono/:/in:Z -v $directory/tmpdir/AppleFonts/:/out:Z nerdfonts/patcher --no-progressbars --quiet && set -e
	7z a $directory/AppleFonts.7z $directory/tmpdir/AppleFonts
}

apple_fonts
