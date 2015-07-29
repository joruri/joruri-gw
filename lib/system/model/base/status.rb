# encoding: utf-8
module System::Model::Base::Status
  def status_list
    [["有効","enabled"],["有効","enabled"],["表示","visible"],["非表示","hidden"],
    ["下書き","draft"],["承認待ち","recognize"],["公開待ち","recognized"],
    ["公開中","public"],["非公開","closed"],["完了","completed"]]
  end

  def status_show
    status_list.each {|a| return a[0] if a[1] == state }
    return nil
  end
end