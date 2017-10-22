#!/usr/bin/env ruby

# frozen_string_literal: true

require 'pry'

key_mappings = {}
`xmodmap -pke | awk '{print $2 ";" $4}'`.each_line do |line|
  mapping = line.split(';').map(&:strip)
  mapping[0] = mapping[0]
  key_mappings.merge!([mapping].to_h)
end

modifier_mappings = {}
n = 0
`xmodmap -pm | grep '(0x'`.each_line do |line|
  modifiers = line.match('^(\w+)\s+(\w*)')
  modifier_mappings[n] = modifiers[1]
  n += 1
end

def get_modifiers_from_hex(hex, mappings)
  flags = hex.to_i(16).to_s(2).chars.reverse.map(&:to_i)

  mappings.map do |index, modifier|
    next unless flags[index] == 1

    modifier
  end.compact
end

keypress = false
key_pressed = nil

ARGF.each_line do |line|
  keypress = true if line.match?(/^EVENT type 2/)
  next unless keypress

  details = line.match(/detail: (\d+)/)
  key_pressed = key_mappings[details[1]] if details

  modifiers = line.match(/modifiers:.*effective: (\w+)/)
  next unless modifiers

  modifiers = get_modifiers_from_hex(modifiers[1], modifier_mappings)

  keys_pressed = modifiers.push(key_pressed)

  puts keys_pressed.join(' + ')

  keypress = false
  key_pressed = nil
end

