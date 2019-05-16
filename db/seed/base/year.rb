# encoding: utf-8
## year fiscal
puts "Import year settings"

def create_fyears(fyear)
  year = Gw::YearFiscalJp.new
  year.fyear = fyear
  year.save
end

def create_year_marks(name, mark, start_at)
  Gw::YearMarkJp.create({
    name: name, mark: mark, start_at: start_at
  })
end

create_year_marks('明治', 'M', '1868-09-08 00:00:00')
create_year_marks('大正', 'T', '1912-07-30 00:00:00')
create_year_marks('昭和', 'S', '1926-12-25 00:00:00')
create_year_marks('平成', 'H', '1989-01-08 00:00:00')
create_year_marks('令和', 'R', '2019-05-01 00:00:00')


this_year = Date.today.month >= 4 ? Date.today.year.to_i : Date.today.prev_year.year.to_i

(1869..this_year).each do |y|
  create_fyears(y)
end

