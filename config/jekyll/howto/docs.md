---
layout: default
title: Editing Dewey's Internal Documentation
---

# Adding and Editing Dewey's Internal Documentation
--------------

Dewey's Internal Documentation for employees (/internal) is built with [Jekyll] (https://github.com/jekyll/jekyll), a blog-aware static site generator in Ruby. Currently we are not using the blog feature. Jekyll is mainly used to interpret Markdown documents to display-able texts inside /internal.

To add a new documentation page:
* Go to /config/jekyll, then to the appropriate dir. If you are adding a new blog post, go to posts. If you are adding to /internal/howto, go to the howto folder. See the documentation on Jekyll's directory structure [here] (http://jekyllrb.com/docs/pages/).
* Write the new document with Markdown. See the cheatsheet [here] (http://nestacms.com/docs/creating-content/markdown-cheat-sheet)
* Run bundle exec rake generate. This will generate the displayable html document in /public/internal.

To edit a new doc:
* Find the appropriate file in /config/jekyll.
* Edit the document with Markdown.
* Run bundle exec rake generate. This will generate the displayable html document in /public/internal.

