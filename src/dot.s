.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li t0, 0            # t0 (accumulated dot product sum)    
    li t1, 0            # t1 (loop cnt i)

loop_start:
    bge t1, a2, loop_end
    # TODO: Add your own implementation

    # mul_custom t2, t1, a3      # t2 = i * stride0
    addi sp, sp, -20
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)

    mv a0, t1                    # a0 (mul_custom multiplicand)
    mv a1, a3                    # a1 (mul_custom multiplier)
    jal ra, mul_custom
    mv t2, a0                    # move mul_custom result to t2

    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    addi sp, sp, 20

    # mul_custom t3, t1, a4      # t3 = i * stride1
    addi sp, sp, -20
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)

    mv a0, t1                    # a0 (mul_custom multiplicand)
    mv a1, a4                    # a1 (mul_custom multiplier)
    jal ra, mul_custom
    mv t3, a0                    # move mul_custom result to t3

    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    addi sp, sp, 20

    slli t2, t2, 2             # t2 = t2 * 4
    slli t3, t3, 2             # t3 = t3 * 4

    add t2, a0, t2             # t2 = addr of arr0[i * stride0]
    add t3, a1, t3             # t3 = addr of arr1[i * stride1]

    lw t4, 0(t2)               # t4 = arr0[i * stride0]
    lw t5, 0(t3)               # t5 = arr1[i * stride1]

    # mul_custom t4, t4, t5    # t4 = arr0[i * stride0] * arr1[i * stride1]
    addi sp, sp, -20
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)

    mv a0, t4                    # a0 (mul_custom multiplicand)
    mv a1, t5                    # a1 (mul_custom multiplier)
    jal ra, mul_custom
    mv t4, a0                    # move mul_custom result to t4

    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    addi sp, sp, 20

    add t0, t0, t4             # t0 (accumulated dot product sum)  

    addi t1, t1, 1             # Increment t1 (loop cnt i)

    j loop_start

######## My custom mul func ########
# Args:
# a0: multiplicand
# a1: multiplier

# Returns:
# a0: product (result)

# Will use t0, t1 !!!

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

######## My custom mul func ########

loop_end:
    mv a0, t0           # copy t0 (accumulated dot product sum) to a0
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
