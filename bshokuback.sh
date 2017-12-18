#!/bin/bash
#
#  bshokuback.sh
#

BASEURL="http://www.b-shoku.jp/modules/wordpress/?author="
UserID=$1
SAVEDIR=$2

state=0
[ -z $UserID ] && state=1
[ -z $SAVEDIR ] && state=1

print_help() {
	echo "Usage: $0 UserID Save_Dir"
	echo "       UserID: B食会員番号"
	echo "       Save_Dir: 保存ディレクトリ"
}

if [ $state -eq 1 ]; then
	print_help
	exit 1
fi

[ -e ${SAVEDIR} ] || mkdir -p ${SAVEDIR}
[ -e ${SAVEDIR}/images ] || mkdir -p ${SAVEDIR}/images

i=1
while true; do
  # ページ単位で最新から最古までダウンロードする。
  wget -nv -O ${SAVEDIR}/$i.html "${BASEURL}${UserID}&paged=$i"
  nkf -w ${SAVEDIR}/$i.html > ${SAVEDIR}/$i-utf8.html
  mv ${SAVEDIR}/$i-utf8.html ${SAVEDIR}/$i.html

  # 記事の無いページまで来たら終了する。
  ret=$(grep "該当する記事はありません" ${SAVEDIR}/$i.html | wc -l)
  [ $ret != 0 ] && exit 0

  # ページ内にある記事のURLを抜き出してそれぞれダウンロードする。
  for l in $(grep "この記事のURL" ${SAVEDIR}/$i.html | cut -d"\"" -f 2); do
     artnum=$(echo $l | cut -d "=" -f3)
     wget -nv -O ${SAVEDIR}/article-${artnum}.html $l
     nkf -w ${SAVEDIR}/article-${artnum}.html > ${SAVEDIR}/article-${artnum}-utf8.html

     # 記事ページ内の画像をダウンロードする。
     for p in $(grep img ${SAVEDIR}/article-${artnum}-utf8.html | grep attach | sed -e "s/<br/\n/g" | sed -n 's/^.*src="\([^"]*\)".*$/\1/p'); do
       t=$(echo ${p} | sed -e "s/http:\/\/www.b-shoku.jp\/modules\/wordpress\/attach\/u${UserID}\///")
       wget -nv -O ${SAVEDIR}/images/${t} ${p}
     done
     rm -f ${SAVEDIR}/article-${artnum}-utf8.html
  done
  i=$(expr $i + 1)
done

