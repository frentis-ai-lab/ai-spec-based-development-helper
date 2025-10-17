/**
 * Simple calculator with 5 functions
 * Used for testing test-runner agent
 */

export class Calculator {
  /**
   * Add two numbers
   */
  add(a: number, b: number): number {
    return a + b
  }

  /**
   * Subtract b from a
   */
  subtract(a: number, b: number): number {
    return a - b
  }

  /**
   * Multiply two numbers
   */
  multiply(a: number, b: number): number {
    return a * b
  }

  /**
   * Divide a by b
   * @throws Error if b is zero
   */
  divide(a: number, b: number): number {
    if (b === 0) {
      throw new Error('Division by zero')
    }
    return a / b
  }

  /**
   * Raise a to the power of b
   * @throws Error if b is negative
   */
  power(a: number, b: number): number {
    if (b < 0) {
      throw new Error('Negative exponent not supported')
    }
    return Math.pow(a, b)
  }
}
