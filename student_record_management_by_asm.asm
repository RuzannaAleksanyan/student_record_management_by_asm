section .data
    STUDENT_MAX_COUNT equ 160   ; Size of Student struct in bytes
    StudentSize equ 160         ; Size of Student struct in bytes
    AcademySize equ 16          ; Size of Academy struct in bytes

    StudentIdOffset equ 0
    StudentNameOffset equ 4
    StudentSurnameOffset equ 54
    StudentAgeOffset equ 104
    StudentGradeOffset equ 108

    AcademyStudentsOffset equ 0
    AcademySizeOffset equ 8

    Student:
        id dd 0
        name db 50 dup(0)
        surname db 50 dup(0)
        age dd 0
        grade dd 0

    Academy:
        students dq 0
        size dd 0

    message db 'Hello, this is a simple program!', 0
    message_len equ $ - message

    num_students dd 0  ; Declare num_students variable
    choice dd 0        ; Declare choice variable
    ID dd 0            ; Declare id variable

    filename db 'your_filename.txt', 0  ; Replace 'your_filename.txt' with the actual file name or path

    header db 256 dup(0) ; Define a character array for the header

    line_cont dd 0  ; Declare line_cont variable


    records_loaded dd 0 ; Declare and initialize records_loaded variable

    menu_prompt db '1. Add a new student record', 10, '2. Display all records', 10, '3. Update a record', 10, '4. Delete a record', 10, '5. Exit', 10, 'Enter your choice: ', 0

    choice_format db "%d", 0
    format db "%s", 0

    invalid_choice_message db 'Invalid choice. Please try again.', 10, 0

    goodbye_message db 'Goodbye! Thank you for using the program.', 10, 0
    goodbye_message_len equ $ - goodbye_message

section .bss
    new_student resb StudentSize  ; Allocate space for a new Student struct

section .text
    global _start

    extern printf                  ; External declaration for printf function
    extern scanf                   ; External declaration for scanf function


_start:
    ; Initialize the Academy struct
    lea rdi, [Academy]
    mov qword [rdi + AcademyStudentsOffset], 0  ; Initialize student pointer to 0
    mov dword [rdi + AcademySizeOffset], 0      ; Initialize size to 0

    ; Call the allocate_students procedure
    call allocate_students

    ; Call the student_record_management procedure
    lea rdi, [Academy]
    call student_record_management

    ; Exit the program
    mov eax, 60          ; syscall number for sys_exit
    xor edi, edi        ; exit code 0
    syscall             ; make syscall

student_record_management:
    mov rdi, StudentSize
    mov rax, 8
    mov rdi, 0
    syscall
    test rax, rax
    jz error_handling1
    mov qword [new_student], rax

    lea rdi, [Academy]
    call load_from_file
    mov eax, [records_loaded]
    cmp eax, -1
    je error_handling1
    mov dword [ID], eax
    ; Menu loop
menu_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, menu_prompt            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, 117   ; length of the string
    syscall

    ; Read user choice
    lea rdi, [choice_format]
    lea rsi, [choice]
    ; jmp read_int
    call read_int
    jmp l1
l1:
    ; Process user choice
    cmp dword [choice], 1
    jl invalid_choice      ; Jump if less than 1 (invalid choice)
    cmp dword [choice], 5
    jg invalid_choice      ; Jump if greater than 5 (invalid choice)

    ; If the choice is within the valid range, jump to the corresponding option
    cmp dword [choice], 1
    je add_student_option
    cmp dword [choice], 2
    je display_records_option
    cmp dword [choice], 3
    je update_record_option
    cmp dword [choice], 4
    je delete_record_option
    cmp dword [choice], 5
    je exit_program

    ; If the choice is within the valid range, jump back to the menu loop
    jmp menu_loop


add_student_option:
    ; ete paymany chisht e
    jmp menu_loop

display_records_option:
    ; ete paymany chisht e
    jmp menu_loop

update_record_option:
    ; ete paymany chisht e
    jmp menu_loop

delete_record_option:
    ; ete paymany chisht e
    jmp menu_loop

invalid_choice:
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_choice_message     ; pointer to the string
    mov rdx, 32   ; length of the string
    syscall

    jmp menu_loop    




load_from_file:
     ; Open the file
     mov rdi, filename ; Replace 'filename' with the actual file name or path
     mov rax, 2 ; System call number for opening:
     mov rsi, 0 ; Flags: O_RDONLY (read-only)
     mov rdx, 0 ; Mode: not needed for read-only
     syscall

     ; Check for errors in the open syscall
     test rax, rax ; Check if rax (file descriptor) is negative
     js error_handling_file_open ; Jump to error handling if negative

     ; Continue with the rest of the code for memory allocation and initialization

     ; Initialize num_students:
     mov dword [num_students], STUDENT_MAX_COUNT

     ; Allocate memory for student array
     mov rdi, [num_students]
     mov rax, 9 ; System call number for sbrk
     mov rdx, rdi
     syscall

     ; Check for errors in the sbrk syscall
     test rax, rax
     jz error_handling_memory_alloc

     ; Save the allocated memory address in Academy structure
     lea rdi, [Academy]
     mov qword [rdi + AcademyStudentsOffset], rax

     ; Set academy->size to 0
     mov dword [rdi + AcademySizeOffset], 0

     ; Process file line by line


error_handling_file_open:
    ; Handle file opening error (print an error message, etc.)
    ; Optionally, close the file if it was opened before
    jmp exit

error_handling_memory_alloc:
    ; Handle memory allocation error (print an error

error_handling_file_read:
    ; Handle file reading error (print an error message, free resources, etc.)
    ; Optionally, close the file if it was opened before
    jmp exit

exit_program:
    lea rdi, [Academy]
    call write_in_file

    ; Display a goodbye message
    mov rax, 1
    mov rdi, 1
    lea rsi, goodbye_message     ; pointer to the string
    mov rdx, goodbye_message_len ; length of the string
    syscall

    mov eax, 60         ; syscall number for sys_exit
    xor edi, edi        ; exit code 0
    syscall

exit:
    ; Your exit code here
    ret

read_int:
    mov rax, 0          ; syscall number for sys_read
    mov rdi, 0          ; file descriptor 0 (stdin)
    mov rdx, 10         ; number of bytes to read
    lea rsi, [choice]   ; pointer to the variable to store the read integer
    syscall

    ; Convert ASCII to integer
    xor rax, rax
    xor rcx, rcx

convert_loop:
    movzx rdx, byte [rsi + rcx]
    cmp rdx, 10     ; check for newline character
    je convert_done
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp convert_loop

convert_done:
    ret

write_in_file:
    ; Implementation
    ret

read_file_loop:
    ; Allocate memory for a new Student struct
    mov rdi, StudentSize       ; Size of a Student struct
    mov rax, 8                 ; System call number for brk
    mov rdi, 0                 ; Null argument
    syscall
    test rax, rax              ; Check if rax (allocated address) is zero
    jz error_handling_file_read ; Jump to error handling if zero
    mov qword [new_student], rax  ; Save the address of the new Student struct

    ; Read a line from the file
    mov rdi, rax ; File descriptor
    lea rsi, [new_student]
    mov rdx, StudentSize
    mov rax, 0          ; System call number for read
    syscall

    ; Check for errors in the read syscall
    test rax, rax
    js error_handling_file_read

    ; Parse the student record
    lea rsi, [new_student]
    call parse_student

    ; Call add_student function
    lea rdi, [Academy]
    lea rsi, [new_student]
    call add_student

    ; Increment line_cont
    inc dword [line_cont]

    ; Check for end of file
    mov rdi, rax ; File descriptor
    mov rax, 19 ; System call number for lseek (check if EOF)
    mov rdx, 0 ; Offset
    mov rsi, 1 ; Whence (SEEK_CUR)
    syscall
    test rax, rax
    jnz read_file_loop ; Continue reading if not EOF

    ; Close the file (assuming it's no longer needed)
    mov rax, 3 ; System call number for closing:
    mov rdi, [filename] ; File descriptor to close
    syscall

    ; Return line_cont
    mov eax, [line_cont]

    ret

; Procedure to allocate students
allocate_students:
    ; Initialize num_students
    mov dword [num_students], STUDENT_MAX_COUNT

    ; Allocate memory for students array
    mov rdi, [num_students]                       ; Number of students
    mov rax, 8                                    ; System call number for brk
    mov rdi, 0                                    ; Null argument
    syscall

    ; Check for errors in the brk syscall
    test rax, rax                                  ; Check if rax (allocated address) is zero
    jz error_handling                              ; Jump to error handling if zero

    ; Save the allocated memory address in Academy struct
    lea rdi, [Academy]
    mov qword [rdi + AcademyStudentsOffset], rax ; Save the address in Academy struct

    ; Set academy->size to 0
    mov dword [rdi + AcademySizeOffset], 0      ; Set size to 0

    ret

error_handling1:
    ; Print error message and exit
    mov rax, 1                                    ; syscall number for sys_write
    mov rdi, 2                                    ; file descriptor 2 (stderr)
    mov rsi, error_message1                       ; address of the error message
    mov rdx, error_message_len1                   ; length of the error message
    syscall

    mov eax, 60                                   ; syscall number for sys_exit
    xor edi, edi                                  ; exit code 0
    syscall

error_handling:
    ; Print error message and exit
    mov rax, 1                                    ; syscall number for sys_write
    mov rdi, 2                                    ; file descriptor 2 (stderr)
    mov rsi, error_message                        ; address of the error message
    mov rdx, error_message_len                    ; length of the error message
    syscall

    mov eax, 60                                   ; syscall number for sys_exit
    xor edi, edi                                  ; exit code 0
    syscall

section .data
    error_message db 'Error allocating memory for students', 0
    error_message_len equ $ - error_message

    error_message1 db 'Error allocating memory for students', 0
    error_message_len1 equ $ - error_message1

; Function to parse student record
parse_student:
    mov rax, [rsi] ; Assuming the first field is an integer (id)
    mov [rsi + StudentIdOffset], eax

    lea rsi, [rsi + StudentNameOffset]

    lea rsi, [rsi + StudentSurnameOffset]

    lea rsi, [rsi + StudentAgeOffset]

    lea rsi, [rsi + StudentGradeOffset]

    ret

; Function to add a student to the academy
add_student:
    ; Input: rdi - Pointer to the Academy structure

    ret
