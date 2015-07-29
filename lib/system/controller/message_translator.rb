# encoding: utf-8
# ■ 使い方
#
# 1. 任意のYAMLファイルを用意する。
#
# config/locales/*******_ja.yml
#
# ---< ここから >---
# ja:
#   actioncontroller:
#     messages:
#       # デフォルトのアクション別メッセージ -> 全ファイルを通して１つ定義できていれば良い。
#       default:
#         create:
#           success: "登録処理が完了しました。"
#         update:
#           success: "更新処理が完了しました。"
#         destroy:
#           success: "削除処理が完了しました。"
#
#       # コントローラ固有のアクション別メッセージ(params[:controller]で取れる値)
#       wdb/admin/form_field_options:
#         div_multiedit:
#           success: "一括登録処理が完了しました。"
#           success_with_count: "{{count}}件登録しました。"
#
# ---< ここまで >---
#
# 2. ソースにmix-inし、
# 3. 任意のアクションで呼出す
# ---< ここから >---
#   class Wdb::Admin::FormFieldOptions
#     include System::Controller::MessageTranslator
#              :
#     def update
#       translate_message(:success) # => 更新処理が完了しました。
#     end
#
#     def div_multiedit
#              :
#       translate_message(:success) # => 一括登録処理が完了しました。
#       translate_message(:success_with_count, :count => 10) #=> 10件登録しました。
#              :
#       translate_notice(:success) # => flash[:notice] ||= translate_message(:success) と同義
#     end
#              :
#   end
# ---< ここまで >---
#
#
module System::Controller::MessageTranslator
  protected

  def translate_message(message_key, options = {})
    options[:scope] ||= [:actioncontroller, :messages]
    controller ||= options[:controller] || params[:controller]
    action ||= options[:action] || params[:action]
    begin
      options[:raise] = true;
      t("#{controller}.#{action}.#{message_key}", options)
    rescue => e
      logger.warn "#{e}"
      begin
        t("#{:default}.#{action}.#{message_key}", options)
      rescue => edefault
        logger.warn "#{edefault}"
        raise e
      end
    end
  end

  def translate_flash(flash_key, message_key, options = {})
    flash[flash_key] ||= options[flash_key]
    return if flash[flash_key]

    begin
      flash[flash_key] ||= translate_message(message_key, options)
    rescue => e
      logger.warn "#{e}"
      "<span class=\"translation_missing\">#{e}</span>"
    end
  end

  def translate_notice(message_key, options = {})
    translate_flash(:notice, message_key, options)
  end

end
