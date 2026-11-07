#!/bin/bash
# How does upstream expect staged apps to get installed, and what decides that data migration runs? Read-only.
U=/root/fuxi/src-unixnu; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
echo "== upstream mentions at pin"
git -C $U grep -n -i -E 'SystemAppMigrator|datamigrat|migration\.plist|staged.apps|staged_system|PurpleBuddy|SetupDone|sheng-setup|sheng-staged' $R -- . ':!*.patch' 2>/dev/null | sed "s/^$R://" | cut -c1-220 | head -40
echo "== later upstream commits"
git -C $U log --all --oneline -i --grep='staged\|migrat' | cut -c1-120 | head -20
echo "== local rules"
grep -rn -i -E 'staged|migrat' /mnt/e/DSH-Fuxi/unixnu-build/fuxi --include='*.md' --include='*.toml' --include='*.sh' --include='*.py' 2>/dev/null | cut -c1-200 | head -20
echo "== OS volume"
L=/mnt/e/DSH-Fuxi/dump/root-peek
grep -a -i -E 'DataMigrat|SystemAppMigrator|datamigrator|MigrationPlugin|migrationd' $L/list.txt $L/sys-list.txt 2>/dev/null | cut -c1-150 | grep -i -E 'SystemApp|datamigrator|\.plist|MigrationPlugins$' | head -20
