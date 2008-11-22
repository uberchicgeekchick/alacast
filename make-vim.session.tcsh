#!/bin/tcsh -f
printf '#\!/bin/tcsh -f\nvim-enhanced -p \n' >! .vim.session
find OPMLs/ -iregex '.*\.swp$' >> .vim.session
ex -s '+3,$s/\(.*\)\/\.\(.*\.opml\).swp[\r\n]\+/"\1\/\2"\ /g' '+2s/[\r\n]\+//' '+wq' .vim.session
chmod +x .vim.session
