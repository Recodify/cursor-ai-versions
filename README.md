# Cursor.Ai AppImage Version Pin

Platform/arch: Linux x86_64

This will remove the auto-update functionality from the Cursor AppImage.

## Usage

`$ sudo chmod +x ./pin.sh`

then

`$./pin.sh` (defaults to version 0.42.5)

or

`$./pin.sh 0.42.5` (or other version)


## Note

You must have the version you wish to pin locally and in the root of this repo.

e.g.

```
user@machine:~/code/cursor-ai-versions$ tree
.
├── cursor-0.42.5.AppImage **(this)**
├── pin.sh
└── README.md
```

## Tested on

Version 0.42.5