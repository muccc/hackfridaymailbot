#!/bin/bash

# muccc hackfriday mail bot
# hacked together by iggy@muc.ccc.de

# scrape the wiki - find the friday - get the content - send an email

HACKFRIDAY_URL=https://wiki.muc.ccc.de/hackfriday
TO_ADDRESS=members@muc.ccc.de
FROM_ADDRESS=hackfriday@muc.ccc.de

CONTENT_TYPE='text/plain; charset="UTF-8"'

# mail or sendmail
MAILER=sendmail


echo "Scraping $HACKFRIDAY_URL"

DATE_NEXT_FRIDAY=$(date -dnext-friday +%Y-%m-%d)
DATE_NEXT_NEXT_FRIDAY=$(date -d'next-friday+7 days' +%Y-%m-%d)
DATE_NEXT_NEXT_NEXT_FRIDAY=$(date -d'next-friday+14 days' +%Y-%m-%d)

echo "Next friday: $DATE_NEXT_FRIDAY"
echo "Next next friday: $DATE_NEXT_NEXT_FRIDAY"
echo "Next next next friday: $DATE_NEXT_NEXT_NEXT_FRIDAY"

HTML=$(curl -sS $HACKFRIDAY_URL)

function getText () {
  HTML="$1"
  FDATE="$2"
  FDATE_NEXT="$3"

  LINE_FROM=$(grep <<<"$HTML" -n "<h2.*${FDATE}</h2>" | cut -f1 -d:)
  LINE_TO=$(grep <<<"$HTML" -n "<h2.*${FDATE_NEXT}</h2>" | cut -f1 -d:)
  ((LINE_FROM++))
  ((LINE_TO--))

  FRIDAY_HTML=$(awk "NR==$LINE_FROM,NR==$LINE_TO" <<< "$HTML")
  FRIDAY_TEXT=$(sed -e 's/<[^>]*>//g' <<<"$FRIDAY_HTML" | sed '/^[[:space:]]*$/d')

  echo "$FRIDAY_TEXT"
  return 0
}

FRIDAY_TEXT=$(getText "$HTML" "$DATE_NEXT_FRIDAY" "$DATE_NEXT_NEXT_FRIDAY")

NEXT_FRIDAY_TEXT=$(getText "$HTML" "$DATE_NEXT_NEXT_FRIDAY" "$DATE_NEXT_NEXT_NEXT_FRIDAY")


EMAIL_SUBJECT="Hackfriday am ${DATE_NEXT_FRIDAY}"

EMAIL_BODY=$(cat <<EOF
Werte Lebensformen,

Wir laden ein zum Hackfriday am ${DATE_NEXT_FRIDAY} mit folgendem Programm:

${FRIDAY_TEXT}

Das Programm beginnt ab 20:00h, anschließend geselliges Beisammensein. 

Nachdem der Club aufgrund der Ausgangsbeschränkungen momentan geschlossen ist,
findet der hack!friday online statt.

Alle Angaben ohne Gewähr.

Dieses Schreiben wurde maschinell erstellt und ist ohne Unterschrift gültig.
EOF
)

if  echo "$NEXT_FRIDAY_TEXT" | grep -q TBD  ; then

  SUBMISSIONS_PLZ=$(cat <<EOF


PS: Im wiki steht noch kein Thema für den übernächsten Hackfriday am ${DATE_NEXT_NEXT_FRIDAY}.
https://wiki.muc.ccc.de/hackfriday freut sich auf Deine Einreichung.

EOF
)

  EMAIL_BODY=$EMAIL_BODY$SUBMISSIONS_PLZ
fi


echo
echo "Mail Subject: $EMAIL_SUBJECT"
echo
echo "Mail Body:"
echo "*******"
echo "$EMAIL_BODY"
echo "*******"

if [ $MAILER == "mail" ] ; then
  echo "sending email to $TO_ADDRESS using mail"
  mail -s "$EMAIL_SUBJECT" "$EMAIL_ADDRESS" <<<"$EMAIL_BODY"
elif [ $MAILER == "sendmail" ] ; then
  echo "sending email to $TO_ADDRESS using sendmail"
  echo -e "To:$TO_ADDRESS\nFrom:$FROM_ADDRESS\nContent-Type:$CONTENT_TYPE\nMIME-Version:1.0\nSubject:$EMAIL_SUBJECT\n$EMAIL_BODY\n." | sendmail -t
fi
