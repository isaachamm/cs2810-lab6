.ORIG x3000
    AND R1, R1, x0          ; Set R1 to 0
    AND R2, R2, x0          ; Set R2 to 0
    LD R3, ASCIIDIFF
    LD R4, NEGASCIIDIFF
    IN                      ; Get the first number to multiply by
    ADD R1, R1, R0          ; Store in R1
    ADD R1, R1, R3          ; Convert from ASCII to numeric
    BRz ZERO_OUT
    IN                      ; Get the second number to multiply by
    ADD R2, R2, R0          ; Store in R2
    ADD R2, R2, R3          ; Convert from ASCII to numeric
    BRz ZERO_OUT
    AND R5 R5, x0
    ADD R5, R5, R1          ; Store our adder in R5 -- this is the number we will add R2 times
    AND R1, R1, x0          ; Set R1 to 0 before the loop so that we add the correct number of times

MULTIPLY_LOOP 
    ADD R1, R1, R5          
    ADD R2, R2, #-1         ; Subtract one from second factor until = 0
    BRp MULTIPLY_LOOP
    
; The next step is to get individual digits -- to do that, we have to divide by 10 and mod 10

    AND R5, R5, x0
    ADD R5, R5, R1          ; R5 is for storing the intermediate number -- the result of each subtraction.
    AND R6, R6, x0
    LD R7, START_DECIMAL   ; R7 is for storing the memory address where we will write our digits to.

DIVIDE_LOOP

    ADD R6, R6, #1          ; R6 keeps track of the number of times we subtract -- it will become the divide result
    ADD R5, R5, #-10
    BRzp DIVIDE_LOOP
    
    ; When we break this loop, we add 10 back to R5 and it becomes the next digit (functionally, it becomes our mod 10)
    ADD R5, R5, #10
    STR R5, R7, #0          ; Store this digit into the next memory address to know when to stop printing
    ADD R7, R7 #1
    AND R5, R5, x0
    ADD R6, R6, #-1         ; If the result is < 1, then we're done dividing
    BRnz POST_DIVIDE
    ADD R5, R5, R6          ; Move divisor from R6 to R5 and loop again.
    AND R6, R6, x0
    AND R2, R2, x0
    ADD R2, R2, R5
    BRp DIVIDE_LOOP         ; This should break once the divide result = 0, meaning result <10, and we store the mod
    
POST_DIVIDE
    AND R5, R5, x0
    ADD R5, R5, #-1
    
    LD R6, START_DECIMAL
    ADD R6, R6, #-1
    STR R5, R6, x0
    
    ADD R7, R7 #-1          ; This eliminates a leading 0 from incrementing the memory address previously
    AND R0, R0, x0          ; Set R0 to 0

PRINT_LOOP
    LDR R0, R7, #0          ; Move next digit to R0 to print
    ADD R0, R0, R4          ; Convert back to ASCII to print
    OUT
    ADD R7, R7 #-1
    AND R5, R5, x0
    LDR R5, R7, x0
    BRzp PRINT_LOOP
    
    HALT
    
ZERO_OUT
    AND R0, R0, x0
    ADD R0, R0, R4
    OUT
    HALT

ASCIIDIFF	.FILL	xFFD0	; To convert from ASCII to numeric
NEGASCIIDIFF .FILL x30      ; To convert from numeric to ASCII
START_DECIMAL .FILL x3100   ; The memory address where we store individual decimals

.END