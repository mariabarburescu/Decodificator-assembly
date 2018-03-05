extern puts
extern printf

section .data
filename: db "./input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa,0

section .text
global main

; TODO: define functions and helper functions
; Functie pentru calcularea lungimii unui sir
strlen_funct:
    push ebp
    mov ebp, esp
    mov ebx, dword [ebp+8]
    xor eax, eax

; Parcurg sirul si numar caracterele    
test_one_byte:
    mov dl, byte [ebx]
    test dl, dl
    je strlen_out
    inc eax
    inc ebx
    jmp test_one_byte

strlen_out:
    leave
    ret

;TASK_1
xor_strings:
    push ebp
    mov ebp, esp

    mov eax, dword [ebp+8] ; Primul parametru care reprezinta mesajul ce trebuie decriptat
    mov edx, dword [ebp+12] ; Al doilea paramtru care reprezinta cheia
    
xor_str:
    mov bl, byte[eax] ; Parcurg mesajul
    test bl, bl ; Verific daca a ajuns la final
    je end_xor
    mov bh, byte[edx] ; Parcurg cheia
    xor bl, bh ; Efectuez decriptarea
    mov byte[eax], bl ; Decriptarea in-place
    inc eax
    inc edx
    jmp xor_str

end_xor:
    leave
    ret

;TASK_2
rolling_xor:
    push ebp
    mov ebp, esp
    
    mov eax, dword [ebp+8] ; Primul parametru, mesajul
    xor ebx, ebx
    mov bl, byte[eax] ; Primul caracter
    inc eax
    
bucla:
    mov bh, byte[eax] ; Al doilea caracter
    test bh, bh
    je end_rolling
    xor bl, bh
    mov byte[eax], bl  ; Decriptarea in-place
    inc eax
    mov bl, bh
    jmp bucla
    
end_rolling:
    leave
    ret
    
;TASK_3
convert_hex_strings:
    push ebp
    mov ebp, esp

    mov eax, dword [ebp+8]
    xor edx, edx
    
convert:
    xor ebx, ebx
    mov bl, byte[eax+edx] ; Primul caracter din pereche
    test bl, bl
    je end_convert
    mov bh, byte[eax+edx+1] ; Al doilea caracter din pereche
    test bh, bh
    je end_convert
    
    ; Converia pentru primul caracter
    cmp bl, 'a' 
    jl number_bl
    sub bl, 'a' ; Conversia in cazul in care este caracter
    add bl, 10
    jmp next    
      
number_bl:
    sub bl, '0' ; Conversia in cazul in care este numar
    
    ; Conversia pentru al doilea caracter
next:
    cmp bh, 'a'
    jl number_bh
    sub bh, 'a' ; Conversia in cazul in care este caracter
    add bh, 10
    jmp next2    
      
number_bh:
    sub bh, '0' ; Conversia in cazul in care este numar 
    
next2:
    shl bl, 4 ; Pentru a efectua inmultirea cu 16, shiftez la stanga cu 4 pozitii
    add bl, bh ; Adunam cele doua rezultate obtinute
    shr edx, 1 ; Impart edx la 2 cu ajutorul shiftarii la dreapta
    mov byte[eax+edx], bl ; Decodarea in-place
    shl edx, 1 ; Aduc edx la valoarea precedenta
    add edx, 2 ; Sar peste cele doua caractere prelucrate
    jmp convert
    
end_convert:
    leave
    ret
    
;TASK_4
base32decode:
    push ebp
    mov ebp, esp
    
    mov edx, dword [ebp+8]
    push edx
    
    ; Aflu lungimea mesajului
    push edx
    call strlen_funct
    add esp, 4
    
    pop edx
    xor ebx, ebx
    
; Convertesc mesajul conform alfabetului base32
base_repeat:
    mov bl, byte [edx]
    test bl, bl 
    je end_base
    cmp bl, '='
    je over_number
    cmp bl, 'A'
    jl base_number
    sub bl, 'A'
    jmp over_number
    
base_number:
    sub bl, '2'
    add bl, 26
    
over_number:
    mov byte[edx], bl
    inc edx
    jmp base_repeat
    
end_base:
    sub edx, eax
    xor eax, eax
    mov eax, edx
    
decode_base32:
    ; Formez primul caracter din bloc
    mov bl, byte [edx]
    test bl, bl
    je end_base32
    cmp bl, 61
    je end_base32
    shl bl, 3
    mov bh, byte[edx+1]
    shr bh, 2
    add bl, bh
    
add1:
    mov byte [eax], bl
    inc eax
        
    ; Formez al doilea caracte
    mov bl, byte [edx+1]

    shl bl, 6
    mov bh, byte[edx+2]
    
    cmp bh, 61
    je end_base32
    shl bh, 1
    add bl, bh
    mov bh, byte[edx+3]
    
    shr bh, 4
    add bl, bh
    
add2:
    mov byte [eax], bl
    inc eax
        
    ; Formez al 3-lea caracter
    
    mov bl, byte [edx+3]
    shl bl, 4
    mov bh, byte[edx+4]
    
    cmp bh, 61
    je end_base32
    
    shr bh, 1
    add bl, bh
    
add3:
    mov byte [eax], bl
    inc eax
    
    ; Formez al 4-lea caracter
    
    mov bl, byte [edx+4]
    shl bl, 7
    mov bh, byte[edx+5]
    
    cmp bh, 61
    je end_base32
    
    shl bh, 2
    add bl, bh
    mov bh, byte[edx+6]
    shr bh, 3
    add bl, bh
    
add4:
    mov byte [eax], bl
    inc eax
        
    ; Formez al 5-lea caracter
        
    mov bl, byte [edx+6]
    shl bl, 5
    mov bh, byte[edx+7]
    
    cmp bh, 61
    je end_base32
    add bl, bh
    
add5:
    mov byte [eax], bl
    inc eax
    add edx, 8
    mov bl, byte[edx]
    test bl, bl
    jne decode_base32
    
end_base32:
    mov byte [eax], 0
    leave
    ret

;TASK_5
bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
    
    mov edi, [ebp+8] ; Mesajul ce trebuie decriptat
    mov edx, edi
    xor ebx, ebx
    mov bl, [ebp+12] ; Cheia
    
; Decodificarea cu o cheie de un octet    
bruteforce: 
    mov bh, byte [edi]
    test bh, bh
    je finish_bruteforce
    xor bh, bl
    mov byte [edi], bh
    inc edi
    jmp bruteforce
    
finish_bruteforce:    
    mov edi, edx
    
repeat:
    ; Caut subsirul force in mesajul decriptat
    cmp byte [edi], 0                     
    je next_key			
    cmp byte [edi], 'f'
    je char2
    inc edi
    jmp repeat
    
char2:
    inc edi
    cmp byte [edi], 0                     
    je next_key
    cmp byte [edi], 'o'
    je  char3
    inc edi
    jmp repeat
    
char3:
    inc edi
    cmp byte [edi], 0                     
    je next_key
    cmp byte [edi], 'r'
    je  char4
    inc edi
    jmp repeat
    
char4:
    inc edi
    cmp byte [edi], 0                     
    je next_key
    cmp byte [edi], 'c'
    je  char5
    inc edi
    jmp repeat
    
char5:
    inc edi
    cmp byte [edi], 0                     
    je next_key
    cmp byte [edi], 'e'
    je  success
    inc edi
    jmp repeat
    
next_key:
    ; Revin la inceputul sirului
    mov edi, edx

    ; Aduc mesajul la forma initiala    
initial_string:
    mov bh, byte[edi]
    test bh, bh
    je string_back
    xor bh, bl
    mov byte[edi], bh
    inc edi
    jmp initial_string
    inc edi
    
string_back:
    mov edi, edx
    
    inc bl ; Schimb cheia
    jmp bruteforce
    
success:
    leave
    ret
    
main:
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp
    sub esp, 2300
    
    ;fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80
    
	; read(fd, ebp-2300, inputlen);
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80

	; close(fd);
	mov eax, 6
	int 0x80

	; all input.dat contents are now in ecx (address on stack)

	; TASK 1: Simple XOR between two byte streams
	; TODO: compute addresses on stack for str1 and str2
        
        push ecx ; Pun mesajul pe stiva pentru a-i afla lungimea
        call strlen_funct
        add esp, 4
        
        mov ebx, ecx ; Pun mesajul in ebx pentru a putea merge mai departe la cheie
        
        inc eax ; In eax este stocata lungimea mesajului si adaug 1 pentru a putea ajunge la cheie
        add ecx, eax ; Acum in ecx am cheia
        
        ; Pun pe stiva mesajul si cheia pentru a le putea pasta
        push ecx
        push ebx
        
	; TODO: XOR them byte by byte
        push ecx
        push ebx
        call xor_strings
        add esp, 8

	; Print the first resulting string
        ; ebx se afla deja pe stiva
	call puts
	add esp, 4

	; TASK 2: Rolling XOR
	; TODO: compute address on stack for str3

        pop ecx ; Restaurez ecx de pe stiva
                
        ; Aflu lungimea mesajului
        push ecx
        call strlen_funct
        add esp, 4
        
        inc eax
        add ecx, eax ; Ajung la urmatorul mesaj        
        
	; TODO: implement and apply rolling_xor function
        push ecx
        call rolling_xor
        add esp, 4
        
        push ecx ; Adaug ecx pe stiva pentru a-i pastra valoarea
        
        	; Print the second resulting string
	push ecx
	call puts
	add esp, 4

	
	; TASK 3: XORing strings represented as hex strings
	; TODO: compute addresses on stack for strings 4 and 5
        
        ; Restaurez valoarea lui ecx si o pun pe stiva
        pop ecx
        
        ; Aflu lungimea mesajului
        push ecx
        call strlen_funct
        add esp, 4
        
        ; Ajung la urmatorul mesaj - Mesajul de care am nevoie pentru task-ul 3
        inc eax
        add ecx, eax
        
        ; TODO: implement and apply xor_hex_strings
        ; Fac conversia pentru mesaj
        push ecx
        call convert_hex_strings
        add esp, 4
        
        push ecx
        push ecx
        call strlen_funct
        add esp, 4
        
        inc eax
        add ecx, eax
        
        ; Fac conversia pentru cheie
        push ecx
        call convert_hex_strings
        add esp, 4     
                          
        ; Sterg caracterele ramase
        shr edx, 1
        mov byte[ecx+edx], 0 
        
        pop eax
        mov byte[eax+edx], 0
    
        push ecx ;Salvez cele doua stringuri pe stiva
        push eax
        
        ; Fac decriptarea cu ajutorul functiei de la task-ul 1
        push ecx
        push eax
        call xor_strings
        add esp, 8
              
	; Print the third string
	;push addr_str4
        ; Mesajul se afla deja pe stiva
	call puts
	add esp, 4
	
	; TASK 4: decoding a base32-encoded string
        ; Voi apela de doua ori functia strlen_funct, deoarece la task-ul anterior am pus un null la mijlocul stringului
        ; TODO: compute address on stack for string 6
        pop ecx
        push ecx
        call strlen_funct
        add esp, 4
        
        inc eax
        add ecx, eax    
        
        push ecx
        call strlen_funct
        add esp, 4
        
        inc eax
        add ecx, eax
                
        push ecx
        push ecx

	; TODO: implement and apply base32decode

        push ecx
        call base32decode
        add esp, 4
        
        ; Print the fourth string
        call puts
        add esp, 4

	; TASK 5: Find the single-byte key used in a XOR encoding
	; TODO: determine address on stack for string 7

        pop ecx
                
        push ecx
        call strlen_funct
        add esp, 4
        
        inc eax
        add ecx, eax    
        
        push ecx
        call strlen_funct
        add esp, 4
        
        inc eax
        add ecx, eax
        
        push ecx
        call strlen_funct
        add esp, 4
        
        inc eax
        add ecx, eax
        
        push ecx
        call strlen_funct
        add esp, 4
        
        inc eax
        add ecx, eax
        
        push ecx
        call strlen_funct
        add esp, 4
        
        inc eax
        add ecx, eax
        
        ; Initilizez cheia cu 0
        xor edx, edx
        mov eax, ecx     
        
	; TODO: implement and apply bruteforce_singlebyte_xor
        push edx
        push eax
        call bruteforce_singlebyte_xor
        add esp, 8 


	; Print the fifth string and the found key value
	push ecx
	call puts
	add esp, 4
                
	push ebx
	push fmtstr
	call printf
	add esp, 8

	; TASK 6: Break substitution cipher
	; TODO: determine address on stack for string 8
	; TODO: implement break_substitution
	;push substitution_table_addr
	;push addr_str8
	;call break_substitution
	;add esp, 8

	; Print final solution (after some trial and error)
	;push addr_str8
	;call puts
	;add esp, 4

	; Print substitution table
	;push substitution_table_addr
	;call puts
	;add esp, 4

	; Phew, finally done
    xor eax, eax
    leave
    ret
