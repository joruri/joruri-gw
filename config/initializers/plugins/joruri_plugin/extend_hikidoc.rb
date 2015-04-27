class HikiDoc
  private
  def compile_blocks(src)
    f = LineInput.new(StringIO.new(src))
    while line = f.peek
      case line
      when COMMENT_RE
        f.gets
      when HEADER_RE
        compile_header f.gets
      when HRULE_RE
        f.gets
        compile_hrule
      when LIST_RE
        compile_list f
      when DLIST_RE
        compile_dlist f
      when TABLE_RE
        compile_table f
      when BLOCKQUOTE_RE
        compile_blockquote f
      when INDENTED_PRE_RE
        compile_indented_pre f
      when BLOCK_PRE_OPEN_RE
        compile_block_pre f
      when UNESCAPE_HTML_OPEN_RE
        unescape_block_pre f
      else
        if /^$/ =~ line
          f.gets
          next
        end
        compile_paragraph f
      end
    end
  end

  def split_columns(str)
    cols = str.split(/\|\|/)
    cols.pop if cols.last.to_s.chomp.empty?
    cols
  end

  UNESCAPE_HTML_OPEN_RE = /\A<UN>>\s*(\w+)?/
  UNESCAPE_HTML_CLOSE_RE = /\A<<UN>/

  def unescape_block_pre(f)
    m = UNESCAPE_HTML_OPEN_RE.match(f.gets) or raise UnexpectedError, "must not happen"
    str = restore_plugin_block(f.break(UNESCAPE_HTML_CLOSE_RE).join.chomp)
    f.gets
    @output.unescape_html_created(str, m[1])
  end

  class HTMLOutput
    def unescape_html_created(str, info)
      syntax = info ? info.downcase : nil
      if syntax
        begin
          @f.puts str
          return
        rescue NameError, RuntimeError
          @f.puts str
          return
        end
      end
      @f.puts str
    end
  end
end

# register plugins
require 'piki_doc'
require 'piki_doc/bundles/plugin_adapter'
require 'piki_doc/bundles/asin'
require 'piki_doc/bundles/gist'
require 'piki_doc/bundles/font'
require 'piki_doc/bundles/fontc'
require 'piki_doc/bundles/fontf'
require 'piki_doc/bundles/fonts'

PikiDoc.register(PikiDoc::Bundles::Gist.new, PikiDoc::Bundles::Asin.new,
  PikiDoc::Bundles::Font.new, PikiDoc::Bundles::Fontc.new, PikiDoc::Bundles::Fontf.new, PikiDoc::Bundles::Fonts.new)
