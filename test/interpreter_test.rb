#!/usr/bin/env ruby
#
# (C)opyright 2009 Ricardo Martins <ricardo at scarybox dot net>
# Licensed under the MIT/X11 License. See LICENSE file for license details.

$:.unshift File.dirname(__FILE__) + "/../lib"

require 'test/unit'
require 'rubygems'
require 'treetop'
require 'coffee/nodes'

if File.file?(File.dirname(__FILE__) + "/../lib/coffee/grammar.rb")
  # Take compiled one
  require "coffee/grammar"
else
  Treetop.load File.dirname(__FILE__) + "/../lib/coffee/grammar.tt"
end

begin
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

    root = parser.parse('1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1')
    assert_equal(18, root.evaluate)

    root = parser.parse('0 + 0 + 1 + 2 + 3 + 5 + 8 + 13 + 21')
    assert_equal(53, root.evaluate)

    root = parser.parse('2 + (-3) * 2')
    assert_equal(-4, root.evaluate)
  end

  def test_addition_fail
    assert_nil parser.parse('1+1+1++1')
  end

  def test_multiplication
    root = parser.parse('2*2')
    assert_equal(4, root.evaluate)

    rootA = parser.parse('5*4*3*2*1')
    rootB = parser.parse('1*2*3*4*5')
    assert_equal(rootA.evaluate, rootB.evaluate)
  end

  def test_priority
    root = parser.parse('1+2*2')
    assert_equal(5, root.evaluate)

    root = parser.parse('(1+2)*2')
    assert_equal(6, root.evaluate)
  end

end
