#!/bin/bash

# muccc hackfriday mail bot
# hacked together by iggy@muc.ccc.de

# scrape the wiki - find the friday - get the content - send an email

HACKFRIDAY_URL=http://wiki.muc.ccc.de/hackfriday
TO_ADDRESS=members@muc.ccc.de
FROM_ADDRESS=hackfriday@muc.ccc.de

# mail or sendmail
MAILER=mail


echo "Scraping $HACKFRIDAY_URL"

DATE_NEXT_FRIDAY=$(date -dnext-friday +%Y-%m-%d)
DATE_NEXT_NEXT_FRIDAY=$(date -d'next-friday+7 days' +%Y-%m-%d)

echo "Next friday: $DATE_NEXT_NEXT_FRIDAY"
echo "Next next friday: $DATE_NEXT_NEXT_FRIDAY"

HTML=$(curl -sS $HACKFRIDAY_URL)
 
LINE_FROM=$(grep <<<"$HTML" -n "<h2.*${DATE_NEXT_FRIDAY}</h2>" | cut -f1 -d:)
LINE_TO=$(grep <<<"$HTML" -n "<h2.*${DATE_NEXT_NEXT_FRIDAY}</h2>" | cut -f1 -d:)
((LINE_FROM++))
((LINE_TO--))

echo "Relevant content in line $LINE_FROM to line $LINE_TO"

FRIDAY_HTML=$(sed -n "${LINE_FROM},${LINE_TO}p" <<<"$HTML")
FRIDAY_TEXT=$(sed -e 's/<[^>]*>//g' <<<"$FRIDAY_HTML" | sed '/^[[:space:]]*$/d')


EMAIL_SUBJECT="Hackfriday am ${DATE_NEXT_FRIDAY}"

EMAIL_BODY=$(cat <<EOF
Werte Lebensformen,

Wir laden ein zum Hackfriday am ${DATE_NEXT_FRIDAY} mit folgendem Programm:

${FRIDAY_TEXT}

Einlass ab 19:00, Programm ab 20:00, anschließend geselliges Beisammensein. 

Alle Angaben ohne Gewähr.

Dieses Schreiben wurde maschinell erstellt und ist ohne Unterschrift gültig.
EOF
)


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
  echo -e "To:$TO_ADDRESS\nFrom:$FROM_ADDRESS\nSubject:$EMAIL_SUBJECT\n$EMAIL_BODY\n." | sendmail -t
fi
