#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ↑Python3 なら本来不要+Emacsの形式を使っている
# vim:fileencoding=utf-8 fileformat=unix

import vim
import os
from glob import glob
import re


def remakehelptags(vimrc):
    vimrc = vimrc.decode()
    docdir = vimrc + '/doc'
    if not os.path.isdir(docdir):
        os.mkdir(docdir)
        os.chmod(docdir, 0o700)
    max_tags_time = 0  # tags, tags-?? 最終更新日時取得
    for tags in glob(vimrc + '/doc/tags*'):
        if re.search(r'^.+/tags(-..)?$', tags) is None:
            continue
        tags_time = os.path.getmtime(tags)
        if tags_time > max_tags_time:
            max_tags_time = tags_time
    # for d in glob(vimrc + '/pack/*/*/*/doc/'):
    for f in glob(vimrc + r'/pack/github/*/*/doc/*'):
        if os.path.basename(os.path.dirname(os.path.dirname(f))) == 'vimdoc-ja':
            continue
        if max_tags_time < os.path.getmtime(f):
            vim.command('call s:mkHelpTags()')
            return
