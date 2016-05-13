; Programming Assignmnet #6 for CSCI 2525 - Assembly Language & Computer Organization
; Written by Justin Shapiro

TITLE strings.asm
; Best viewed in Notepad++

INCLUDE Irvine32.inc ; used for procedures where call was used rather than INVOKE

;===============================PROCEDURE PROTOTYPES======================================= ;
CheckInput 		  PROTO userInput_param:DWORD, instanceType_param:BYTE	                    ;
DisplayMenu 	  PROTO			                                                            ;
RouteUser  		  PROTO userInput_param2:DWORD                                              ;
GetStrings 		  PROTO routeType_param:BYTE                                                ;
printConcatString PROTO string_param:PTR BYTE                                               ;
str_cat    		  PROTO string1_param:PTR BYTE, string2_param:PTR BYTE                      ;
str_n_cat  	      PROTO string1_param2:PTR BYTE, string2_param2:PTR BYTE, nvar_param:BYTE   ;
str_str    	      PROTO string1_param3:PTR BYTE, string2_param3:PTR BYTE				    ;
;===========================================================================================;
.code
	main PROC
	;**********************************************************************************************
	;Description - directs user to the appropriate point in the program based on their choice 
	;			   by using INVOKE to first display a menu, then retrieve user input, then to
	;			   pass this input to another procedure using INVOKE to route the user accordingly 
	;Recieves - nothing
	;Returns - nothing
	;************************************************************************************************
			.data
				userInput1    DWORD 0			  			; needed to retrieve user input for eax to pass to CheckInput PROC
				select_option BYTE "Selection: ", 0			; Prompts the user to make a selection
				
			.code
				mov eax, white								; main text color of the program will be white
				call SetTextColor
				
				Menu: INVOKE DisplayMenu					; go to the DisplayMenu procedure to display a menu of choices for the user 
	
				Selection: mov edx, OFFSET select_option	; Prompt: "Selection: "
						   call WriteString
						   call ReadDec
								mov userInput1, eax
								INVOKE CheckInput, userInput1, 1	; CheckInput([user input]:DWORD, [type of error check]:BYTE)
								cmp dl, 1							; if check fails, CheckInput returns 1 in dl
									je Selection
								cmp dl, 2							; if check indicates an exit option, CheckInput returns 2 in dl
									je exitProgram
				
				INVOKE RouteUser, userInput1						; RouteUser([user input]:DWORD)
				jmp Menu
		
		exitProgram: exit
		main ENDP
		
		DisplayMenu PROC
		;**********************************************************************************
		;Description - displays a menu that promps the user to select one of four options
		;Recieves - nothing
		;Returns - nothing
		;**********************************************************************************
			.data
			    menu_Prmt BYTE "                                     Assignment 9:                                             ", 0
				prgmTitle BYTE "                          FUNCTIONS FOR STRING MANIPULATION                                    ", 0
				instrPrmt BYTE "                          <---choose a function to test--->                                    ", 0
				func1Prmt BYTE "1. str_cat()   - conactenates a string to the end of a target string                           ", 0
				func2Prmt BYTE "2. str_n_cat() - copy n characters of a source string and concatenate to end of a target string", 0
				func3Prmt BYTE "3. str_str()   - locate a substrng in a string                                                 ", 0
				exit_Prmt BYTE "4. Exit                                                                                        ", 0
							
			.code
				mov ecx, 7
				mov bl, 0
				printMenu: mov edx, OFFSET menu_Prmt		; a loop used to print the menu, where each array is of equal length
						   mov eax, 0
						   mov al, LENGTHOF menu_Prmt
						   mul bl							; multiplication by bl determines which line to print
							 
						   add edx, eax						; after multiplication by bl, the result stored in ax is added to edx
						   call WriteString
						   call Crlf
						   inc bl
				loop printMenu
				
				call Crlf
				call Crlf	
		ret
		DisplayMenu ENDP
		
		CheckInput PROC x1:DWORD, y1:BYTE	
		;*******************************************************************************************
		;Description - a reusable procedure for checking user input in many different ways
		;Recieves - user input as a DWORD parameter and a number indicating what type of checking
		;			to perform as BYTE parameter
		;Returns - 0, 1 or 2 in the dl register
		;*******************************************************************************************
			.data
				user_input1    EQU [x1 + 4]
				instance_type  EQU [y1 + 4]
				
				failCheck			   BYTE ?	; 0 = success, 1 = fail, 2 = program exit code
				
				overflow_prompt        BYTE "Sorry, that number exceeds 32-bits. Please try again....", 0
				signed_prompt          BYTE "Sorry, input must be unsigned. Please try again....", 0
				menuError_prompt       BYTE "Input must be a 1, 2, 3 or 4. Please try again...", 0
				letterError_prompt     BYTE "Choice must be either Y or N. Please try again...", 0
				upperBoundError_prompt BYTE "String length cannot exceed 255. Please try again...", 0
				
			.code
				push ebp							; create stack frame
				mov ebp, esp
				
				jo overflowError					; regardless of type check selected, if the overflow flag is set, display a specific error 
				cmp user_input1, 0					; if user input is less than zero at any point of the program, display a signed error
					jl rangeCmp			
					
				cmp instance_type, 1				; Check 1: used for tracking menu choices
					je menuCmp
				cmp instance_type, 2				; Check 2: used for checking proper response to a (Y/N) menu
					je letterCheck
				cmp instance_type, 3				; Check 3: used to check if a number is in a specific range
					je rangeCmp
				
				menuCmp: cmp user_input1, 4			; there are 4 menu options, therefore if user input is greater, throw an error 
							jg menuError
						 cmp user_input1, 0
							jle menuError
						 jmp doneChecking	
				
				letterCheck: cmp user_input1, 'Y'
								je doneChecking
							 cmp user_input1, 'y'
								je doneChecking
							 cmp user_input1, 'N'
								je doneChecking
							 cmp user_input1, 'n'
								je doneChecking
							 jmp letterError
							 
				rangeCmp: cmp user_input1, 0
							jl RangeSignedError
						  cmp user_input1, 255		; 255 is the upper limit for string lengths 
						    jg UpperBoundError
						  jmp doneChecking	
						  
				overflowError: mov edx, OFFSET overflow_prompt
							   jmp displayError
									   
				MenuError: mov edx, OFFSET menuError_prompt
						   jmp displayError
						   
				letterError: mov edx, OFFSET letterError_prompt
							 jmp displayError
						   
				RangeSignedError: mov edx, OFFSET signed_prompt
								  jmp displayError
				UpperBoundError: mov edx, OFFSET upperBoundError_prompt
								 jmp displayError
				
				displayError: call Crlf				; all error messages displayed will use this label to be printed. edx must have the offset 
							  mov eax, lightRed		; all error messages are displayed in red text
							  call SetTextColor
							   
							  call WriteString
							   
							  mov eax, white
							  call SetTextColor
							   
							  jo clrOF				; clear the overflow flag if it has been set 
							  jmp skip_clrOF
							   
							  clrOF: mov cl, 1
									 neg cl
							   
							  skip_clrOF:
							  call Crlf
							  call Crlf
							   
							  mov failCheck, 1		; if program reaches this point, input is invalid
							  jmp leaveProc1
			
				doneChecking: cmp user_input1, 4	; if program is sent to this label, input is valid
								je setExitCode
							mov failCheck, 0
							jmp leaveProc1
					  
				setExitCode: mov failCheck, 2		; in the special case where user input is 4, generate program exit code
		
				leaveProc1: mov dl, failCheck
							leave
				   
		ret
		CheckInput ENDP
		
		RouteUser PROC x2:DWORD
		;************************************************************************************************
		;Description - a reusable procedure that routes the user to the appropriate point in the program
		;Recieves - user input as a DWORD contain value used to route user
		;Returns - nothing
		;*******************************************************************************************
			.data
				user_input2 EQU [x2 + 4]
			
			.code
				push ebp							; create stack frame
				mov ebp, esp
				
				cmp user_input2, 1
					je Option1_GO
				cmp user_input2, 2
					je Option2_GO
				cmp user_input2, 3
					je Option3_GO
				
				Option1_GO: INVOKE GetStrings, 1	; in all cases, user will be routed to GetStrings PROC for string preprocessing
							jmp leaveProc2
							
				Option2_GO: INVOKE GetStrings, 2
							jmp leaveProc2
				
				Option3_GO: INVOKE GetStrings, 3
							jmp leaveProc2
							
		leaveProc2:	leave
		ret
		RouteUser ENDP
		
		GetStrings PROC, x3:BYTE
		;************************************************************************************************
		;Description - gets two strings from the user and prepares them in the approriate manner to send
		;			   to their specified procedure 
		;Recieves - procedure destination as BYTE parameter 
		;Returns - nothing
		;************************************************************************************************
			.data
				route_type EQU [x3 + 4]
				
				stringLength 		 BYTE 25			; string length default = 25, but can be changed
				defaultStringLPrmt   BYTE "String length is currently ", 0
				route_type1		     BYTE "You have selected to concatenate String 2 to String 1...", 0
				route_type2			 BYTE "You have selected to concatenate n-characters of String 2 to String 1...", 0
				route_type3			 BYTE "You have selected to search for String 2 within String 1...", 0
				string1_Prmt		 BYTE "Enter String 1: ", 0
				string2_Prmt		 BYTE "Enter String 2: ", 0
				strLengthError		 BYTE "Sorry, the size of the string you have entered exceeds the maximum string length of ", 0
				changeStrLengthPrmt  BYTE "Would you like to change the string length? (Y/N): ", 0
				warningNoticePrmt    BYTE "WARNING: CHANGING THE STRING LENGTH WILL RESTART PROCEDURE. CONTINUE? (Y/N): ", 0
				changeStrLengthPrmt2 BYTE "Enter the new string length: ", 0
				enter_nvar_Prmt      BYTE "Enter the number of characters in String 2 to concatenate to String 1: ", 0
				NError_Prmt  		 BYTE "Sorry, the amount of characters to concatenate must be less than or equal to the string to concatenate", 0
				concatFinishPrmt     BYTE "The concatenated string is: ", 0
				
				string1arr           BYTE 255 DUP(0)	; holds String 1: 255 is the maximum size, as some constant needed to be determined
				string2arr    		 BYTE 255 DUP(0)	; holds String 2: ////////....
				localErrCode		 BYTE ?				; used to route user to appropriate label within this procedure
				tempInput			 DWORD ?
				n_var_pass			 BYTE ?
				n_var_pass2			 DWORD ?
				str2length			 BYTE ?
				runOnce				 BYTE 0				; used to record if the procedure has already been run
				
			.code
				push ebp								; create stack frame
				mov ebp, esp
				
				mov stringLength, 25					; all instances of running this procedure will have 25 as the default string length value
				cmp runOnce, 1
					je refillArr
				jmp ProcStart
				
				refillArr: mov esi, OFFSET string1arr	; if procedure has been run already, the strings must be zeroed out in order for the procedure
						   mov edi, OFFSET string2arr	; to work properly after the first instance
						   mov al, 0
						   mov ecx, 255
						   LR: mov [esi], al
							   mov [edi], al
							   inc esi
							   inc edi
						   loop LR
			
				ProcStart: call Clrscr								; clear screen on every instance

			    mov eax, lightGreen									; tell the user which option they have selected 
				call SetTextColor
				cmp route_type, 1
					je route1Prmt
				cmp route_type, 2
					je route2Prmt
				cmp route_type, 3
					je route3Prmt
					
				route1Prmt: mov edx, OFFSET route_type1
							call WriteString
							jmp input_strings
				route2Prmt: mov edx, OFFSET route_type2
							call WriteString
							jmp input_strings
				route3Prmt: mov edx, OFFSET route_type3
							call WriteString
				
				input_strings: call Crlf							; code under this label will retrieve values for the two strings
							   call Crlf
							   
							   mov eax, white
							   call SetTextColor
							   
							   mov edx, OFFSET defaultStringLPrmt	; display length on console for users to keep in mind while they are typing 
							   call WriteString
							   
							   mov eax, yellow
							   call SetTextColor
							   
							   mov eax, 0
							   mov al, stringLength
							   call WriteDec
							   
							 string1Enter: call Crlf
										   call Crlf
										   
										   mov eax, white
										   call SetTextColor
							   
										   mov edx, OFFSET string1_Prmt
										   call WriteString
							   
										   mov edx, OFFSET string1arr
										   mov ecx, SIZEOF string1arr
										   call ReadString
										   mov localErrCode, 1				; if input was faulty local error code 1 will ensure user is brought here
												   cmp al, stringLength		; al stores the string length: it will be checked before moving on
													   jg lengthError
													   
							 string2Enter: call Crlf
										   
										   mov eax, white
										   call SetTextColor
							   
										   mov edx, OFFSET string2_Prmt
										   call WriteString
							   
										   mov edx, OFFSET string2arr
										   mov ecx, SIZEOF string2arr
										   call ReadString
										   mov str2length, al
										   mov localErrCode, 2
												   cmp al, stringLength
													   jg lengthError
							 jmp processStrings
							 
				lengthError: mov eax, lightRed							; all code under this label is used to deal with bad input
							 call SetTextColor
							 
							 call Crlf
							 mov edx, OFFSET strLengthError
							 call WriteString
							 mov eax, yellow
							 call SetTextColor
							 mov eax, 0
							 mov al, stringLength
							 call WriteDec
							 mov eax, lightRed
							 call SetTextColor
							 							 
							 changeLengthPrmt: call Crlf			; user has the option to change length of string, but will have to re-enter all strings
											   mov edx, OFFSET changeStrLengthPrmt
											   call WriteString
											   mov eax, 0
											   call ReadChar
											   mov ebx, 0
											   mov bl, al
											   mov tempInput, ebx
													INVOKE CheckInput, tempInput, 2
														cmp dl, 1
															je changeLengthPrmt
														cmp al, 'y'
															je warningNotice
														cmp al, 'Y'
															je warningNotice
														cmp localErrCode, 1
															je string1Enter
														cmp localErrCode, 2
															je string2Enter
							 warningNotice: mov eax, yellow
											call SetTextColor
											
											call Crlf
											
											mov edx, OFFSET warningNoticePrmt
											call WriteString
											call ReadChar
											mov ebx, 0
											mov bl, al
											mov tempInput, ebx
													INVOKE CheckInput, tempInput, 2
														cmp dl, 1
															je warningNotice
														cmp al, 'y'
															je changeStrLength
														cmp al, 'Y'
															je changeStrLength
														cmp localErrCode, 1
															je string1Enter
														cmp localErrCode, 2
															je string2Enter
							 changeStrLength: call Clrscr
											  redo_csl:
											  mov eax, white
											  call SetTextColor
											  
											  mov edx, OFFSET changeStrLengthPrmt2
											  call WriteString
											  
											  mov eax, 0
											  call ReadDec
											  mov tempInput, eax
												  INVOKE CheckInput, tempInput, 3
												  cmp dl, 1
													   je redo_csl
											  mov stringLength, al
											  jmp ProcStart
																						  
				processStrings: cmp route_type, 1				; once input has been verified, strings can now be sent to their destination
									je call_1
								cmp route_type, 2
									je call_2
								cmp route_type, 3
									je call_3
									
								call_1: INVOKE str_cat, ADDR string1arr, ADDR string2arr	; str_cat([target]:OFFSET, [source], OFFSET)
										INVOKE printConcatString, ADDR string1arr			; printConcatString ([string 1]:OFFSET)
										call WaitMsg
										mov runOnce, 1
										call Clrscr
										jmp leaveProc3
										
								call_2: call Crlf											; number of characters to concatenate must still be
										call Crlf											; obtained. It will be done so here.
										mov edx, OFFSET enter_nvar_Prmt
										call WriteString
										
										call ReadDec
										mov n_var_pass, al
										mov eax, 0
										mov al, n_var_pass
										mov n_var_pass2, eax
											INVOKE CheckInput, n_var_pass2, 3
												cmp dl, 1
													je call_2
											mov ecx, 0
											mov cl, stringLength
											cmp n_var_pass, cl							; n must be less than or equal to the string length
												jg NError
											mov cl, str2length
											cmp n_var_pass, cl							; n must also be less than or equal to the size of the source string
												jg NError
										
										INVOKE str_n_cat, ADDR string1arr, ADDR string2arr, n_var_pass
										INVOKE printConcatString, ADDR string1arr
										call WaitMsg
										mov runOnce, 1
										call Clrscr
										jmp leaveProc3
										
										NError: mov eax, lightRed
											    call SetTextColor
												
												mov edx, OFFSET NError_Prmt
												call WriteString
												 
												mov eax, white
												call SetTextColor
												
												call Crlf
												call Crlf
											
												jmp call_2 

								call_3: INVOKE str_str, ADDR string1arr, ADDR string2arr	; str_str([string to be searched]:OFFSET, [search string]:OFFSET)
										call WaitMsg
										mov runOnce, 1
										call Clrscr
										jmp leaveProc3
							
				leaveProc3: leave
		ret
		GetStrings ENDP	
		
		printConcatString PROC, x4:PTR BYTE
		;************************************************************************************************
		;Description - prints the resulting concatenated string when modified by str_cat or str_n_cat
		;Recieves - concatenated string as a PTR BYTE parameter
		;Returns - nothing
		;************************************************************************************************
			.data
				target_string EQU [x4 + 4]
				
				concatPrmt BYTE "The concatenated string is: ", 0
				
			.code
				push ebp					; create stack frame
				mov ebp, esp
				
				call Crlf
				
				mov edx, OFFSET concatPrmt
				call WriteString
				
				mov eax, lightMagenta
				call SetTextColor
				
				mov edx, target_string
				call WriteString
				
				mov eax, white
				call SetTextColor
				
				call Crlf
				call Crlf
				
				leave
		ret
		printConcatString ENDP
				
		str_cat PROC x5:PTR BYTE, y3:PTR BYTE
		;********************************************************************************************************
		;Description - appends a source string to the end of a target string
		;Recieves - source and target string as PTR BYTE parameters (the offset of their first elemets are passed)
		;Returns - nothing
		;********************************************************************************************************
			.data
				string1 EQU [x5 + 4]
				string2 EQU [y3 + 4]
				
				count BYTE 0		; used to store the size of the source string
				
			.code
				push ebp
				mov ebp, esp
				
				mov edi, string1				; edi = offset of target string
					L1: mov al, BYTE PTR [edi]	; mov edi to the end of the target string
						cmp al, 0
							je exitL1
						inc edi
					jmp L1
				
				exitL1:
				mov esi, string2				; esi = offset of source string
				mov count, 0
					L2: mov al, BYTE PTR [esi]
						cmp al, 0
							je exitL2
						inc esi
						inc count
					jmp L2
					
				exitL2:
				mov ebx, 0
				mov bl, count
				sub esi, ebx					; restored esi to the offset of the first element of the source string
				mov ecx, 0
				mov cl, count
				
				rep movsb						; repeats a byte-wise copy of the source string (esi) to the target string (edi) cl times
				
				leaveProc4: leave
		ret
		str_cat ENDP

		str_n_cat PROC x6:PTR BYTE, y4:PTR BYTE, z1:BYTE
		;********************************************************************************************************
		;Description - appends n-characters of a source string to the end of a target string
		;Recieves - source and target string as PTR BYTE parameters (the offset of their first elemets are passed)
		;Returns - nothing
		;********************************************************************************************************
			.data
				string1n EQU [x6 + 4]
				string2n EQU [y4 + 4]
				n_var	 EQU [z1 + 4]
								
			.code
				push ebp
				mov ebp, esp
				
				mov edi, string1n				; edi = offset of target string 
					L1n: mov al, BYTE PTR [edi] ; mov edi to the end of the target string
						cmp al, 0
							je exitL1n
						inc edi
					jmp L1n
				
				exitL1n:	
				mov esi, string2n				; esi = offset of source string
				mov ecx, 0
				mov cl, n_var
				
				rep movsb						; repeats a byte-wise copy of the source string (esi) to the target string (edi) cl times
												; where cl = n
				leaveProc5: leave
		ret
		str_n_cat ENDP 
		
		str_str PROC x7:PTR BYTE, y5: PTR BYTE
		;********************************************************************************************************
		;Description - determines if one string is a subset of another string
		;Recieves - source and target string as PTR BYTE parameters (the offset of their first elemets are passed)
		;Returns - nothing (but if used in the real world, it would return a boolean success/fail value)
		;********************************************************************************************************
			.data
				string1s EQU [x7 + 4]
				string2s EQU [y5 + 4]
				
				stringFound    BYTE "String 2 is a subset of String 1", 0
				stringNotFound BYTE "String 2 is not a subset of String 1", 0
				
				count2 BYTE 0				; used to store the length the string to search
				locationOfString DWORD ?	; used as a temporary place holder for the location of the found string, which would be returned in eax
			
			.code
				push ebp
				mov ebp, esp
				
				mov eax, 0
				
				mov edi, string1s
				mov count2, 0
					L1: mov al, BYTE PTR [edi]		; get the size of the string to search
						cmp al, 0
							je exitL2
						inc edi
						inc count2
					jmp L1
					
				exitL2:
				
				mov edi, string1s					; edi = string to search
				
				findString:
				mov esi, string2s					; esi = string to dermine whether or not it is a subset 
				
				mov al, [esi]						
				mov ecx, 0
				mov cl, count2
				repne scasb							; compare each character of the first string with the first character of second 
					jnz notFound					; if not match is found, ZF = 1 and second string is not a subset of the first string
				
				dec edi				
				mov locationOfString, edi			; move location of potentially found string to memory 
				inc edi								; restore edi for further processing
				inc esi								; after repne scasb, edi points to the next character after the previous, so adust esi accordingly
				L2: mov al, [edi]					; compare each element of second string with that of the first until the second string has reached
					mov bl, [esi]					; its end, or until a non-match has been discovered 
					cmp bl, 0						
						je found
					cmp al, bl
						jne notFound
					inc edi
					inc esi
				jmp L2
				
				notFound: mov edi, locationOfString		; there may be more than one of the same letter in the target string 
						  inc edi						; in which the subset string has as its first. Therefore, repeat the 
						  mov al, [edi]					; check until the end of the target string 
						  cmp al, 0
							jne findString
			
				          mov eax, lightRed
						  call SetTextColor
					   
						  call Crlf
						  
						  mov edx, OFFSET stringNotFound
						  call WriteString			   
						  call Crlf
						  
						  mov eax, white
						  call SetTextColor
						  
						  mov eax, 0					; move 0 to eax indicating a no-match
						 											  					  
						  jmp leaveProc6
						  
				found: mov eax, lightGreen
					   call SetTextColor
					   
					   call Crlf
					   
					   mov edx, OFFSET stringFound
					   call WriteString			   
					   call Crlf
					   
					   mov eax, white
					   call SetTextColor
					   
					   mov eax, locationOfString		; pass location of subset in eax
					   mov al, 1
					   mov bl, 1
					   sub al, bl						; set the zero flag as per instructions 
					  					   					  					   
				leaveProc6: leave
		ret
		str_str ENDP
								
END main