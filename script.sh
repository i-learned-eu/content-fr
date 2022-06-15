for i in $(ls -1 fr | sed -e 's/\..*$//')
do
  msginit -i i18n/$i.pot --locale=en_EN -o i18n/en/$i.po
done
