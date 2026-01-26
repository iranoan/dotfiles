#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ↑Python3 なら本来不要+Emacsの形式を使っている
# vim:fileencoding=utf-8 fileformat=unix
# 比較対象色の色差と簡易的な APCA Lc を出力

import math

colors = {
    '#1d221f': 'Inkstone',
    '#e44036': 'Vermilion',
    '#309c00': 'KOSHIABURA',
    '#c08000': 'Ochre',
    '#2280e4': 'SEIRAN',
    '#e14080': 'Lotus',
    '#148fa4': 'Kingfisher',
    '#e6e1d1': 'Fog',
    '#29302b': 'AOZUMI',
    '#ca5e5e': 'Peony',
    '#00886a': 'Bamboo',
    '#ca5b00': 'Persimmon',
    '#6d736d': 'Ash',
    '#966fe1': 'Violet',
    '#8c8a7d': 'Gray',
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


def get_delta_e_2000(hex1, hex2):  # 厳密な CIEDE2000 (ISO/CIE 11664-6:2014) 実装
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
    L2, a2, b2 = rgb_to_lab(hex2)

    # --- CIEDE2000 Constants & Calculations ---
    C1 = math.sqrt(a1**2 + b1**2)
    C2 = math.sqrt(a2**2 + b2**2)
    mean_C = (C1 + C2) / 2

    G = 0.5 * (1 - math.sqrt(mean_C**7 / (mean_C**7 + 25**7)))
    a1p = (1 + G) * a1
    a2p = (1 + G) * a2

    Cp1 = math.sqrt(a1p**2 + b1**2)
    Cp2 = math.sqrt(a2p**2 + b2**2)

    hp1 = math.degrees(math.atan2(b1, a1p)) % 360
    hp2 = math.degrees(math.atan2(b2, a2p)) % 360

    dL = L2 - L1
    dCp = Cp2 - Cp1

    if Cp1 * Cp2 == 0:
        dhp = 0
    else:
        dhp = hp2 - hp1
        if dhp > 180:
            dhp -= 360
        elif dhp < -180:
            dhp += 360

    dHp = 2 * math.sqrt(Cp1 * Cp2) * math.sin(math.radians(dhp / 2))

    mean_L = (L1 + L2) / 2
    mean_Cp = (Cp1 + Cp2) / 2

    if Cp1 * Cp2 == 0:
        mean_hp = hp1 + hp2
    else:
        mean_hp = (hp1 + hp2) / 2
        if abs(hp1 - hp2) > 180:
            if hp1 + hp2 < 360:
                mean_hp += 180
            else:
                mean_hp -= 180

    T = 1 - 0.17 * math.cos(math.radians(mean_hp - 30)) + \
        0.24 * math.cos(math.radians(2 * mean_hp)) + \
        0.32 * math.cos(math.radians(3 * mean_hp + 6)) - \
        0.20 * math.cos(math.radians(4 * mean_hp - 63))

    SL = 1 + (0.015 * (mean_L - 50)**2) / math.sqrt(20 + (mean_L - 50)**2)
    SC = 1 + 0.045 * mean_Cp
    SH = 1 + 0.015 * mean_Cp * T

    RT = -2 * math.sqrt(mean_Cp**7 / (mean_Cp**7 + 25**7)) * \
        math.sin(math.radians(60 * math.exp(-((mean_hp - 275) / 25)**2)))

    return math.sqrt((dL / SL)**2 + (dCp / SC)**2 + (dHp / SH)**2 + RT * (dCp / SC) * (dHp / SH))


# 出力処理
print("\t", "light", "dark", sep="\t", end="\t")
for name in colors.values():
    print(name, end="\t")
print("")
Inkstone, *_, WASHI = colors.keys()
for i, (c0, v) in enumerate(colors.items()):
    print(v, c0,
          f"{apca_lc(c0, WASHI):#.3g}" if v != 'WASHI' else '―',
          f"{apca_lc(c0, Inkstone):#.3g}" if v != 'Inkstone' else '―',
          sep="\t", end="\t")
    for j, (c1, _) in enumerate(colors.items()):
        if i < j:
            print("\t", end="")
            continue
        if c0 == c1:
            print('―', end="\t")
        else:
            print(f"{get_delta_e_2000(c0, c1):#.3g}", end="\t")
    print('')
