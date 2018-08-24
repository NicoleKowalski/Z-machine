.global decode_table_two_operands

.extern asm_main
.extern decode_instructions_loop
.extern memory_read
.extern get_location_of_register
.extern msn
.extern ZMemoryLocalRegisters
.extern debug_mode
.extern branch
.extern sign_extend_16_bit
.extern check_if_long_branch

decode_table_two_operands:
    LDR R12, =msn
 	LDRB R9, [R12, #0]
 	CMP R9, #0x20
 	BNE skip_debug
		LDRB R8, [R10, #0]	;@extract type
		CMP R8, #3		;@check if type is C if not then its B type
			LDREQ R9, =#67					;@print C
			BLEQ send_to_UART
			LDRNE R9, =#66					;@print B
			BLNE send_to_UART
		STRH R0, [R10, #17] // 17 THESE ARE THE NEW VALUES
    	STRH R1, [R10, #19] // 19
    	STRH R3, [R10, #21] // 21
    	LDR R9, =#0x20
		BL send_to_UART		;@print space
		;@print instruction
		LDRB R0, [R10, #3]
    	BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		MOV R8, #1
    	print_operand_instruction:
			STRB R12, [R10, #24]	//this offset is okay
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_instruction
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
		;@ move onto getting the second operand
		LDR R9, =#0x20
		BL send_to_UART		;@print space
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
    	LDR R9, =#0x20
		BL send_to_UART		;@print space
		LDRH R0, [R10, #17]
    	LDRH R1, [R10, #19]
		LDRH R3, [R10, #21]
	skip_debug:
 	LDR R12, =ZMemoryLocalRegisters
    LDR R10,=mySpace
    LDRB R9, [R10, #3]
    CMP R9, #0x1
        BEQ JE
    CMP R9, #0x2
        BEQ JL
    CMP R9, #0x3
        BEQ JG
    CMP R9, #0x6
        BEQ JIN
    CMP R9, #0x8
        BEQ OR
    CMP R9, #0x9
        BEQ AND
    CMP R9, #0x0A
        BEQ TEST_ATTR
    CMP R9, #0x0B
        BEQ SET_ATTR
    CMP R9, #0x0C
        BEQ CLEAR_ATTR
    CMP R9, #0x0D
        BEQ STORE
    CMP R9, #0x0E
        BEQ INSERT_OBJ
    CMP R9, #0x0F
        BEQ LOADW
    CMP R9, #0x10
        BEQ LOADB
    CMP R9, #0x11
        BEQ GET_PROP
    CMP R9, #0x12
        BEQ GET_PROP_ADDR
    CMP R9, #0x13
        BEQ GET_NEXT_PROP
    CMP R9, #0x14
        BEQ ADD
    CMP R9, #0x15
        BEQ SUB
    CMP R9, #0x16
        BEQ MUL
    CMP R9, #0x17
        BEQ DIV
    CMP R9, #0x18
        BEQ MOD
    CMP R9, #0x19
        BEQ CALL_2S
    CMP R9, #0x1A
        BEQ CALL_2N
    CMP R9, #0x1B
        BEQ SET_COLOUR
    B determine_crash_counter

   JE:
    LDRB R9, [R10, #0]                        ;@get type
    CMP R9, #2
    LDREQ R11, =#2

    CMP R0, R1
            BEQ branch
    CMP R11, #2                                                ;@done if you only have 2 operands
        BLEQ memory_read
        BLEQ check_if_long_branch
        BEQ decode_instructions_loop
    LDRH R1, [R10, #32]
    CMP R0, R1
        BEQ branch
    CMP R11, #3                                                ;@done if you only have 3 operands
        BLEQ memory_read
        BLEQ check_if_long_branch
        BEQ decode_instructions_loop
    LDRH R1, [R10, #64]
    CMP R0, R1
        BEQ branch
	BL memory_read
    BL check_if_long_branch
    B decode_instructions_loop

    JL:
    LDRB R9, [R10, #23]			;@ load sign bit
    	MOV R8, #1
    	AND R9, R9, R8
    	CMP R9, #0				;@ see if operand was an 8-bit or not (if its not must sign extend)
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		LSREQ R8, R8, #30
    		ADDEQ R9, R9, R0
    		BLEQ sign_extend_16_bit
    		LSREQ R0, R0, #30
    		ADDEQ R0, R9, R0	;@ signed bit is now in the 16th position
    	LDRB R9, [R10, #23]		;@ load sign bit
    	MOV R8, #2
    	AND R9, R9, R8
    	CMP R9, #0				;@ see if operand was an 8-bit or not (if its not must sign extend)
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		LSREQ R8, R8, #30
    		ADDEQ R9, R9, R1
    		BLEQ sign_extend_16_bit
    		LSREQ R1, R1, #30
    		ADDEQ R1, R9, R1	;@ signed bit is now in the 16th position
    CMP R0, R1
    	BLT branch				;@ branch if less than (signed)
    ;@ if the branch is not taken, still need to increment the ZPC
    BL memory_read
    BL check_if_long_branch
    B decode_instructions_loop

    JG:
    LDRB R9, [R10, #23]			;@ load sign bit
    	MOV R8, #1
    	AND R9, R9, R8
    	CMP R9, #0				;@ see if operand was an 8-bit or not (if its not must sign extend)
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		LSREQ R8, R8, #30
    		ADDEQ R9, R9, R0
    		BLEQ sign_extend_16_bit
    		LSREQ R0, R0, #30
    		ADDEQ R0, R9, R0	;@ signed bit is now in the 16th position
    	LDRB R9, [R10, #23]		;@ load sign bit
    	MOV R8, #2
    	AND R9, R9, R8
    	CMP R9, #0				;@ see if operand was an 8-bit or not (if its not must sign extend)
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		LSREQ R8, R8, #30
    		ADDEQ R9, R9, R1
    		BLEQ sign_extend_16_bit
    		LSREQ R1, R1, #30
    		ADDEQ R1, R9, R1	;@ signed bit is now in the 16th position
    CMP R0, R1
    	BGT branch				;@ branch if less than (signed)
    ;@ if the branch is not taken, still need to increment the ZPC
    BL memory_read
    BL check_if_long_branch
    B decode_instructions_loop

    JIN:
    ;@ PLEASE NO
    B determine_crash_counter

    OR:
    	ORR R9, R0, R1
    B get_location_of_register

    AND:
    	AND R9, R0, R1
    B get_location_of_register

    TEST_ATTR:
        MOV R8, #14
    	MUL R0, R0, R8			;@ multiply the first operand by 14
    	LDRH R10, [R10, #34]		;@ get the location of the object table
    	CMP R1, #40					;@ is this the highest byte?
    		ADDHS R8, R0, #5		;@ offset to the highest byte
    		ADDHS R10, R8, R10		;@ add the offset of the highest byte to the location of the table with the object offset
    		LDRHSB R9, [R7, R10]	;@ load that byte
    		SUBHS R1, R1, #40
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BHS check_branch
    	CMP R1, #32
    		ADDHS R8, R0, #4
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #32
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BHS check_branch
    	CMP R1, #24
    		ADDHS R8, R0, #3
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #24
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BHS check_branch
    	CMP R1, #16
    		ADDHS R8, R0, #2
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #16
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BHS check_branch
    	CMP R1, #8
    		ADDHS R8, R0, #1
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #8
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BHS check_branch
    	CMP R1, #0
    		ADDHS R8, R0, #0
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #0
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    check_branch:
    TST R9, R8
    BEQ branch
    BNE decode_instructions_loop

    SET_ATTR:
        MOV R8, #14
    	MUL R0, R0, R8			;@ multiply the first operand by 14
    	LDRH R10, [R10, #34]		;@ get the location of the object table
    	CMP R1, #40					;@ is this the highest byte?
    		ADDHS R8, R0, #5		;@ offset to the highest byte
    		ADDHS R10, R8, R10		;@ add the offset of the highest byte to the location of the table with the object offset
    		LDRHSB R9, [R7, R10]	;@ load that byte
    		SUBHS R1, R1, #40
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		ORRHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS set_attribute
    	CMP R1, #32
    		ADDHS R8, R0, #4
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #32
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		ORRHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS set_attribute
    	CMP R1, #24
    		ADDHS R8, R0, #3
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #24
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		ORRHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS set_attribute
    	CMP R1, #16
    		ADDHS R8, R0, #2
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #16
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		ORRHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS set_attribute
    	CMP R1, #8
    		ADDHS R8, R0, #1
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #8
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		ORRHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS set_attribute
    	CMP R1, #0
    		ADDHS R8, R0, #0
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #0
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		ORRHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    set_attribute:
    B decode_instructions_loop

    CLEAR_ATTR:
    	MOV R8, #14
    	MUL R0, R0, R8			;@ multiply the first operand by 14
    	LDRH R10, [R10, #34]		;@ get the location of the object table
    	CMP R1, #40					;@ is this the highest byte?
    		ADDHS R8, R0, #5		;@ offset to the highest byte
    		ADDHS R10, R8, R10		;@ add the offset of the highest byte to the location of the table with the object offset
    		LDRHSB R9, [R7, R10]	;@ load that byte
    		SUBHS R1, R1, #40
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BICHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS cleared_attribute
    	CMP R1, #32
    		ADDHS R8, R0, #4
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #32
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BICHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS cleared_attribute
    	CMP R1, #24
    		ADDHS R8, R0, #3
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #24
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BICHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS cleared_attribute
    	CMP R1, #16
    		ADDHS R8, R0, #2
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #16
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BICHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS cleared_attribute
    	CMP R1, #8
    		ADDHS R8, R0, #1
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #8
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BICHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    		BHS cleared_attribute
    	CMP R1, #0
    		ADDHS R8, R0, #0
    		ADDHS R10, R8, R10
    		LDRHS R9, [R7, R10]
    		SUBHS R1, R1, #0
    		LDRHS R8, =#1
    		LSLHS R8, R8, R1
    		BICHS R9, R9, R8
    		STRHSB R9, [R7, R10]
    cleared_attribute:
    B decode_instructions_loop

    STORE:
    	MOV R9, R1
    	MOV R8, R0
    B store_to_register_location

    INSERT_OBJ:
    B determine_crash_counter

    LOADW:
    LSL R1, R1, #1
    ADD R8, R1, R0
    B fetch_register_operand

    LOADB:
    ADD R8, R1, R0
    B fetch_register_operand

    fetch_register_operand:
	CMP R8, #0xF
		BHI global_register_operand_2
	CMP R8, #0
		BEQ zstack_operand_2
		BNE local_register_operand_2
	global_register_operand_2:
	SUB R8, R8, #16
	LSL R8, R8, #1 		;@This is A
	STRB R11, [R10, #7]
	LDRH R11, [R10, #25]
	ADD R11, R8, R11
	LDRH R9 ,[R7, R11]
	REV16 R9, R9
	B get_location_of_register

	zstack_operand_2:
	LDR R9, =Zstack
	SUB R5, R5, #2
    LDRH R8, [R9, R5]   ;@ pop the zstack into R0
    ;@ need to decrement the 20th local register
    LDR R9,=#40
    LSL R9, R6, #6 		;@ multiply nesting depth by 64--B
    ADD R9, R9, #40		;@ add A and B giving you C the offset
    MOV R11, R9
    LDRH R9 ,[R12, R9]	;@ add c to the location of your zprodedure local zregister, this is the higher order byte
    SUB R9, R9, #1		;@ subtract 1 from the value in the register
    STRH R9, [R12, R11]	;@ store in the new value
	MOV R9, R8
	B get_location_of_register

    local_register_operand_2:
	SUB R8, R8, #1
	LSL R8, R8, #1 		;@ This is A
	LSL R9, R6, #6 		;@ This is B
	ADD R9, R9, R8 		;@ This is the offset of the zregister
	LDRH R9, [R12, R9]
    B get_location_of_register

    GET_PROP:
    ;@ TBD
    B determine_crash_counter

    GET_PROP_ADDR:
    ;@ TBD
    B determine_crash_counter

    GET_NEXT_PROP:
    ;@ TBD
    B determine_crash_counter

    ADD:
    	ADD R9, R0, R1
    B get_location_of_register

    SUB:
        SUB R9, R0, R1
    B get_location_of_register

    MUL:
    	LDRB R9, [R10, #23]		;@ load sign bit
    	MOV R8, #1
    	AND R9, R9, R8
    	CMP R9, #0				;@ see if operand was an 8-bit or not (if its not must sign extend)
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		ADDEQ R9, R9, R0
    		BLEQ sign_extend_16_bit
    		LSREQ R0, R0, #30
    		ADDEQ R0, R9, R0						;@ signed bit is now in the 16th position
    	LDRB R9, [R10, #23]		;@ load sign bit
    	MOV R8, #2
    	AND R9, R9, R8
    	CMP R9, #0				;@ see if operand was an 8-bit or not (if its not must sign extend)
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		ADDEQ R9, R9, R1
    		BLEQ sign_extend_16_bit
    		LSREQ R1, R1, #30
    		ADDEQ R1, R9, R1						;@ signed bit is now in the 16th position
    	STRH R3, [R10, #21]
   		BL multiply
   		MOV R9, R3
   		LDRH R3, [R10, #21]
    B get_location_of_register

    DIV:
    LDRB R9, [R10, #23]		;@ load sign bit
    	MOV R8, #1
    	AND R9, R9, R8
    	CMP R9, #0				;@ see if operand was an 8-bit or not (if its not must sign extend)
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		ADDEQ R9, R9, R0
    		BLEQ sign_extend_16_bit
    		LSREQ R0, R0, #30
    		ADDEQ R0, R9, R0						;@ signed bit is now in the 16th position
    	LDRB R9, [R10, #23]		;@ load sign bit
    	MOV R8, #2
    	AND R9, R9, R8
    	CMP R9, #0				;@ see if operand was an 8-bit or not (if its not must sign extend)
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		ADDEQ R9, R9, R1
    		BLEQ sign_extend_16_bit
    		LSREQ R1, R1, #30
    		ADDEQ R1, R9, R1						;@ signed bit is now in the 16th position
    	STRH R3, [R10, #21]
   		BL divide
   		MOV R9, R3
   		LDRH R3, [R10, #21]
    B get_location_of_register

    MOD:
     LDRB R9, [R10, #23]		;@ load sign bit
    	MOV R8, #1
    	AND R9, R9, R8
    	CMP R9, #0
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		ADDEQ R9, R9, R0
    		BLEQ sign_extend_16_bit
    		LSREQ R0, R0, #30
    		ADDEQ R0, R9, R0						;@ signed bit is now in the 16th position
    	LDRB R9, [R10, #23]		;@ load sign bit
    	MOV R8, #2
    	AND R9, R9, R8
    	CMP R9, #0
    		LSREQ R9, R9, #30
    		LSREQ R11, R11, #30
    		ADDEQ R9, R9, R1
    		BLEQ sign_extend_16_bit
    		LSREQ R1, R1, #30
    		ADDEQ R1, R9, R1						;@ signed bit is now in the 16th position
   		STRH R3, [R10, #21]
   		BL mod
   		MOV R9, R3
   		LDRH R3, [R10, #21]
    B get_location_of_register

    CALL_2S:
    	MOV R11, #1
    	STRB R11, [R10, #4]
    B calls

    CALL_2N:
        MOV R11, #0
    	STRB R11, [R10, #4]
    	MOV R11, #1
    B calls

    SET_COLOUR:
    ;@ do nothing, absolutely nothing
    B decode_instructions_loop

