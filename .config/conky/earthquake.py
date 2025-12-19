#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ↑Python3 なら本来不要+Emacsの形式を使っている
# vim:fileencoding=utf-8 fileformat=unix
# conky で https://earthquake.tenki.jp/bousai/earthquake/ で直近3つの地震情報表示

from datetime import datetime
import requests
from bs4 import BeautifulSoup
from requests.exceptions import Timeout

try:
    html = requests.get('https://earthquake.tenki.jp/bousai/earthquake/', timeout=(3.0, 7.5))
except Timeout:
    print('')
    print('')
    print('')
else:
    soup = BeautifulSoup(html.content, "html.parser")
    for s in soup.find('table', class_='earthquake-entries-table').find_all('tr')[1:4]:  # 最初の3日分
        print('{}{}/{}{}'.format(
            datetime.strptime(s.find_all('td', class_='datetime')[0].text.strip(),
                              "%Y年%m月%d日 %H時%M分頃").strftime("%m/%dT%H:%M"),
            s.find_all('td', class_='magnitude')[0].text.strip(),
            s.find_all('td', class_='max-level')[0].find('img').get('alt'),
            s.find_all('td', class_='center')[0].text.strip()
        ))
