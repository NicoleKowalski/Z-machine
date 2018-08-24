.global decode_table_no_operand
.global VERIFY
.global RTRUE
.global RFALSE
.global find_the_character

.extern RETURN
.extern memory_read
.extern send_to_UART
.extern determine_determine_crash_counter_counter
.extern msn
.extern ZMemoryLocalRegisters
.extern debug_mode
.extern crash_
.extern store_to_register_location

decode_table_no_operand:
    LDR R12, =msn
 	LDRB R9, [R12, #0]
 	CMP R9, #0x20
 	BNE skip_debug
		MOV R9, #65					;@print A
		BL send_to_UART
		STRH R0, [R10, #17] ;@ 17 THESE ARE THE NEW VALUES
    	STRH R1, [R10, #19] ;@ 19
    	STRH R3, [R10, #21] ;@ 21
    	LDR R9, =#0x20
		BL send_to_UART		;@ print space
		LDRB R0, [R10, #3]
    	BL getSizeofHex
    	LSR R12, R12, #30
		ADD R12, R12, R3			;@ store size
		MOV R8, #1
		;@print instruction
    	print_operand_instruction:
			STRB R12, [R10, #24]
			STRB R8, [R10, #11]
			BL getNextChar
			MOV R9, R3
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_instruction
    	LDR R9, =#0x20
		BL send_to_UART		;@ print space
		LDRH R0, [R10, #17]
    	LDRH R1, [R10, #19]
		LDRH R3, [R10, #21]
	skip_debug:
    ;@ The following all have no operands that are taken in 
    LDR R12, =ZMemoryLocalRegisters
    LDR R10,=mySpace
    LDRB R9, [R10, #3]
    LDRB R9, [R10, #3]
    CMP R9, #0x0
        BEQ RTRUE
    CMP R9, #0x1
        BEQ RFALSE
    CMP R9, #0x2
        BEQ PRINT
    CMP R9, #0x3
        BEQ PRINT_RET
    CMP R9, #0x8
        BEQ RET_POPPED
    CMP R9, #0xD
        BEQ VERIFY
    CMP R9, #0xE
        BEQ EXTENDED_OPCODE
    MOV R12, #0
    B determine_crash_counter
    
    RTRUE:
    	MOV R11, #1 ;@ return from the current zprodecure with a 1 as the result
    B RETURN
   
    RFALSE:
    	MOV R11, #0 ;@ return from the current zprodecure with a 0 as the result
    B RETURN

    PRINT:
    grab_next_two_bytes:
    BL memory_read
    LDR R9, =#0x80		;@ check if the top bit is the stop bit
    AND R9, R8, R9		;@ extract the possible stop bit
    STRB R9, [R10, #8]
    LSL R11, R8, #8	;@ shift most significant bits
    BL memory_read
    ORR R11, R8, R11	;@ concatenate the least significant byte to most significant
    ;@ first character
    LDR R9, =#0x7C00
    AND R9, R9, R11
    LSR R9, R9, #10
    BL find_the_character
    BL send_to_UART
    ;@ second character
    LDR R9, =#0x3E0
    AND R9, R9, R11
    LSR R9, R9, #5
    BL find_the_character
    BL send_to_UART
    ;@ third character
    LDR R9, =#0x1F
    AND R9, R9, R11
    BL find_the_character
    BL send_to_UART
    LDRB R9, [R10, #8]
    CMP R9, #0
    	BEQ grab_next_two_bytes
    B decode_instructions_loop

    find_the_character:
    CMP R9, #0
        LSREQ R9, R9, #10
        ADDEQ R9, R9, #0x20
        BEQ character_found
    CMP R9, #1
    	BEQ character_found
    CMP R9, #2
    	BEQ character_found
    CMP R9, #3
    	BEQ character_found
    CMP R9, #4
   		BEQ character_found
    CMP R9, #5
    	BEQ character_found
	CMP R9, #6
	   LSREQ R9, R9, #10
	   ADDEQ R9, R9, #0x61
	   BEQ character_found
	CMP R9, #7
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x62
	    BEQ character_found
	CMP R9, #8
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x63
	    BEQ character_found
	CMP R9, #9
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x64
	    BEQ character_found
	CMP R9, #10
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x65
	    BEQ character_found
	CMP R9, #11
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x66
	    BEQ character_found
	CMP R9, #12
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x67
	    BEQ character_found
	CMP R9, #13
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x68
	    BEQ character_found
	CMP R9, #14
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x69
	    BEQ character_found
	CMP R9, #15
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x6A
	    BEQ character_found
	CMP R9, #16
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x6B
	    BEQ character_found
	CMP R9, #17
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x6C
	    BEQ character_found
	CMP R9, #18
	    LSREQ R9, R9, #10
	    ADDEQ R9, R9, #0x6D
	    BEQ character_found
	CMP R9, #19
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x6E
		BEQ character_found
	CMP R9, #20
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x6F
		BEQ character_found
	CMP R9, #21
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x70
		BEQ character_found
	CMP R9, #22
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x71
		BEQ character_found
	CMP R9, #23
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x72
		BEQ character_found
	CMP R9, #24
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x73
		BEQ character_found
	CMP R9, #25
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x74
		BEQ character_found
	CMP R9, #26
	 	LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x75
		BEQ character_found
	CMP R9, #27
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x76
		BEQ character_found
	CMP R9, #28
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x77
		BEQ character_found
	CMP R9, #29
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x78
		BEQ character_found
	CMP R9, #30
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x79
		BEQ character_found
	CMP R9, #31
		LSREQ R9, R9, #10
	 	ADDEQ R9, R9, #0x7A
	 	BEQ character_found
	CMP R9, #1
	   LSREQ R9, R9, #10
	   ADDEQ R9, R9, #0x0A 	;@ PRINT A CARRIAGE RETURN
	LDR R8,=0xE0001030 		;@ memory location to read/write for the UART
    STR R9, [R8]
		LSREQ R9, R9, #10
		ADDEQ R9, R9, #0x0A ;@ PRINT A NEWLINE
	character_found:
    MOV R15, R14
    
    PRINT_RET:
    grab_next_two_bytes_print_ret:
    BL memory_read
    LDR R9, =#0x80		;@ check if the top bit is the stop bit
    AND R9, R8, R9		;@ extract the possible stop bit
    STRB R9, [R10, #8]
    LSL R11, R8, #8	;@ shift most significant bits
    BL memory_read
    ORR R11, R8, R11	;@ concatenate the least significant byte to most significant
    ;@ first character
    LDR R9, =#0x7C00
    AND R9, R9, R11
    LSR R9, R9, #10
    BL find_the_character
    BL send_to_UART
    ;@ second character
    LDR R9, =#0x3E0
    AND R9, R9, R11
    LSR R9, R9, #5
    BL find_the_character
    BL send_to_UART
    ;@ third character
    LDR R9, =#0x1F
    AND R9, R9, R11
    BL find_the_character
    BL send_to_UART
    LDRB R9, [R10, #8]
    CMP R9, #0
    	BEQ grab_next_two_bytes_print_ret ;@ LOOPS FOR DAYS
    ;@ PRINT A NEW LINE
    LSR R9, R9, #32
	ADD R9, R9, #0x0A 		;@ PRINT A CARRIAGE RETURN
	LDR R8,=0xE0001030 		;@ memory location to read/write for the UART
    STR R9, [R8]
	LSR R9, R9, #32
	ADD R9, R9, #0x0A ;@ PRINT A NEWLINE
	STR R9, [R8]
	;@ RETURN WITH A VALUE OF 1
	MOV R11, #1
    B RETURN
    
    RET_POPPED:
    LDR R9, =Zstack
	SUB R5, R5, #2      ;@ change the ZSP
	LDRH R1, [R9, R5]   ;@ pop the zstack
	;@ need to decrement the 20th local register
	LDR R9,=#40
	LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
	ADD R9, R9, #40                ;@ add A and B giving you C the offset
	MOV R11, R9
	LDRH R9 ,[R12, R9]        ;@ add c to the location of your zprodedure local zregister, this is the higher order byte
	SUB R9, R9, #1                ;@ add 1 from the value in the register
	STRH R9, [R12, R11]        ;@ store in the new value
	MOV R11, R1	;@ STORE POPPED VALUE
    B RETURN
    
    NEW_LINE:
	LDR R8,=0xE0001030 		;@ memory location to read/write for the UART
	LDR R9, =0x0D 			;@ ASCII value for carriage return
	STR R9, [R8]            ;@ write the ASCII value for carriage return to the memory address
	LDR R9, =0x0A ;@
	STR R9, [R8]  ;@ write the ASCII value for new line to the memory address
    B decode_instructions_loop
    
    VERIFY:
	;@ jumps to here after SW7 has been moved down, upload is complete
	;@ header mode is directed by SW6-- only need to verify the header if SW6 is 0
	;@ if the verification is successful this will branch to decode instructions
	;@ otherwise determine_crash_counter
	MOV R8, #0
    ;@ SET UP THE DEFAULT VALUES FOR NO HEADER MODE
        ;@ Save Object Table Location
        LDR R8, =#0x1000
        STRH R8, [R10, #45]
        ;@ Save dictionary location
        LDR R8, =#0x2000
        STRH R8, [R10, #45]
    MOV R8, #0
	STR R8, [R6] 		;@ Nesting depth is 0
	MOV R5, #0 			;@ ZSP Starts at 0
	LDR R8, =0x41220000 ;@ address of the switches
	LDR R9, [R8]
	AND R9, R9, #64
	CMP R9, #64 		;@ if SW6 is 1, then there is no header, no need to verify
	MOV R4, #0			;@ no header present, set ZPC to 0
	LDR R11, =#0x4000
	STR R11, [R10, #25]
	BEQ decode_instructions_loop
	LDRH R4, [R7, #0x4]	;@ header is present, read ZPC from there located at Zmemory location with an offset of 4
	REV16 R4, R4
	ADD R4, R4, #1
	MOV R9, #0
	add_up_zmemory: 	;@ add up all the Zmemory from 0x40 to the end
			LDRB R8, [R7, R4]	;@ R4 is holding the value of ZPC, location of first instruction
			ADD R9, R9, R8	;@ accumulate the op codes obtained from memory_read
			LDR R8, =#2000001
			CMP R4, R8	;@ check if at the end of the file
			ADDNE R4, R4, #1
			BNE add_up_zmemory
		LDR R8, =#0xffff
		AND R9, R9, R8
	    ;@ now to get the value the check sum is compared to
	    LDRH R8, [R7, #28] ;@ the value is located at a decimal offset of 28
	    REV16 R8, R8
		CMP R9, R8			;@ compare to the given result
			BNE crash_
	LDRH R4, [R7, #0x4]		;@ reload the appropiate ZPC counter value
	REV16 R4, R4
	LDRH R11, [R7, #0x0C] ;@ GLOBAL REGISTERS
	REV16 R11, R11
	STRH R11, [R10, #25]
    ;@ Save Object Table Location
    LDRH R8, [R7, #0x0A]
    REV16 R8, R8
    STRH R8, [R10, #34]
    ;@ Save dictionary location
    LDRH R8, [R7, #0x08]
    REV16 R8, R8
    STRH R8, [R10, #36]
    ADD R4, R4, #1
	B decode_instructions_loop
    
    EXTENDED_OPCODE:
    B determine_crash_counter
    
