# Calculator Specification

**Author**: Test Sample
**Date**: 2025-10-17
**Status**: Approved
**Version**: 1.0

## Overview

Simple calculator library with 5 basic operations for testing test-runner agent.

## Functional Requirements

### FR1: Addition
- **Function**: `add(a: number, b: number): number`
- **Behavior**: Returns sum of a and b
- **Example**: `add(2, 3)` → `5`

### FR2: Subtraction
- **Function**: `subtract(a: number, b: number): number`
- **Behavior**: Returns a minus b
- **Example**: `subtract(5, 3)` → `2`

### FR3: Multiplication
- **Function**: `multiply(a: number, b: number): number`
- **Behavior**: Returns product of a and b
- **Example**: `multiply(4, 5)` → `20`

### FR4: Division
- **Function**: `divide(a: number, b: number): number`
- **Behavior**: Returns a divided by b
- **Example**: `divide(10, 2)` → `5`
- **Error**: Throws error if b is zero

### FR5: Power
- **Function**: `power(a: number, b: number): number`
- **Behavior**: Returns a raised to the power of b
- **Example**: `power(2, 3)` → `8`
- **Error**: Throws error if b is negative

## Edge Cases

### EC1: Division by zero
- **Input**: `divide(10, 0)`
- **Expected**: Throw Error with message "Division by zero"

### EC2: Negative exponent
- **Input**: `power(2, -1)`
- **Expected**: Throw Error with message "Negative exponent not supported"

### EC3: Zero operations
- **Input**: `add(0, 0)`, `multiply(5, 0)`
- **Expected**: Correct mathematical results (0, 0)

### EC4: Negative numbers
- **Input**: `add(-5, -3)`, `subtract(-2, 3)`
- **Expected**: Correct results (-8, -5)

### EC5: Large numbers
- **Input**: `multiply(999999, 999999)`
- **Expected**: Correct result without overflow

## Test Coverage Target

- **Target**: 85% minimum
- **Current**: ~40% (only add and subtract tested)
- **Missing**: multiply, divide, power tests

## Success Criteria

- All 5 functions have tests
- All 5 edge cases covered
- Coverage >= 85%
- All tests pass
