import pandas as pd

# 프로젝트에 startapps 명령어로 생성되지 않은 파일에서 장고에 등록된 모델이나 함수를 사용할 때 다음과 같은 에러가 발생한다.

# django.core.exceptions.ImproperlyConfigured: Requested setting INSTALLED_APPS, but settings are not configured.
# You must either define the environment variable DJANGO_SETTINGS_MODULE or call settings.configure() before accessing settings.

# 이를 해결하기 위해선 환경을 장고에 맞춰주기 위해서 다음과 같은 코드를 from user.models import model 과 같은 파일 위쪽에 선언해준다.

import os

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

import django

django.setup()

from places.models import Place, Tag

import requests
import shutil
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from webdriver_manager.chrome import ChromeDriverManager
import time

from config import settings

# Read csv file.
df = pd.read_excel(r"C:\work_django\BE_AI_GO\api\data.xlsx", engine="openpyxl")

chrom_options = Options()
chrom_options.add_experimental_option("detach", True)

chrom_options.add_experimental_option("excludeSwitches", ["enable-logging"])

service = Service(executable_path=ChromeDriverManager().install())
browser = webdriver.Chrome(service=service, options=chrom_options)

browser.get("https://map.naver.com/")
browser.implicitly_wait(10)  # 로딩이 끝날 때까지 10초까지는 기다려줌
search = browser.find_element(By.CSS_SELECTOR,".input_search")
search.click()
count = 0

# Connect to (create) database.
for index, row in df.iterrows():
    if count == 0:
        search = browser.find_element(By.CSS_SELECTOR,".input_search")
        search.click()
        search.send_keys(row["street_name_address"]+" "+row["name"])
        search.send_keys(Keys.ENTER)
        browser.find_element(By.CSS_SELECTOR, "#lnb > div.lnb_group > div > div.lnb_nav_area._nav_area_root > div > div.api_flicking_wrap._conveyer_root > div:nth-child(3) > a").click()
        count += 1
    else:
        search = browser.find_element(By.CSS_SELECTOR,"#nx_query")
        search.clear()
        search.click()
        search.send_keys(row["street_name_address"]+" "+row["name"])
        search.send_keys(Keys.ENTER)

    #time.sleep(5)
    #browser.find_element(By.CSS_SELECTOR, ".btn_option._search_option_open_btn").click()
    #browser.find_element(By.CSS_SELECTOR, "#snb > div.mod_group_option_sort._search_option_detail_wrap > ul > li.bx.ccl > div > div > a:nth-child(3)").click()

    img_element = browser.find_elements(By.CSS_SELECTOR, "#main_pack > section.sc_new.sp_nimage._fe_image_viewer_prepend_target > div.api_subject_bx._fe_image_tab_list_root.ani_fadein > div > div > div.image_tile._fe_image_tab_grid > div:nth-child(1) > div > div > div > img")
    if len(img_element) == 0:
        img_url = 'https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2F20140819_170%2Fshrtkvudst_14084484749649SuTm_PNG%2F%25C7%25C1%25B6%25F5%25C4%25A1%25BD%25BA%25C4%25DA_%25B1%25B3%25C8%25B2_%25C7%25E0%25BA%25B9_10%25B0%25E8%25B8%25ED_%25281%2529.png&type=a340'
    else:
        img_element = browser.find_element(By.CSS_SELECTOR, "#main_pack > section.sc_new.sp_nimage._fe_image_viewer_prepend_target > div.api_subject_bx._fe_image_tab_list_root.ani_fadein > div > div > div.image_tile._fe_image_tab_grid > div:nth-child(1) > div > div > div > img")

        img_url = img_element.get_attribute("src")
    # # 이미지 URL을 바로 'image' 열에 저장
    # row["image"] = img_url
    response = requests.get(img_url, stream=True)
    if response.status_code == 200:
        filename = os.path.join(settings.STATIC_ROOT, f'{row["name"]}_image.jpg')
        with open(filename, 'wb') as f:
            response.raw.decode_content = True
            shutil.copyfileobj(response.raw, f)
    # 저장된 파일의 URL을 row["image"]에 저장
        row["image"] = os.path.join(settings.STATIC_URL, f'{row["name"]}_image.jpg')

    place = Place.objects.create(
        name=row["name"],
        image=row["image"],
        classification=row["classification"],
        street_name_address=row["street_name_address"],
        hardness=row["hardness"],
        latitude=row["latitude"],
        like=row["like"],
        info=row["info"],
        call=row["call"],
    )
    place.save()