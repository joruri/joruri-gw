class Gw::Admin::Piece::PortalLeftAddsController < ApplicationController
  include System::Controller::Scaffold
  include Gw::Controller::PortalAd
  layout false

  def index
    call_add = (params[:piece_param].presence || 1).to_i
    load_state_and_num_and_pattern(call_add)

    if @open_state
      today = Time.now.strftime('%Y-%m-%d')
      item    = Gw::PortalAdd.new
      base_cond = "published = 'opened' and publish_start_at <= '#{today}' and publish_end_at >= '#{today}'"
      join = "LEFT JOIN gw_portal_add_patterns ON gw_portal_add_patterns.add_id = gw_portal_adds.id"
      order = "gw_portal_add_patterns.group_id, gw_portal_add_patterns.sort_no ASC"
      if @pattern==5 && call_add != 1
        @items = get_large_ad(item, base_cond, join, order)
      else
        disp_limit = []
        disp_limit = return_limit(call_add,@pattern)
        use_join = true
        if call_add==1
          use_join = false
          cond    = "#{base_cond} and place = #{call_add}"
        else
          case @pattern
          when 1
            use_join = false
            cond = "#{base_cond} and place = #{call_add}"
          when 2
            use_join = false
            cond = "#{base_cond} and place = #{call_add}"
          when 3
            cond = "#{base_cond} and gw_portal_add_patterns.state ='enabled' and gw_portal_add_patterns.pattern = 3 and gw_portal_add_patterns.place = #{call_add}"
          when 4
            cond = "#{base_cond} and gw_portal_add_patterns.state ='enabled' and gw_portal_add_patterns.pattern = 4"
          else
            use_join = false
            cond = "#{base_cond}  and place = #{call_add}"
          end
        end
        if use_join==true
          @add_limit = 3
          if disp_limit
            ad_limit = disp_limit[0][0]
            offset = disp_limit[0][1]
          end
          @items = Gw::PortalAdd.joins(join).select("gw_portal_adds.* , gw_portal_add_patterns.group_id")
            .where(cond).order(order).limit(ad_limit).offset(offset)
           if  disp_limit[1] && @pattern == 4
            disp_ad = []
            disp_limit[1].each do |idx|
              disp_ad << @items[idx] if @items[idx]
            end
          @items = disp_ad
          end if @items && disp_limit
        else
          @items = Gw::PortalAdd.where(cond).order(:sort_no).limit(@add_limit)
        end
      end
    else
      @items = nil
    end
  end

  def load_state_and_num_and_pattern(i)
    pattern_item = Gw::Property::PortalAddDispPattern.first_or_new
    option_item = Gw::Property::PortalAddDispOption.first_or_new
    num_item = Gw::Property::PortalAddDispLimit.first_or_new

    @pattern = pattern_item.options_value
    @open_state = option_item.options_value[i-1][0] == "opened"
    @add_limit = num_item.options_value[i-1][0].to_i
  end
end
