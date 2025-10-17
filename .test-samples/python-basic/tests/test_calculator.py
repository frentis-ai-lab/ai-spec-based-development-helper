"""
Test suite for Calculator
Only 2 tests initially - test-runner should add 3 more
"""
import pytest
from src.calculator import Calculator


class TestCalculator:
    """Calculator test suite"""

    def setup_method(self):
        """Setup test fixtures"""
        self.calc = Calculator()

    def test_add(self):
        """Test addition"""
        assert self.calc.add(2, 3) == 5
        assert self.calc.add(-1, 1) == 0

    def test_subtract(self):
        """Test subtraction"""
        assert self.calc.subtract(5, 3) == 2
        assert self.calc.subtract(0, 5) == -5

    # Missing tests for: multiply, divide, power
    # test-runner should detect and generate these
