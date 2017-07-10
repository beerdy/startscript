#!/usr/bin/ruby

require 'rubygems'
require 'simpleidn'
require 'russian'
require 'fileutils'

common_template = File.read("templatephp.common").force_encoding("utf-8")
available_template = File.read("templatephp.available").force_encoding("utf-8")

domainname_original = ARGV[0].dup.force_encoding("utf-8")

domainname = SimpleIDN.to_ascii domainname_original

if ARGV[1]
  dimainname_folder = ARGV[1].dup
  print "Are you sure you want to use '#{dimainname_folder}'? (Y/N): "
  case STDIN.gets.chomp
  when 'yes', 'y','Yes','Y','YES'
  when 'no','n','No','N','NO'
    puts 'Terminate.'
    exit
  else
    puts 'Your answer incorrect. Restart script and try again'
    exit
  end
elsif domainname_original == domainname
  domainname_folder = domainname_original
else
  puts "Domain name is IDN! - #{domainname}"
  domainname_folder = Russian.translit(domainname_original).downcase
end 

FileUtils.mkdir_p "/var/www/php/#{domainname_folder}/log/nginx"
FileUtils.mkdir_p "/var/www/php/#{domainname_folder}/htdocs"

common_template.gsub! /domainnamefolder/, domainname_folder
#puts common_template
File.write "/etc/nginx/common.conf/php/#{domainname_folder}.conf", common_template
#puts "==================="

available_template.gsub! /domainnameadress/, domainname
available_template.gsub! /domainnamefolder/, domainname_folder
#puts available_template
available_site = "/etc/nginx/sites-available/php/#{domainname_folder}"
File.write available_site, available_template

`ln -s #{available_site} /etc/nginx/sites-enabled/php/#{domainname_folder}`
