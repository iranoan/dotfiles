#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ↑Python3 なら本来不要+Emacsの形式を使っている
# vim:fileencoding=utf-8 fileformat=unix
# conky で  https://tenki.jp/ を用いて3日間の天気予報を表示

import requests
import re
import sys
from bs4 import BeautifulSoup
from requests.exceptions import Timeout


def get_current_zipcode():
    '''IPアドレスから現在の郵便番号を推定する'''
    try:
        response = requests.get("http://ip-api.com/json/?lang=ja")
        data = response.json()
        if 'zip' in data:
            return data['zip'].replace('-', '')
        else:
            return None
    except Exception:
        return None


def get_weather_by_zipcode(zipcode):
    '''郵便番号を使ってtenki.jpから天気を取得する'''
    def Error(s):
        print(s)
        print('')
        print('')
        sys.exit()

    if zipcode is None:
        Error('Not get ZIP code')
        return
    try:
        res = requests.get(f'https://tenki.jp/search/?keyword={zipcode}', timeout=(3.0, 7.5))
        for s in BeautifulSoup(res.text, 'html.parser').find_all(['a', 'p'], class_='search-entry-data'):
            url = s.find('a').get('href')
            if url is not None:
                break
    except Timeout:
        Error('tenki.jp TimeOut')
        return
    except Exception:
        Error('Not get tenki.jp page')
        return
    try:
        html = requests.get(f'https://tenki.jp{url}10days.html', timeout=(3.0, 7.5))
    except Timeout:
        Error('tenki.jp TimeOut')
        return
    except Exception:
        Error('tenki.jp Error')
        return
    else:
        soup = BeautifulSoup(html.content, "html.parser")
        for s in soup.find_all('dd', class_='forecast10days-actab')[:3]:  # 最初の3日分
            forecast = s.find_all('div', class_='forecast')[0].text.replace(
                '時々', '|').replace('のち', '/').replace('一時', '.')
            if len(forecast) == 1:
                print('{} {}  {}{:>4}'.format(
                    re.sub(r'(?<=\d)月', '/',
                           re.sub(r'(?<=\d)日', '',
                                  s.find_all('div', class_='days')[0].text)),
                    forecast,
                    s.find_all('div', class_='temp')[0].text.replace('℃', '/', 1).replace('℃', '°C'),
                    s.find_all('div', class_='prob-precip')[0].text))
            else:
                print('{}{}{}{:>4}'.format(
                    re.sub(r'(?<=\d)月', '/',
                           re.sub(r'(?<=\d)日', '',
                                  s.find_all('div', class_='days')[0].text)),
                    forecast,
                    s.find_all('div', class_='temp')[0].text.replace('℃', '/', 1).replace('℃', '°C'),
                    s.find_all('div', class_='prob-precip')[0].text))


get_weather_by_zipcode(get_current_zipcode())
