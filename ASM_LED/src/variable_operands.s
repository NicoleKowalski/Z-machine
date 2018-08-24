.global decode_table_variable_operands
.global decode_table_extended_operations
.global decode_table_no_operand

.extern memory_read
.extern send_to_UART
.extern determine_determine_crash_counter_counter
.extern msn
.extern ZMemoryLocalRegisters
.extern debug_mode
.extern extract_sign_bit
.extern random_number

decode_table_variable_operands:
    LDR R12, =msn
 	LDRB R9, [R12, #0]
 	CMP R9, #0x20
 	BNE skip_debug
		MOV R9, #67					;@print C
		BL send_to_UART
		STRH R0, [R10, #17] ;@ 17 THESE ARE THE NEW VALUES
    	STRH R1, [R10, #19] ;@ 19
    	STRH R3, [R10, #21] ;@  21
    	LDR R9, =#0x20
		BL send_to_UART		;@print space
		;@print instruction
    	LDRB R0, [R10, #3]
    	BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@ store size
		MOV R8, #1
    	print_operand_instruction:
			STRB R12, [R10, #24]	;@ this offset is okay
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_instruction
    	;@ print operand
		CMP R11, #0
			BEQ done_debug_variable
		;@ move onto getting the first operand
		LDRH R0, [R10, #17]
		BL getSizeofHex
		LDR R9, =#0x20
		BL send_to_UART		;@print space
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		MOV R8, #1
		print_operand_1:
			STRB R12, [R10, #24]
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_1
		CMP R11, #1
			BEQ done_debug_variable
		LDR R9, =#0x20
		BL send_to_UART		;@print space
		;@ move onto getting the second operand
		LDRH R0, [R10, #19]
		MOV R8, #1
		BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		print_operand_2:
			STRB R12, [R10, #24]
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_2
		CMP R11, #2
			BEQ done_debug_variable
		LDR R9, =#0x20
		BL send_to_UART		;@print space
		;@ move onto getting the third operand
		LDRB R0, [R10, #32]
		MOV R8, #1
		BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		print_operand_3:
			STRB R12, [R10, #24]
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_3
		CMP R11, #3
			BEQ done_debug_variable
		LDR R9, =#0x20
		BL send_to_UART		;@print space
		;@ move onto getting the fourth operand
		LDRB R0, [R10, #64]
		MOV R8, #1
		BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		print_operand_4:
			STRB R12, [R10, #24]
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_4
		CMP R11, #4
			BEQ done_debug_variable
		LDR R9, =#0x20
		BL send_to_UART		;@print space
		;@ move onto getting the fifth operand
		LDRB R0, [R10, #66]
		MOV R8, #1
		BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		print_operand_5:
			STRB R12, [R10, #24]
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_5
		CMP R11, #5
			BEQ done_debug_variable
		LDR R9, =#0x20
		BL send_to_UART		;@print space
		;@ move onto getting the sixth operand
		LDRB R0, [R10, #68]
		MOV R8, #1
		BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		print_operand_6:
			STRB R12, [R10, #24]
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_6
		CMP R11, #6
			BEQ done_debug_variable
		LDR R9, =#0x20
		BL send_to_UART		;@print space
		;@ move onto getting the sevnth operand
		LDRB R0, [R10, #70]
		MOV R8, #1
		BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		print_operand_7:
			STRB R12, [R10, #24]
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_7
		CMP R11, #7
			BEQ done_debug_variable
		LDR R9, =#0x20
		BL send_to_UART		;@print space
		;@ move onto getting the eighth operand
		LDRB R0, [R10, #72]
		MOV R8, #1
		BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		print_operand_8:
			STRB R12, [R10, #24]
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_8
		LDR R9, =#0x20
		BL send_to_UART		;@print space
    	done_debug_variable:
    	LDR R9, =#0x20
		BL send_to_UART		;@print space
		LDRH R0, [R10, #17]
    	LDRH R1, [R10, #19]
		LDRH R3, [R10, #21]
	skip_debug:
    ;@ The following have a variable operand count
    LDR R12, =ZMemoryLocalRegisters
    LDR R10,=mySpace
    LDRB R9, [R10, #3]
    CMP R9, #0x0
        BEQ CALL_VS
    CMP R9, #0x1
        BEQ STOREW
    CMP R9, #0x2
        BEQ STOREB
    CMP R9, #0x3
        BEQ PUT_PROP
    CMP R9, #0x4
        BEQ READ
    CMP R9, #0x5
    	LSREQ R8, R8, #20
        BEQ PRINT_CHAR
    CMP R9, #0x6
        BEQ PRINT_NUM
    CMP R9, #0x7
        BEQ RANDOM
    CMP R9, #0x8
        BEQ PUSH
    CMP R9, #0x9
        BEQ PULL
    CMP R9, #0xA
        BEQ SPLIT_WINDOW
    CMP R9, #0xB
        BEQ SET_WINDOW
    CMP R9, #0xC
        BEQ CALL_VS2
    CMP R9, #0xD
        BEQ ERASE_WINDOW
    CMP R9, #0xF
        BEQ SET_CURSOR
    CMP R9, #0x11
        BEQ SET_TEXT_STYLE
    CMP R9, #0x13
        BEQ OUTPUT_STREAM
    CMP R9, #0x14
        BEQ INPUT_STREAM
    CMP R9, #0x16
    	BEQ READ_CHAR
    CMP R9, #0x18
        BEQ NOT
    CMP R9, #0x19
        BEQ CALL_VN
    CMP R9, #0x1A
        BEQ CALL_VN2
    CMP R9, #0x1B
        BEQ TOKENIZE
    CMP R9, #0x1F
        BEQ CHECK_ARG_COUNT
    B determine_crash_counter

    CALL_VS:
    	MOV R9, #1
    	STRB R9, [R10, #4]
    	SUB R11, R11, #1
    B calls

    STOREW:
    	LSL R1, R1, #1			;@ multiply the second operand by two
	    ADD R8, R0, R1 			;@ add the two together
	    LDRH R9, [R10, #32]		;@ get the third operand
    B store_to_register_location

    STOREB:
	    ADD R8, R0, R1
	    LDRH R9, [R10, #32]		;@ get the third operand
    B store_to_register_location

    PUT_PROP:
    ;@ TBD
    B determine_crash_counter

    READ:
    ;@ TBD
    B determine_crash_counter

	PRINT_CHAR:
        MOV R9, R0                                  ;@counting which operand to print character from
        BL send_to_UART
        B decode_instructions_loop

    PRINT_NUM:				;@ only have 1 operand
    	LDRB R9, [R10, #23]		;@ load sign bit
    	MOV R8, #1
    	AND R9, R9, R8
    	CMP R9, #1
    		LSREQ R9, R9, #30
    		ADDEQ R9, R9, R0
    		BLEQ extract_sign_bit
    		LSREQ R0, R0, #30
    		ADDEQ R0, R9, R0						;@ signed bit is now in the 16th position
    	STRH R3, [R10, #21]							;@ save branch stuff
   		LDR R1, =#0x8000							;@ mask to determine the sign of number
   		AND R1, R1, R9
   		LSR R1, R1, #15								;@ R1 now contains the sign of the number (1 = neg, 0 = positive)
   		MOV R9, #45									;@ ascii character '-'
   		CMP R1, #1
   		BLEQ send_to_UART							;@ print the '-' character if its negative
   		MOV R9, R0                                  ;@ counting which operand to print character from
   		STRH R0, [R10, #17]
   		LDR R0, =#0x8000
   		BIC R0, R9, R0								;@ R0 now contains the number without the sign
   		BL getSizeNum
   		MOV R11, R3									;@ save the size of the number
   		CMP R11, #0
   			LDREQB R9, =#48
   			BLEQ send_to_UART
   			BEQ	decode_instructions_loop
   		MOV R8, #1									;@Set counter to 1 for first character
   	printnum:
   		BL getNextChar
   		MOV R9, R3									;@save the character to print
   		STRB R8, [R10, #11]
   		BL send_to_UART
   		LDRB R8, [R10, #11]							;@retrieve counter
   		CMP R8, R11
   		ADD R8, R8, #1								;@ increment counter
   		BNE printnum
		LDRH R0, [R10, #17]							;@restore everything
   		LDRH R3, [R10, #21]
   		B decode_instructions_loop

    RANDOM:
    	;@ R0 holds the maximum value
    	BL random_number
    	MOV R9, R3
    	LDR R12,=ZMemoryLocalRegisters
    B get_location_of_register

	PUSH:
	LDR R9, =Zstack
	STRH R0, [R9, R5]   ;@ store the result into the stack
	ADD R5, R5, #2
	;@ need to increment the 20th local register
	LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
	ADD R9, R9, #40                 ;@ add A and B giving you C the offset
	MOV R11, R9
	LDRH R9 ,[R12, R9]        ;@ add c to the location of your zprodedure local zregister, this is the higher order byte
	ADD R9, R9, #1                ;@ add 1 to the value in the register
	STRH R9, [R12, R11]        ;@ store in the new value
	B decode_instructions_loop

	PULL:
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
	MOV R9, R1	;@ STORE POPPED VALUE
	MOV R8, R0	;@ MOVE REG
	B store_to_register_location

    SPLIT_WINDOW:
    B decode_instructions_loop

    SET_WINDOW:
    B decode_instructions_loop

    CALL_VS2:
        MOV R9, #1
    	STRB R9, [R10, #4]
    	SUB R11, R11, #1
    B calls

    ERASE_WINDOW:
    B decode_instructions_loop

    SET_CURSOR:
    B decode_instructions_loop

    SET_TEXT_STYLE:
    ;@ what do I do here?
    B determine_crash_counter

    OUTPUT_STREAM:
    B decode_instructions_loop

    INPUT_STREAM:
    ;@ what do I do here?
    B determine_crash_counter

    READ_CHAR:
    ;@ TBD
    B determine_crash_counter

    NOT:
    	MVN R9, R0
    B get_location_of_register

    CALL_VN:
    	MOV R9, #0
    	STRB R9, [R10, #4]
    	SUB R11, R11, #1
    B calls

    CALL_VN2:
        MOV R9, #0
    	STRB R9, [R10, #4]
    	SUB R11, R11, #1
    B calls

    TOKENIZE:
    ;@ TBD :(
    B determine_crash_counter

    CHECK_ARG_COUNT:
    LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
    ADD R9, R9, #44                 ;@ add A and B giving you C the offset
    LDRH R9, [R12, R9]        	   ;@ store the operand
    CMP R0, R9
    	BEQ branch
    BL memory_read
    BL check_if_long_branch
    B decode_instructions_loop

	decode_table_extended_operations:
    ;@ at this point in time the document has no information on handling SAVE_UNDO
    B determine_crash_counter
