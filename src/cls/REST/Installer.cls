Class REST.Installer Extends %Projection.AbstractProjection
{

/// インストーラーバージョン
Parameter VERSION = "1.0.0";

/// Webアプリケーション名
Parameter Name = "/csp/storage";

/// RESTクラス名
Parameter DispatchClass = "REST.StreamTransfer";

/// インストーラの実装
/// このメソッドはクラスがコンパイルされたときに呼ばれます
Projection Reference As REST.Installer;

/// WEBアプリケーションの作成
ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
        Set sc = $$$OK
        set prop("NameSpace")=$Namespace
        set prop("Description")="FileTransfer RESTインターフェース"
        set prop("IsNameSpaceDefault")= $$$NO
        set prop("DispatchClass")=..#DispatchClass
        set prop("MatchRoles")=":%All"
        set prop("AutheEnabled")= $$$AutheUnauthenticated
        new $Namespace
        set $Namespace="%SYS"
        if ('##class(Security.Applications).Exists(..#Name)) {
            set sc= ##class(Security.Applications).Create(..#Name, .prop)
        }
        Return sc
}

/// プロジェクションの削除
ClassMethod RemoveProjection(cls As %String, ByRef params, recompile As %Boolean) As %Status
{
    set sc=$$$OK
    new $NAMESPACE
    set $Namespace = "%SYS"
    if (##class(Security.Applications).Exists(..#Name)) {
        set sc = ##class(Security.Applications).Delete(..#Name)
    }
    quit sc
}

}
