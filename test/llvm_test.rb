#!/usr/bin/env ruby
#
# (C)opyright 2009 Ricardo Martins <ricardo at scarybox dot net>
# Licensed under the MIT/X11 License. See LICENSE file for license details.

$:.unshift File.dirname(__FILE__) + "/../lib"

require 'test/unit'
require 'rubygems'
require 'treetop'
require 'coffee'

begin
  require 'redgreen'
rescue 'LoadError'
  puts "WARNING: redgreen not found."
end

class Compiler < Test::Unit::TestCase

  attr_reader :parser, :generator

  def setup
    @parser = CoffeeParser.new
  end

  def compile_test(source)
    @generator = Coffee::Generator.new
    if root = parser.parse(source)
      root.codegen_test(generator)
      generator.optimize
      generator.run
    else
      raise Coffee::ParserError, parser.failure_reason
    end
  end

  def compile(source)
    @generator = Coffee::Generator.new
    if root = parser.parse(source)
      root.codegen(generator)
      generator.optimize
      generator.run
    else
      raise Coffee::ParserError, parser.failure_reason
    end
  end

  private :compile, :compile_test

  def test_identity
    result = compile_test('1')
    assert_equal(1, result)
  end

  def test_addition
    result = compile_test('1+1')
    assert_equal(2, result)

    result = compile_test('1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1')
    assert_equal(18, result)

    result = compile_test('0 + 0 + 1 + 2 + 3 + 5 + 8 + 13 + 21')
    assert_equal(53, result)

    result = compile_test('2 + (-3) * 2')
    assert_equal(-4, result)
  end

  def test_addition_fail
    assert_raise(Coffee::ParserError) { compile_test('1+1+1++1') }
  end

  def test_multiplication
    result = compile_test('2*2')
    assert_equal(4, result)

    resultA = compile_test('5*4*3*2*1')
    resultB = compile_test('1*2*3*4*5')
    assert_equal(resultA, resultB)
  end

  def test_priority
    result = compile_test('1+2*2')
    assert_equal(5, result)

    result = compile_test('(1+2)*2')
    assert_equal(6, result)
  end

end