#!/bin/sh
# $1 第一引数となるウィンドウ・タイトルを検索して、そのウィンドウをアクティブにする
# wmctrl が対応しているアプリ限定

while [ -z "$winid" ] ; do
	winid=$( wmctrl -l | grep -E "$1" | sed -E 's/ .+$//g' )
done
wmctrl -ia "$winid" #ウィンドウをアクティブに
