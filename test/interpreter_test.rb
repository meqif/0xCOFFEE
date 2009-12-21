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

class Interpreter < Test::Unit::TestCase

    attr_reader :parser

    def setup
        @parser = CoffeeParser.new
    end

    def test_identity
        root = parser.parse('1')
        assert_equal(1, root.evaluate)
    end

    def test_addition
        root = parser.parse('1+1')
        assert_equal(2, root.evaluate)
    end

    def test_multi_addition
        root = parser.parse('1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1')
        assert_equal(18, root.evaluate)
    end

    def test_addition_fail
        assert_nil parser.parse('1+1+1++1')
    end

end