## ファイルのアップロード、ダウンロードサンプル
このWebブラウザからIRISシステムにバイナリやテキスト形式のファイルをアップロードしたり、アップロードされているファイルをダウンロードするサンプルプログラムです。

アップロードにはmultipart/form-dataを使用し、ダウンロードはファイル形式に応じたmime typeを使用しています。

## インストール方法
1. REST.StreamTransferクラス、REST.Installerクラスを適当なネームスペース(例:USER)にロードします。
2. REST.Installerクラスをコンパイルを行いますと、/csp/storageというWebアプリケーションが作成されます
3. ロードしたネームスペースのデフォルトWebアプリケーションのディレクトリ(/csp/user)にfiletrans.htmlをコピーします。
4. ファイルを格納するディレクトリを作成しREST.StreamTransferクラスのStorageパラメータにそのディレクトリを指定します。

## 操作方法
1. Chromeなどのブラウザからfiletrans.htmlにアクセスします。
   例:　http://localhost:52773/csp/user/filetrans.html

2. 「ファイルを選択」ボタンをクリックし、アップロードしたいファイルを選択します。
3. 「アップロード」ボタンをクリックしますと、ファイルがIRISサーバで受信され、Storageパラメータで指定されたディレクトリに保存され、「アップロード」ボタンの下にそのファイル名が表示されます。
4. アップロードされたファイルをクリックしますと、右側にファイルの内容が表示されます。


