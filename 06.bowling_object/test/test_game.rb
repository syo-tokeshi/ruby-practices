# frozen_string_literal: true

require 'test/unit'
require_relative '../game'

class GameTest < Test::Unit::TestCase
  def test_game1
    game1 = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5')
    assert_equal(139, game1.calc_frames)
  end

  def test_game2
    game2 = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X')
    assert_equal(164, game2.calc_frames)
  end

  def test_game3
    game3 = Game.new('0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4')
    assert_equal(107, game3.calc_frames)
  end

  def test_game4
    game4 = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0')
    assert_equal(134, game4.calc_frames)
  end

  def test_game5
    game5 = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8')
    assert_equal(144, game5.calc_frames)
  end

  def test_game6
    game6 = Game.new('X,X,X,X,X,X,X,X,X,X,X,X')
    assert_equal(300, game6.calc_frames)
  end

  def test_game7
    game7 = Game.new('0,0,0,0,0,0,0,0,0,0,0,0')
    assert_equal(0, game7.calc_frames)
  end

  def test_argument_error
    e = assert_raises ArgumentError do
      Game.new('x,z,0,100,X,X,X,X,X,X,X,X')
    end
    assert_equal '1-9の範囲の数字、またはX(ストライク)を渡して下さい', e.message
  end
end
