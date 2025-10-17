"""
Simple calculator with 5 functions
Used for testing test-runner agent
"""


class Calculator:
    """Calculator class with basic operations"""

    def add(self, a: float, b: float) -> float:
        """Add two numbers"""
        return a + b

    def subtract(self, a: float, b: float) -> float:
        """Subtract b from a"""
        return a - b

    def multiply(self, a: float, b: float) -> float:
        """Multiply two numbers"""
        return a * b

    def divide(self, a: float, b: float) -> float:
        """
        Divide a by b

        Raises:
            ValueError: If b is zero
        """
        if b == 0:
            raise ValueError("Division by zero")
        return a / b

    def power(self, a: float, b: float) -> float:
        """
        Raise a to the power of b

        Raises:
            ValueError: If b is negative
        """
        if b < 0:
            raise ValueError("Negative exponent not supported")
        return a ** b
