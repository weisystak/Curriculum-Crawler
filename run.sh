a=""
#cou=0
#輸入帳密
exec 3>&1;
id=$(dialog --title 學號 --inputbox 請輸入學號  0 0 2>&1 1>&3);
pw=$(dialog --title "Password" --insecure --passwordbox "交大單一路口的密碼" 10 35 2>&1 1>&3);
exec 3>&-;

while [ -z "$a" ] 
do
curl  --cookie-jar cookie_file.txt --cookie cookie_file.txt https://portal.nctu.edu.tw/captcha/pic.php > /dev/null
curl  --cookie-jar cookie_file.txt --cookie cookie_file.txt https://portal.nctu.edu.tw/captcha/pitctest/pic.php > image.png
convert -resize 400% image.png image_large.png
convert image_large.png -type Grayscale image_g.png
convert image_g.png -threshold 55% image_t.png
# number=`curl -F "image=@image.png" https://nasa.cs.nctu.edu.tw/sap/2017/hw2/captcha-solver/api/`
tesseract image_t.png o -psm 7 digits
number=`head -1 o.txt | tr -d "[:space:]"`
echo "number $number"
a=`curl --cookie-jar cookie_file.txt --cookie cookie_file.txt  -d "username=$id&password=$pw&seccode=$number&pwdtype=static&Submit2=登入(Login)" -L https://portal.nctu.edu.tw/portal/chkpas.php | grep "<title>校園資訊系統</title>"`
#cou=`expr $cou + 1`
#echo -e "第 $cou 次 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
done

b=`curl --cookie-jar cookie_file.txt --cookie cookie_file.txt  'https://portal.nctu.edu.tw/portal/relay.php?D=cos' | node extractFormdata.js`
curl --cookie-jar cookie_file.txt --cookie cookie_file.txt   "https://course.nctu.edu.tw/index.asp?$b" > /dev/null
curl --cookie-jar cookie_file.txt --cookie cookie_file.txt -L https://course.nctu.edu.tw/adSchedule.asp | iconv -f big5 -t utf-8 | 
awk '{if(NR>=74 && NR<=899){print;}}' | awk 'BEGIN{ORS =" "; cou=0;}{
if( match($0,/"3">\(.*\)<\/font>/))
    {print substr($0,RSTART+4,RLENGTH-11);
    cou=cou+1;
    }
else if( match($0,/<h2>\&nbsp<\/h2>/))
    {print ".";
    cou=cou+1;
    }
else if( match($0,/.*<br/))
    {
	    print substr($0,RSTART+3,RLENGTH-6);
        cou=cou+1;
    }	
if(cou == 7){
	cou = 0;
	print "\n";}
}'  | column -t 
