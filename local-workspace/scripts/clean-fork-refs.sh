#!/bin/bash
# Removes the temporary fork tracking refs added to the local repository by read-fuxi-fork.sh.
cd /mnt/e/DSH-Fuxi/unixnu-build/fuxi
for r in fts-touch linux main old; do git update-ref -d "refs/remotes/fork/$r"; done
echo "fork refs left: $(git for-each-ref refs/remotes/fork | wc -l)"
git status -sb | head -1
