# Assignment 2: Classify

## Part A: Mathematical Functions

## relu.s
The relu function use a loop to iterates through each element of the array. If the value is greater than or equal to zero, just skip it and move to next element. Otherwise, replace the element with zero.

**Error Condition**

If length of array is less than 1, return 36.


## argmax.s
The argmax function use a loop to iterates through each element of the array. If the value is greater than the current max value, update current max value and index of current max value. Otherwise, move to next element. Finally, return the index of max value.

**Error Condition**

If length of array is less than 1, return 36.


## dot.s
First, we have to implement our own mul operation. Using a loop to implement the shift-and-add algorithm:
1. Check if the least significant bit of the multiplier is set.

2. If set, it adds the current value of the multiplicand to the product.

3. It then shifts the multiplicand left by 1 bit and the multiplier right by 1 bit.

The loop continues until the multiplier becomes 0.

```
mul_custom:
    li t0, 0                        # Initialize t0, temporary store product (result)

mul_custom_loop:
    beq a1, x0, mul_custom_end      # If a1 (multiplier) is 0, goto mul_custom_end
    andi t1, a1, 1                  # t1 (check if the least significant bit of multiplier is set)
    beq t1, x0, mul_custom_skip     # If not set, goto mul_custom_skip

    add t0, t0, a0                  # Add a0 (multiplicand) to t0 (product)

mul_custom_skip:
    slli a0, a0, 1                  # Shift a0 (multiplicand) left 
    srli a1, a1, 1                  # Shift a1 (multiplier) right 
    j mul_custom_loop               # Goto mul_custom_loop 

mul_custom_end:
    mv a0, t0                       # move product (result) to a0
    ret                             # Return from function
```

The dot function using a loop to calculates the dot product of two arrays with their strides. Finally, return the dot product result.

**Error Condition**

If element count is less than 1, return 36.
If any stride is less than 1, return 37.


## matmul.s
The matmul function includes outer loop and inner loop. 

The outer loop iterates over each row of M0 matrix. 's0' tracks the current row in M0 matrix. 's1' is set to zero, which tracks the current col in M1 matrix. 's4' points to the first column of M1 matrix. If 's0' is less than 'a1', move to inner loop and do matrix multiplication, otherwise finish the matmul function.

```
outer_loop_start:
    #s0 is going to be the loop counter for the rows in A
    li s1, 0
    mv s4, a3
    blt s0, a1, inner_loop_start

    j outer_loop_end

...

outer_loop_end:
    # 
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    
    addi sp, sp, 28
    
    ret
```

The inner loop calls the dot function to calculate M0_row × M1_col, then stores the dot product result to the target address of result matrix D. If 's1' equals to 'a5', finish inner loop and move to next row in M0 matrix. 

```
inner_loop_start:
# HELPER FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use = number of columns of A, or number of rows of B
#   a3 (int)  is the stride of arr0 = for A, stride = 1
#   a4 (int)  is the stride of arr1 = for B, stride = len(rows) - 1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
    beq s1, a5, inner_loop_end

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    
    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B
    
    jal dot
    
    mv t0, a0 # storing result of the dot product into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24
    
    sw t0, 0(s2)
    addi s2, s2, 4 # Incrememtning pointer for result matrix
    
    li t1, 4
    add s4, s4, t1 # incrememtning the column on Matrix B
    
    addi s1, s1, 1
    j inner_loop_start
    
inner_loop_end:
    # TODO: Add your own implementation
    
    slli t0, a2, 2      # t0 = a2 * 4

    add s3, s3, t0      # move to next row in matrix A
    
    addi s0, s0, 1      # increment outer loop counter

    j outer_loop_start
```

**Error Condition**
1. Validates M0: Ensures positive dimensions
2. Validates M1: Ensures positive dimensions
3. Validates multiplication compatibility: M0_cols = M1_rows

All failures trigger program exit with code 38




## Part B: File Operations and Main

## read_matrix.s
The read_matrix function includes several steps:

1. Open the file using 'fopen'

2. Read matrix dimensions (# rows and # cols), using 'fread' to read 8 bytes (each 4 bytes).

3. Calculate matrix size (# matrix elements * 4 bytes).
    * \*matrix elements = # rows * # cols (using my own implementation of mul operation)
    * Convert to bytes by shifting left by 2

4. Allocate memory using 'malloc' based on the calculated byte size.

5. Read matrix data into memory, using 'fread'.

6. Using 'fclose' to close file.


**Error Condition**

If any file operation fails, exit with the following codes:
* 48: Malloc error
* 50: fopen error
* 51: fread error
* 52: fclose error

## write_matrix.s
The write_matrix function includes several steps:

1. Open the file using 'fopen'

2. Write matrix dimensions (# rows and # cols) using 'fwrite'.

3. Calculate matrix size (# matrix elements * 4 bytes).
    * \*matrix elements = # rows * # cols (using my own implementation of mul operation)
    
4. Write the matrix data using 'fwrite'.

5. Using 'fclose' to close file.

**Error Condition**

Use the following exit codes for errors:
* 53: fopen error
* 54: fwrite error
* 55: fclose error

## classify.s
The classify function includes several steps:

1. Read two weight matrices (M0 and M1) and input matrix using 'read_matrix'.

2. Compute intermediate matrix h = matmul(m0, input) using 'matmul'.

3. Compute ReLU(h) using 'relu'

4. Compute output matrix o = matmul(m1, h) using 'matmul'.

5. Save the output matrix o to file using 'write_matrix'.

6. Find the index of the largest element in output matrix o using 'argmax'

**Error Condition**

Use the following exit codes for errors:
* 31 - Invalid argument count
* 26 - Memory allocation failure





