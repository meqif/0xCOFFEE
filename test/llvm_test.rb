#!/usr/bin/env ruby
#
# (C)opyright 2009 Ricardo Martins <ricardo at scarybox dot net>
# Licensed under the MIT/X11 License. See LICENSE file for license details.

$:.unshift File.dirname(__FILE__) + "/../lib"

require 'test/unit'
require 'rubygems'
require 'coffee'

begin
  require 'redgreen'
rescue LoadError
  puts "WARNING: redgreen not found."
end

class Compiler < Test::Unit::TestCase

  attr_reader :parser, :generator

  def stfu
    old_stdout = STDOUT.clone
    STDOUT.reopen('/dev/null', 'w')
    yield
  ensure
    STDOUT.reopen(old_stdout)
  end

  def compile_test(source, test=true)
    @generator = Coffee.compile(source, test)
    generator.optimize
    generator.run
  end

  def compile(source)
    compile_test(source, false)
  end

  private :compile, :compile_test, :stfu

  def setup
    @parser = CoffeeParser.new
  end

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

    result = compile_test('2-1')
    assert_equal(1, result)

    result = compile_test('10 - 5 + 1')
    assert_equal(6, result)
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

    result = compile_test('((10*8)/4)%15')
    assert_equal(5, result)

    result = compile_test('10*8/4%15')
    assert_equal(5, result)

    result = compile_test('((10*9)/8)%7')
    assert_equal(4, result)

    result = compile_test('10*9/8%7')
    assert_equal(4, result)
  end

  def test_assign
    result = compile('a = 1+2*3')
    assert_equal(0, result)
  end

  def test_load
    result = compile_test('a = 1+2*3; a')
    assert_equal(7, result)

    result = parser.parse('a = 1; a').to_s
    assert_equal("Code(Assign(a,Number(1)),Load(a))", result)
  end

  def test_functions
    ['λ', '\\', 'fun'].each do |symb|
      result = compile("#{symb} x -> x")
      assert_equal(0, result)
    end

    f1 = 'λ x -> x + x'
    result = compile(f1)
    assert_equal(0, result)

    f2 = "(#{f1})"
    result = compile(f2)
    assert_equal(0, result)

    result = compile('fun x y -> x * y')
    assert_equal(0, result)

    result = compile("gamma = fun a b -> a + b")
    assert_equal(0, result)
  end

  def test_string_ast
    result = parser.parse('((10*8)/4)%15').to_s
    expected = "Code(Modulo(Division(Multiplication(Number(10),Number(8))," +
               "Number(4)),Number(15)))"
    assert_equal(expected, result)

    result = parser.parse('print(2 + (-3) * 2 - 1)').to_s
    expected = "Code(Print(Subtraction(Addition(Number(2)," +
               "Multiplication(Number(-3),Number(2))),Number(1))))"
    assert_equal(expected, result)
  end

  def test_sequence
    result = compile_test('1+1; 10*3')
    assert_equal(30, result)

    result = compile_test('a = 3; b = 4; a*a/b')
    assert_equal(2, result)
  end

  def test_print
    result = nil
    stfu { result = compile_test('print(10)') }
    assert_equal(3, result)

    result = nil
    stfu { result = compile_test('x = 2*2*2*2*2; print(x*4)') }
    assert_equal(4, result)
  end

  def test_kaboom
    #assert_raise(Coffee::NonTerminatedBlockError) { compile('print(1)') }
  end

end
