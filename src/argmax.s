.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)

    li t1, 0
    li t2, 1
loop_start:
    # TODO: Add your own implementation
    beq t2, a1, loop_end        # If t2 (loop cnt) == a1 (arr len), goto loop_end

    slli t3, t2, 2              # t3 = t2 * 4
    add t3, a0, t3              # t3 = a0 + t3 (current element addr)
    lw t4, 0(t3)                # t4 (current element)
    
    ble t4, t0, loop_cont       # if t4 (current element value) <= t0 (current max value), continue
    
    mv t0, t4                   # update t0 (current max value)
    mv t1, t2                   # update t1 (index of current max value)

loop_cont:
    addi t2, t2, 1              # Increment t2 (loop cnt)
    j loop_start                # Goto loop_start

loop_end:
    mv a0, t1                   # Move t1 (index of current max value) to a0
    ret

handle_error:
    li a0, 36
    j exit
