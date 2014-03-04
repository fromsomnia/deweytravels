---
layout: default
title: Git Tutorial
---

# Git Tutorial
--------------

To check out the Git repo:
    => git clone https://github.com/stephenq/dewey

After committing your local changes, to push into production:
1. git pull --rebase origin master
   If there is a conflict, fix the conflicts, then commit the changes.
2. git push heroku master
3. git push origin master
