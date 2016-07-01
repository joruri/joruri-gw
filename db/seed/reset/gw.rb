# encoding: utf-8
ActiveRecord::Base.connection.tables.each{|t| truncate_table t }