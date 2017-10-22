#!/usr/bin/env ruby

# frozen_string_literal: true

require 'pry'

key_mappings = {}
`xmodmap -pke | awk '{print $2 ";" $4}'`.each_line do |line|
  mapping = line.split(';').map(&:strip)
  mapping[0] = mapping[0]
  key_mappings.merge!([mapping].to_h)
end

keypress = false

ARGF.each_line do |line|
  keypress = true if line.match?(/^EVENT type 2/)
  next unless keypress

  matches = line.match(/detail: (\d+)/)
  if matches
    puts key_mappings[matches[1]]
    keypress = false
  end
end
