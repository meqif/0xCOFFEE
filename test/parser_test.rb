#!/usr/bin/env ruby
#
# (C)opyright 2009 Ricardo Martins <ricardo at scarybox dot net>
# Licensed under the MIT/X11 License. See LICENSE file for license details.

$:.unshift File.dirname(__FILE__) + "/../lib"
require 'coffee'
require 'test/unit'

begin
  require 'rubygems'
  require 'redgreen'
rescue 'LoadError'
  puts "WARNING: redgreen not found."
end

class Parser < Test::Unit::TestCase

    attr_reader :parser

    def setup
        @parser = CoffeeParser.new
    end

    def test_addition
        assert parser.parse('1+1')
    end

    def test_multi_addition
        assert parser.parse('1+1+1+1+1+1+1+1++1+1+1+1+1+1+1+1+1+1')
    end

    def test_addition_fail
        assert_nil parser.parse('1+1+1++1')
    end

end
