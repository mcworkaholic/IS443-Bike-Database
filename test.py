import time
import itertools
from itertools import repeat
import undetected_chromedriver as uc
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

driver = uc.Chrome(use_subprocess=True)
# enter the address where flask is running here
driver.get("http://000.000.0.00/login")
driver.maximize_window()
time.sleep(1)

getRegister= driver.find_element(by=By.ID, value= 'register')
getRegister.click()
time.sleep(1)

# feel free to change
IDDict = {
     'fname': 'Weston',
     'lname': 'Evans',
     'phone': '555-555-5555' ,
     'address': 'SCSU' ,
     'email': 'weston.evans@go.stcloudstate.edu',
     'password':'supersecretpass', 
     'cpwd': 'supersecretpass', 
}

for key, value in IDDict.items():
   l =  driver.find_element(by=By.ID, value= key)
   l.click()
   l.send_keys(value)
   time.sleep(1)


register = driver.find_element(by=By.ID, value= 'registerme')
register.click()

email = driver.find_element(by=By.ID, value= 'email')
email.click()
email.send_keys('weston.evans@go.stcloudstate.edu')
time.sleep(1)

pw = driver.find_element(by=By.ID, value= 'password')
pw.click()
pw.send_keys('supersecretpass')
time.sleep(1)

register = driver.find_element(by=By.ID, value= 'registerme')
register.click()
time.sleep(300)
    