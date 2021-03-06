#!/usr/bin/ruby

require 'rubygems'
require 'simpleidn'
require 'russian'
require 'fileutils'

interpreter = ARGV[0].dup

common_template = File.read("template#{interpreter}.common").force_encoding("utf-8")
available_template = File.read("template#{interpreter}.available").force_encoding("utf-8")

domainname_original = ARGV[1].dup.force_encoding("utf-8")

domainname = SimpleIDN.to_ascii domainname_original

if ARGV[2]
  dimainname_folder = ARGV[2].dup
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

FileUtils.mkdir_p "/var/www/#{interpreter}/#{domainname_folder}/log/nginx"
FileUtils.mkdir_p "/var/www/#{interpreter}/#{domainname_folder}/log/rails/puma" if interpreter=='rails'
FileUtils.mkdir_p "/var/www/#{interpreter}/#{domainname_folder}/htdocs"

common_template.gsub! /domainnamefolder/, domainname_folder
#puts common_template
File.write "/etc/nginx/common.conf/#{interpreter}/#{domainname_folder}.conf", common_template
#puts "==================="

available_template.gsub! /domainnameadress/, domainname
available_template.gsub! /domainnamefolder/, domainname_folder
#puts available_template
available_site = "/etc/nginx/sites-available/#{interpreter}/#{domainname_folder}"
File.write available_site, available_template

`ln -s #{available_site} /etc/nginx/sites-enabled/#{interpreter}/#{domainname_folder}`
