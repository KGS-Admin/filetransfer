/// ストリームデータのダウンロード、アップロード用RESTインターフェース
Class REST.StreamTransfer Extends %CSP.REST
{

/// ファイル格納ディレクトリ
Parameter Storage = "c:\temp";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/" Method="GET" Call="ListFile" Cors="true"/>
<Route Url="/:filename" Method="POST" Call="Upload" Cors="true"/>
<Route Url="/:filename" Method="GET" Call="Download" Cors="true"/>
</Routes>
}

ClassMethod Upload(filename As %String)
{
	set tSC=$$$OK
	try {
		// MIMEタイプチェック
		if %request.ContentType'["multipart" {
			set %response.Status="406 Not Acceptable mimetype"
			quit
		}
		//ストリームクラスのオープン
		set stream=##class(%FileBinaryStream).%New()
		set stream.Filename=##class(%File).NormalizeDirectory(..#Storage)_filename
		set filetype=$select(filename[".":$zcvt($piece(filename,".",*),"L"),1:"") // 拡張子(小文字)を取得
		if filetype'="" {
			set ^FileType(filetype)=%request.MimeData("file",1).ContentType /// コンテンツタイプと拡張子の対照表を作成
		}
		do stream.CopyFrom(%request.MimeData("file",1))
		do stream.SaveStream()

		set %response.Status="200 Upload OK"
		
	} catch {
		set %response.Status="500 Upload error"
	}

	quit $$$OK
}

ClassMethod Download(filename As %String)
{
	#dim %response as %CSP.Response
	#dim %request as %CSP.Request
	set tSC=$$$OK
	try {
		// ファイル存在チェック
		set file=##class(%File).NormalizeDirectory(..#Storage)_filename
		if '##class(%File).Exists(file) {
			set %response.Status="404 File not found"
			quit
		}

		set %response.Expires=120
		// ContentTypeの設定
		set filetype=$select(filename[".":$zcvt($piece(filename,".",*),"L"),1:"") // 拡張子(小文字)を取得
		if filetype'="" {
			set %response.ContentType=$get(^FileType(filetype))  /// コンテンツタイプを取得
		}
		set:%response.ContentType="" %response.ContentType="application/binary"

		// Accept-Rangesの設定
		do %response.SetHeader("Accept-Ranges","bytes")

		//ストリームクラスのオープン
		set stream=##class(%FileBinaryStream).%New()
		set stream.Filename=file

		// 取得範囲(Rangeヘッダ)を取得（単一のみ）
		set range=%request.GetCgiEnv("HTTP_RANGE")
		if range'="" {
			set rangeType=$piece(range,"="),range=$piece(range,"=",2)

			// 複数範囲取得は無視する
			set range=$zstrip($piece(range,","),"<>W")
		} else {
			set range="0-"
		}
		set ^header($I(^header))=$job_"]range:"_range
		if range="0-" {
			// 範囲が指定されていない場合

			set %response.Status="206 Partial Content"
			do %response.SetHeader("Content-Range","bytes 0-"_(stream.Size-1)_"/"_stream.Size)

			// 全範囲の出力
			set tSC=stream.OutputToDevice()

		} else {
			// 範囲が指定されている場合
			set start=$zstrip($piece(range,"-"),"<>W"),end=$zstrip($piece(range,"-",2),"<>W")
			set:end="" end=stream.Size-1
			set len=end-start+1
			
			// 範囲ヘッダの設定
			do %response.SetHeader("Content-Range","bytes "_start_"-"_end_"/"_stream.Size)
			set %response.Status="206 Partial Content"

			// 指定範囲を出力
			set tSC=stream.OutputToDeviceAt(start+1,.len)

		}


	} catch {
		set %response.Status="500 Download error"
	}

	quit $$$OK
}

/// ファイル一覧の出力
ClassMethod ListFile()
{
	#dim %response as %CSP.Response

	try {
		set filecnt=0 // 出力ファイル件数
		
		//配列出力
		write "["
		
		set %response.ContentType = "application/json"

		// Storageパラメータで指定されたディレクトリのファイル一覧を取得
		set rs=##class(%ResultSet).%New("%File:FileSet")
		do rs.Execute(..#Storage,"*.*","",1)
		while rs.Next() {
			// ファイル名、拡張子の取得
			set filename=##class(%File).GetFilename(rs.Data("Name"))
			set filetype=$piece(filename,".",*)

			//拡張子の無いファイルはスキップ
			continue:filetype=""
			continue:'$data(^FileType(filetype),contenttype)

			// エントリの出力
			write:filecnt>0 ","
			write "{""filename"":""",filename,""",""contenttype"":""",contenttype,"""}"

			// 出力ファイル件数をインクリメント
			set filecnt=filecnt+1
		}
		write "]",!

		set %response.Status="200 ListFile OK"	
	} catch {
		set %response.Status="500 ListFile error"	
	}

	quit $$$OK
}

}
