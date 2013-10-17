#!/bin/bash
# This little script has been made to help people who use google spreadsheet and mapbox with url loaded geojson
# Made by n3b https://github.com/N3bTcx
echo

echo -e "Start, csv2geojson with google doc spreadsheet\n"
echo -e "Put the email and the password of the google account"
read -p 'Your gmail address :  ' gmailaddress
read -p 'Your password : ' -s gmailpassword
googleauth=`curl https://www.google.com/accounts/ClientLogin \
--data-urlencode Email=$gmailaddress --data-urlencode Passwd=$gmailpassword \
-d accountType=GOOGLE \
-d source=Google-cURL-Example \
-d service=lh2 | grep Auth | sed 's/.*=//'`
echo
echo -e "Put the url of your document\nTo get them on google spreadsheet: File > Publish on the Web > Insert a public link > CSV"
read -p 'Google Url : ' googledocurl

curl --silent --header Authorization: GoogleLogin auth=$googleauth "$googledocurl" | tee temp.CSV
echo
read -p 'Name of your exported Geojson (with *.geojson) : ' geojsonname
csv2geojson temp.CSV temp.geojson | tee $geojsonname
#yeah I know what a silly trick...
echo -e "\n"
echo "Do you want to send to and FTP (yes/no)?"
read answer > /dev/null
if [ "$answer" == "yes" ]; 
	then read -p 'FTP address please : ' ftpaddress
	read -p 'Login please : ' ftplogin
	read -p 'Password please : ' ftpass
	curl -T $geojsonname $ftpaddress --user $ftplogin:$ftpass
else echo "Ok bro, no FTP."
fi
catfile=`cat $geojsonname | grep -c "coordinates"`
echo "Done. Number of entries is $catfile"
exit 0