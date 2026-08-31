# Raycast configuration

Raycast stores its live data in an encrypted, machine-specific database. Do not
copy that database into this repository.

To save a portable configuration from the current Mac, run Raycast's **Export
Preferences & Data** command and save the resulting file here as
`raycast.rayconfig`. It can contain snippets, quicklinks, extensions, aliases,
and hotkeys, so review it before committing.

`install.sh` copies `raycast.rayconfig` to the new Mac's Desktop. In Raycast,
run **Import Preferences & Data** and select that file.
