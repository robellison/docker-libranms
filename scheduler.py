#!/usr/bin/env python

# Uses Brian's python cron code from
# http://stackoverflow.com/questions/373335/suggestions-for-a-cron-like-scheduler-in-python

import schedule
import time
import os

def poller_5m():
    print("----- running 5 minute jobs -----")
    os.system("/opt/librenms/poller-wrapper.py")
    os.system("/opt/librenms/discovery.php -h new")
    os.system("/opt/librenms/alerts.php")
    os.system("/opt/librenms/check-services.php")
    print("----- completed 5 minute jobs -----")

def poller_1h():
    print("----- running hourly jobs -----")
    os.system("/opt/librenms/discovery.php -h new >> /dev/null 2>&1")
    print("----- completed hourly jobs -----")    

def poller_daily():
    print("----- running daily jobs -----")
    os.system("/opt/librenms/discovery.php -h all >> /dev/null 2>&1")
    os.system("/opt/librenms/daily.sh >> /dev/null 2>&1")
    print("----- completed daily jobs -----")



schedule.every(5).minutes.do(poller_5m)
schedule.every().hour.do(poller_1h)
schedule.every().day.at("00:01").do(poller_daily)
#schedule.every().monday.do(job)
#schedule.every().wednesday.at("13:15").do(job)

while True:
    schedule.run_pending()
    time.sleep(1)



"""
33  */6   * * *   librenms    /opt/librenms/discovery.php -h all >> /dev/null 2>&1
*/5  *    * * *   librenms    /opt/librenms/discovery.php -h new >> /dev/null 2>&1
*/5  *    * * *   librenms    /opt/librenms/cronic /opt/librenms/poller-wrapper.py 16
15   0    * * *   librenms    /opt/librenms/daily.sh >> /dev/null 2>&1
*    *    * * *   librenms    /opt/librenms/alerts.php >> /dev/null 2>&1
*/5  *    * * *   librenms    /opt/librenms/poll-billing.php >> /dev/null 2>&1
01   *    * * *   librenms    /opt/librenms/billing-calculate.php >> /dev/null 2>&1
*/5  *    * * *   librenms    /opt/librenms/check-services.php >> /dev/null 2>&1

run using:
sudo -H -u librenms python /opt/scheduler.py
sudo -H -u librenms /opt/librenms/cronic /opt/librenms/poller-wrapper.py 16

"""
