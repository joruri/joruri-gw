# encoding: utf-8
class Sys::Lib::Net::Imap::MailPaginate < Array
  attr_reader :total_pages, :current_page, :previous_page, :next_page
  
  def make_pagination(attributes = {})
    page  = attributes[:page]
    limit = attributes[:per_page]
    total = attributes[:total]
    
    @total_pages   = (total / limit) + (total % limit == 0 ? 0 : 1)
    @current_page  = page
    @previous_page = (page <= 1) ? nil : page - 1
    @next_page     = (page >= @total_pages) ? nil : page + 1
  end
end