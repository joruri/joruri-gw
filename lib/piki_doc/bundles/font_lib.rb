module PikiDoc
  module Bundles
    module FontLib
      include PluginAdapter
      def initialize()

      end
#
      def myescape(array)
        array.collect!{|x| Gw.html_escape(x.to_s).strip }
      end

      def fontf(text, face)
        text, face = myescape([text, face])
        [%Q(font-family: "#{face}";), text]
      end

      def fontc(text, color)
        text, color = myescape([text, color])
        [%Q(color: #{color};), text]
      end

      def fonts(text, size)
        text, size = myescape([text, size])
        [%Q(font-size: #{size};), text]
      end

      def font(text, color, face, size)
        text, color, face, size = myescape([text, color, face, size])
        [%Q(color: #{color}; font: #{size} "#{face}";), text]
      end
      
      def font_change(src)
        cmd = src[0,5]
        case cmd
        when 'font('
          text = src.scan(/font\((.+)\)/)
          argument = text[0][0].split(/,/) if !text.blank? && !text[0].blank?
          font(argument[0], argument[1], argument[2], argument[3])
        when 'fonts'
          text = src.scan(/fonts\((.+)\)/)
          argument = text[0][0].split(/,/) if !text.blank? && !text[0].blank?
          fonts(argument[0], argument[1])
        when 'fontc'
          text = src.scan(/fontc\((.+)\)/)
          argument = text[0][0].split(/,/) if !text.blank? && !text[0].blank?
          fontc(argument[0], argument[1])
        when 'fontf'
          text = src.scan(/fontf\((.+)\)/)
          argument = text[0][0].split(/,/) if !text.blank? && !text[0].blank?
          fontf(argument[0], argument[1])
        else
          "error font plugin"
        end
      end

      def plugin_dom_font(tag, style, text)
        %Q[<#{tag} class='plugin #{plugin_name}' style='#{style}'>#{text}</#{tag}>]
      end

      def inline_plugin(src)
        style, text = font_change(src)
        plugin_dom_font("span", style, text)
      end

      def block_plugin(src)
        style, text = font_change(src)
        plugin_dom_font("div", style, text)
      end
    end
  end
end
