require 'mharris_ext'
require 'io/wait'
require 'json'
require 'cgi'
require 'open-uri'

%w(ext manager pipes client).each do |f|
  load File.dirname(__FILE__) + "/rest_debug/#{f}.rb"
end
