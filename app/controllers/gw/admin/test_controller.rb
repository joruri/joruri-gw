class Gw::Admin::TestController < ApplicationController
  include System::Controller::Scaffold

  def index

  end

private

  def redirect_page_create(url, field_account, field_pass)

    redirect_page = <<-EOL
<html>
<head>
<meta http-equiv="Content-Language" content="ja">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Expires" content="-1">
<title>redirect</title>
<!--JavaScript-->
<script language="JavaScript">
<!--
function PostToAuth(){
  document.loginform.submit();
}
-->
</script>
</head>
<body onLoad="PostToAuth();">
<form name="loginform" action="#{url}" method="post" >
<input type="hidden" name="#{field_account}" value="#{Core.user.code}">
<input type="hidden" name="#{field_pass}" value="#{Core.user.password}">
</form>
</body>
</html>
EOL

    return redirect_page
  end

end
