for i in $(ls -1 -p fr/ | grep -v / | sed -e 's/\..*$//')
do
  node /usr/local/lib/node_modules/gettext-markdown/bin/gettext-md.js -o i18n/__name__.pot --pot fr/$i.md
  if test -f i18n/en/$i.po; then
    msgmerge --backup=none -U i18n/en/$i.po i18n/$i.pot
  else
    msginit --no-translator -i i18n/$i.pot -o i18n/en/$i.po
    sed -i 's/Language: fr/Language: en/' i18n/en/$i.po
  fi
done

