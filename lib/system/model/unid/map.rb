# encoding: utf-8
module System::Model::Unid::Map
  def self.included(mod)
    mod.has_many :maps, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'System::Map',
      :dependent => :destroy

    mod.after_save :save_maps
  end

  attr_accessor :_maps

  def find_map_by_name(name)
    return nil if maps.size == 0
    maps.each do |map|
      return map if map.name == name
    end
    return nil
  end

  def save_maps
    return true  unless _maps
    return false unless unid
    return false if @save_maps_callback_flag

    @save_maps_callback_flag = true

    _maps.each do |k, values|
      name  = k.to_s

      if values == ''
        maps.each do |map|
          map.destroy if map.name == name
        end
      else
        items = []
        maps.each do |map|
          if map.name == name
            items << map
          end
        end

        if items.size > 1
          items.each {|map| map.destroy}
          items = []
        end

        if items.size == 0
          map = System::Map.new({:unid => unid, :name => name})
        else
          map = items[0]
        end

        map.title       = values[:title]
        map.map_lat     = values[:map_lat]
        map.map_lng     = values[:map_lng]
        map.map_zoom    = values[:map_zoom]
        map.point1_name = values[:point1_name]
        map.point1_lat  = values[:point1_lat]
        map.point1_lng  = values[:point1_lng]
        map.point2_name = values[:point2_name]
        map.point2_lat  = values[:point2_lat]
        map.point2_lng  = values[:point2_lng]
        map.point3_name = values[:point3_name]
        map.point3_lat  = values[:point3_lat]
        map.point3_lng  = values[:point3_lng]
        map.point4_name = values[:point4_name]
        map.point4_lat  = values[:point4_lat]
        map.point4_lng  = values[:point4_lng]
        map.point5_name = values[:point5_name]
        map.point5_lat  = values[:point5_lat]
        map.point5_lng  = values[:point5_lng]

        map.save
      end
    end

    maps(true)
    return true
  end
end