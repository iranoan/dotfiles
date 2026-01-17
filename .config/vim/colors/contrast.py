#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ↑Python3 なら本来不要+Emacsの形式を使っている
# vim:fileencoding=utf-8 fileformat=unix
# 比較対象色の色差と簡易的な APCA Lc を出力

import math

# 比較対象
colors = {
    '#1d221f': 'Inkstone',
    '#e04a41': 'Vermilion',
    '#6da34d': 'KOSHIABURA',
    '#a67700': 'Ochre',
    '#268bd2': 'SEIRAN',
    '#d14d8a': 'Lotus',
    '#00947a': 'Bamboo',
    '#8c8a7d': 'Gray',
    '#29302B': 'AOZUMI',
    '#ca5b00': 'Persimmon',
    '#6d736d': 'Ash',
    '#cf5858': 'Peony',
    '#6595b5': 'Hydrangea',
    '#966fd0': 'Violet',
    '#e6e1d1': 'Fog',
    '#f7f2e1': 'WASHI',
}


def apca_lc(text_rgb, bg_rgb) -> float:  # 簡易版
    def relative_luminance(rgb):
        def srgb_to_linear(c: float) -> float:
            if c <= 0.04045:
                return c / 12.92
            return ((c + 0.055) / 1.055) ** 2.4

        r, g, b = [int(rgb.lstrip('#')[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]
        r_lin = srgb_to_linear(r)
        g_lin = srgb_to_linear(g)
        b_lin = srgb_to_linear(b)
        return 0.2126 * r_lin + 0.7152 * g_lin + 0.0722 * b_lin

    def low_contrast_rolloff(Lc: float, is_light_bg: bool) -> float:  # APCA低コントラスト補正
        absLc = abs(Lc)
        if absLc < 45:  # 低コントラストは軽く圧縮
            if is_light_bg:  # 白背景側は少し持ち上げる
                Lc *= 1.005
            else:  # 黒背景側はほぼそのまま
                Lc *= 0.995
        elif absLc < 60:  # 中域はごく緩やか
            if is_light_bg:
                Lc *= 1.003
        return Lc

    scale = 1.14 * 98.6
    Ytxt = max(relative_luminance(text_rgb), 0.022)
    Ybg = max(relative_luminance(bg_rgb), 0.022)
    if Ybg > Ytxt:  # 白背景・黒文字
        Ybg_p = Ybg ** 0.56
        Ytxt_p = Ytxt ** 0.57
        Lc = (Ybg_p - Ytxt_p) * scale
        Lc = low_contrast_rolloff(Lc, is_light_bg=True)
    else:  # 黒背景・白文字
        Ybg_p = Ybg ** 0.65
        Ytxt_p = Ytxt ** 0.62
        Lc = (Ybg_p - Ytxt_p) * scale
        Lc = low_contrast_rolloff(Lc, is_light_bg=False)
    return Lc


def get_delta_e_2000(hex1, hex2):
    def rgb_to_lab(h):
        def f(t):
            return math.pow(t, 1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
        r, g, b = [int(h.lstrip('#')[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]
        r, g, b = [((c + 0.055) / 1.055) ** 2.4 if c > 0.04045 else c / 12.92 for c in [r, g, b]]
        x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047
        y = (r * 0.2126 + g * 0.7152 + b * 0.0722)
        z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883
        return 116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z))

    L1, a1, b1 = rgb_to_lab(hex1)
    L2, a2, b2 = rgb_to_lab(hex2)  # 簡易版色差（ユークリッド距離ではなく、知覚的な色差近似）
    return math.sqrt(math.pow(L2 - L1, 2) + math.pow(a2 - a1, 2) + math.pow(b2 - b1, 2))


for i in colors.values():
    print(i, end="\t")
print("")
for i, c0 in enumerate(colors.keys()):
    c0 = c0.lstrip('#')
    for j, c1 in enumerate(colors):
        if i < j:
            print("\t", end="")
            continue
        c1 = c1.lstrip('#')
        if c0 == c1:
            print('―', end="\t")
        else:
            print(f"{get_delta_e_2000(c0, c1):.3g}", end="\t")
    print('')
print("")
Inkstone, *_, WASHI = colors.keys()
for v in colors.keys():
    print(v,
          apca_lc(v, WASHI) if v != WASHI else '―',
          apca_lc(v, Inkstone) if v != Inkstone else '―',
          sep="\t")
