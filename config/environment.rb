# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

def nz(value, valueifnull='')
  value.blank? ? valueifnull : value
end
def nf(value, valueifnull='')
  # no-falsy, falsy: false, nil, '', 0, '0'
  value.blank? || value.to_s == '0' ? valueifnull : value
end
