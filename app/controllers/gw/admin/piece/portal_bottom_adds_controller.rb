class Gw::Admin::Piece::PortalBottomAddsController < ApplicationController
  include System::Controller::Scaffold
  include Gw::Controller::PortalAd
  layout false

  def index
    load_state_and_num_and_pattern

    disp_limit = []
    disp_limit = return_limit(2, @pattern)
    join = "LEFT JOIN gw_portal_add_patterns ON gw_portal_add_patterns.add_id = gw_portal_adds.id"
    use_join = true
    if @open_state
      today = Time.now.strftime('%Y-%m-%d')
      item    = Gw::PortalAdd.new
      base_cond = "published = 'opened' and publish_start_at <= '#{today}' and publish_end_at >= '#{today}'"
      case @pattern
      when 1
        use_join = false
        cond    = "#{base_cond} and place = 2"
      when 2
        cond    = "#{base_cond} and gw_portal_add_patterns.state ='enabled'  and gw_portal_add_patterns.pattern = 2 and gw_portal_add_patterns.place = 2"
      when 3
        cond    = "#{base_cond} and gw_portal_add_patterns.state ='enabled'  and gw_portal_add_patterns.pattern = 3 and gw_portal_add_patterns.place = 2"
      when 5
        cond    = "#{base_cond} and gw_portal_add_patterns.state ='enabled'  and gw_portal_add_patterns.pattern = 5 and gw_portal_add_patterns.place = 2"
      when 4
        cond    = "#{base_cond} and gw_portal_add_patterns.state ='enabled'  and gw_portal_add_patterns.pattern = 4"
      else
        use_join = false
        cond    = "#{base_cond}  and place = 2"
      end
      if use_join==true
        @add_limit = 4
        if disp_limit
          ad_limit = disp_limit[0][0]
          offset = disp_limit[0][1]
        end
        order   = "gw_portal_add_patterns.group_id, gw_portal_add_patterns.sort_no ASC"
        @items = Gw::PortalAdd.joins(join).select("gw_portal_adds.* , gw_portal_add_patterns.group_id")
          .where(cond).order(order).limit(ad_limit).offset(offset)
        if disp_limit[1] && @pattern == 4
          disp_ad = []
          disp_limit[1].each do |idx|
            disp_ad << @items[idx] if @items[idx]
          end
          @items = disp_ad
        end if @items && disp_limit
      else
        @items = Gw::PortalAdd.where(cond).order(:sort_no).limit(@add_limit)
      end
      disp_no_set(@pattern)
    else
      @items = nil
    end
  end

  def load_state_and_num_and_pattern
    pattern_item = Gw::Property::PortalAddDispPattern.first_or_new
    option_item = Gw::Property::PortalAddDispOption.first_or_new
    num_item = Gw::Property::PortalAddDispLimit.first_or_new

    @pattern = pattern_item.options_value
    @open_state = option_item.options_value[1][0] == "opened"
    @add_limit = num_item.options_value[1][0].to_i
  end
end
