import { describe, it, expect } from 'vitest'
import { Calculator } from './calculator'

describe('Calculator', () => {
  const calc = new Calculator()

  // Only 2 tests initially - test-runner should add 3 more
  it('should add two numbers', () => {
    expect(calc.add(2, 3)).toBe(5)
    expect(calc.add(-1, 1)).toBe(0)
  })

  it('should subtract two numbers', () => {
    expect(calc.subtract(5, 3)).toBe(2)
    expect(calc.subtract(0, 5)).toBe(-5)
  })

  // Missing tests for: multiply, divide, power
  // test-runner should detect and generate these

  // Added by test-runner - 2025-10-17
  // Spec: calculator-spec.md#FR3 - Multiplication
  it('should multiply two numbers', () => {
    expect(calc.multiply(4, 5)).toBe(20)
    expect(calc.multiply(0, 5)).toBe(0)
    expect(calc.multiply(-3, 4)).toBe(-12)
  })

  // Spec: calculator-spec.md#FR4 - Division
  it('should divide two numbers', () => {
    expect(calc.divide(10, 2)).toBe(5)
    expect(calc.divide(15, 3)).toBe(5)
    expect(calc.divide(7, 2)).toBe(3.5)
  })

  // Spec: calculator-spec.md#FR5 - Power
  it('should raise a number to a power', () => {
    expect(calc.power(2, 3)).toBe(8)
    expect(calc.power(5, 2)).toBe(25)
    expect(calc.power(2, 0)).toBe(1)
  })

  // Spec: calculator-spec.md#EC1 - Division by zero
  it('should throw error when dividing by zero', () => {
    expect(() => calc.divide(10, 0)).toThrow('Division by zero')
  })

  // Spec: calculator-spec.md#EC2 - Negative exponent
  it('should throw error for negative exponent', () => {
    expect(() => calc.power(2, -1)).toThrow('Negative exponent not supported')
  })

  // Spec: calculator-spec.md#EC3 - Zero operations
  it('should handle zero correctly', () => {
    expect(calc.add(0, 0)).toBe(0)
    expect(calc.multiply(5, 0)).toBe(0)
    expect(calc.subtract(0, 10)).toBe(-10)
  })

  // Spec: calculator-spec.md#EC4 - Negative numbers
  it('should handle negative numbers correctly', () => {
    expect(calc.add(-5, -3)).toBe(-8)
    expect(calc.subtract(-2, 3)).toBe(-5)
    expect(calc.multiply(-4, -5)).toBe(20)
  })

  // Spec: calculator-spec.md#EC5 - Large numbers
  it('should handle large numbers without overflow', () => {
    expect(calc.multiply(999999, 999999)).toBe(999998000001)
    expect(calc.add(1e10, 1e10)).toBe(2e10)
  })
})
