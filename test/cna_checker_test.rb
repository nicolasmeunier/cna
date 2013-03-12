require 'test/unit'
require '../lib/cna_checker'
class TestCna < Test::Unit::TestCase
  def test_invalid
    checker = CnaChecker.new("ca")
    expected = checker.check("Nicolas", "Meunier", "02109201")
    assert_equal expected, false
  end

  def test_valid
    checker = CnaChecker.new("ca")
    expected = checker.check("URBARDO", "SAA", "00346525")
    assert_equal expected, true
  end
end