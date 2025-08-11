# output2qf

出力を  QuickFix (`:help quickfix`) に取り込む

## :Shell2Qf

シェルの出力結果をファイルのリストとして取り込む

### 使用法

``` vim
:Shell2Qf shell-command arg | shell-command arg ...
```

## :Vim2Qf

`:message` の出力結果の内、エラーの出力を取り込む

* `:message` にエラーがなく、バッファのファイルタイプが Vim なら `:source %` して再度取り込みを試みる
* Python interface には対応してが他は未対応
* lambda 関数未対応 (←おそらくエラーに成り、それだけ無視されるのではなく他も取り込まれない)

### 使用法

``` vim
:Vim2Qf
```
