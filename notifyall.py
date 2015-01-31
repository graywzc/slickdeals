import MySQLdb
from datetime import date
from datetime import timedelta
import smtplib
from email.mime.text import MIMEText
server = smtplib.SMTP('smtp.gmail.com', 587)

server.ehlo()
server.starttls()
server.ehlo()
server.login("graywzc.deal@gmail.com", "f983jOv2")
conn=MySQLdb.connect(user="graywzc",passwd="2326838", db="deals")
conn1=MySQLdb.connect(user="graywzc",passwd="2326838", db="deals")

today=date.today()
yesterday = today - timedelta(days=1)
s_today=str(today.year)+'-'+str(today.month)+'-'+str(today.day)
s_yesterday=str(yesterday.year)+'-'+str(yesterday.month)+'-'+str(yesterday.day)

myquery="select date,title,link,votes,score,notified,id,category from sdTbl where (date='"+s_today+"' or date='"+s_yesterday+"') and score>10"

cur = conn.cursor()
cur.execute(myquery)
cur1 = conn1.cursor()

row = cur.fetchone()
while row is not None:
    if row[5] == 'no':
        msg = MIMEText("title "+row[1]+"\nurl "+row[2]+"\nvotes "+str(row[3])+" score "+str(row[4]))
        msg['Subject'] = "[SlickDeals]" + row[1]
        server.sendmail("graywzc.deal@gmail.com", "graywzc.deal@gmail.com", msg.as_string())
        myupdate="update sdTbl set notified='yes' where id ="+row[6]
        cur1.execute(myupdate) 
    row = cur.fetchone()


