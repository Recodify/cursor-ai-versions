VERSION="${1:-0.42.5}"
STATIC_FILE="cursor-static-$VERSION.AppImage"

if [ -e "$STATIC_FILE" ]; then
    echo "Static Cursor version($VERSION) with filename '$STATIC_FILE' already exists, delete it if re-running"
    exit 1
fi

echo "Checking if appimagetool is installed"
if ! command -v appimagetool &> /dev/null; then
    echo "appimagetool not found. Downloading..."
    wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x appimagetool-x86_64.AppImage
    sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool
else
    echo "  - appimagetool is already installed, skipping install."
fi

echo "Checking if cursor $VERSION is available"

FILE="./cursor-$VERSION.AppImage"

if [ ! -e "$FILE" ]; then
    echo "You need an existing version $VERSION in the root of this repo."
    exit 1
else
    echo "  - Pinned source version of cursor exists"
fi

DIR="squashfs-root"

if [ -d "$DIR" ]; then
  rm -rf "$DIR"
  echo "Removing old extract. Directory $DIR deleted."
  echo "  - done"
else
  echo "Old extract does not exist, skippping"
fi

echo "Extracting AppImage"
$FILE --appimage-extract > extraction.log 2>&1
echo "  - done"

echo "Backing up app-update.yml"
mv squashfs-root/resources/app-update.yml squashfs-root/resources/app-update.yml.bak
echo "  - done"

echo "Updating app-update.yml to disable auto-updates"

echo 'channel: latest
provider: generic
url: https://recodify.co.uk
updaterCacheDirName: cursor-updater'  >  squashfs-root/resources/app-update.yml
echo "  - done"

echo "Repackacing AppImage"
appimagetool squashfs-root cursor-static-$VERSION.AppImage > repackage.log 2>&1
echo "  - done"

echo "Tidying up"
rm -rf squashfs-root
echo "  - done"

echo "Setting executable access on static version $STATIC_FILE"
chmod +x $STATIC_FILE
echo "  - done"

alias_name="cursor-static"
alias_command="$(pwd)/$STATIC_FILE"

# Display the alias that will be added
echo "Alias to be added: alias $alias_name='$alias_command'"
read -p "Do you want to add this to your .bashrc? Only do this if not already added or you'll get duplicates (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    # Append to .bashrc
    echo -e "\nalias $alias_name='$alias_command'" >> ~/.bashrc
    echo "Alias added to .bashrc successfully."

    # Reload .bashrc
    source ~/.bashrc
    echo "Your new alias is now active. Old terminals may require sourcing, e.g. source ~.bashrc"
else
    echo "Alias addition cancelled."
fi

echo "DONE! All good. As you were sailor. Version $VERSION FTW."