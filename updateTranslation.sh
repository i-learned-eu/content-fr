if [git show $(git rev-parse origin/master) | grep Author -ne "Author: Gitlab CI <contact@ilearned.eu>"]; then
  for i in $(ls -1 -p fr/ | grep -v / | sed -e 's/\..*$//')
  do
    gettext-md -o i18n/__name__.pot --pot fr/$i.md
    if test -f i18n/en/$i.po; then
      msgmerge --backup=none -U i18n/en/$i.po i18n/$i.pot
    else
      msginit --no-translator -i i18n/$i.pot -o i18n/en/$i.po
      sed -i 's/Language: fr/Language: en/' i18n/en/$i.po
    fi
  done
fi
