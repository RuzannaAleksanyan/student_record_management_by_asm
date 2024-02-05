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
    target_id dd 0
    delete_id dd 0


    filename db 'your_filename.txt', 0  ; Replace 'your_filename.txt' with the actual file name or path

    header db 256 dup(0) ; Define a character array for the header

    line_cont dd 0  ; Declare line_cont variable


    records_loaded dd 0 ; Declare and initialize records_loaded variable

    menu_prompt db '1. Add a new student record', 10, '2. Display all records', 10, '3. Update a record', 10, '4. Delete a record', 10, '5. Exit', 10, 'Enter your choice: ', 0
    menu_prompt_size equ $-menu_prompt

    format_int db "%d", 0
    format_string db "%s", 0

    invalid_choice_message db 'Invalid choice. Please try again.', 10, 0
    invalid_choice_message_size equ $-invalid_choice_message

    goodbye_message db 'Goodbye! Thank you for using the program.', 10, 0
    goodbye_message_len equ $ - goodbye_message

    message_1 db 'Enter student information: ', 10, 'Name: ', 0
    message_1_size equ $-message_1

    message_2 db 'Surname: ', 0
    message_2_size equ $-message_2

    message_3 db 'Age: ', 0
    message_3_size equ $-message_3

    message_4 db 'Grade: ', 0
    message_4_size equ $-message_4

    message_5 db 'Enter the ID of the record to update: ', 0
    message_5_size equ $-message_5

    message_6 db 'Enter new student information: ', 10, 'Name: ', 0
    message_6_size equ $-message_6
    
    message_7 db 'We cannot remove it because there is no student.', 10
    message_7_size equ $-message_7

    delete_prompt db 'Enter the ID of the record to delete: ', 0
    delete_prompt_size equ $ - delete_prompt

    invalid_id_message db 'Invalid ID. Please enter a value between 0 and %d.', 10, 0
    invalid_id_message_size equ $ - invalid_id_message

    no_space_message db 'We cannot add a student due to lack of space', 0
    no_space_message_size equ $ - no_space_message

section .bss
    new_student resb StudentSize  ; Allocate space for a new Student struct

section .text
    global  main

    extern printf                  ; External declaration for printf function
    extern scanf                   ; External declaration for scanf function
    extern strcpy

    extern add_student
    extern read_records

    extern allocate_students

    extern load_from_file


main:
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
    mov rdx, menu_prompt_size   ; length of the string
    syscall

    ; Read user choice
    lea rdi, [format_int]
    lea rsi, [choice]
    jmp read_int

l1:    ; Process user choice
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
    je exit

    ; If the choice is within the valid range, jump back to the menu loop
    jmp menu_loop

add_student_option:
    mov rax, 1
    mov rdi, 1
    mov rsi, message_1            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_1_size   ; length of the string
    syscall

    ; Read and display student name
    mov rax, 0          ; syscall number for sys_read
    mov rdi, format_string         ; file descriptor 0 (stdin)
    lea rsi, [new_student + StudentNameOffset]  ; pointer to the buffer for student name
    mov rdx, 50         ; maximum number of characters to read (adjust as needed)
    call scanf

    mov rax, 1
    mov rdi, 1
    mov rsi, message_2            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_2_size   ; length of the string
    syscall

    ; Read and display student surname
    mov rax, 0          ; syscall number for sys_read
    mov rdi, format_string         ; file descriptor 0 (stdin)
    lea rsi, [new_student + StudentSurnameOffset]  ; pointer to the buffer for student name
    mov rdx, 50         ; maximum number of characters to read (adjust as needed)
    call scanf

    mov rax, 1
    mov rdi, 1
    mov rsi, message_3            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_3_size   ; length of the string
    syscall

    ; Example: Read and display age
    mov rax, 0
    mov rdi, format_int
    lea rsi, [new_student + StudentAgeOffset]
    call scanf

    mov rax, 1
    mov rdi, 1
    mov rsi, message_4            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_4_size   ; length of the string
    syscall

    ; Example: Read and display grade
    mov rax, 0
    mov rdi, format_int
    lea rsi, [new_student + StudentGradeOffset]
    call scanf

    mov eax, [ID]
    inc eax
    mov dword [new_student + StudentIdOffset], eax
    mov dword [ID], eax
    
    ; Call add_student function
    mov rdi, Academy
    mov rsi, new_student
    ; call add_student

    jmp menu_loop

display_records_option:
    lea rdi, [Academy]
    ; call read_records

    jmp menu_loop

update_record_option:
    mov rax, 1
    mov rdi, 1
    mov rsi, message_5            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_5_size   ; length of the string
    syscall

    ; Read and display student name
    mov rax, 0          ; syscall number for sys_read
    mov rdi, format_int        ; file descriptor 0 (stdin)
    lea rsi, [target_id]  ; pointer to the buffer for student name
    mov rdx, 50         ; maximum number of characters to read (adjust as needed)
    call scanf

    mov rax, 1
    mov rdi, 1
    mov rsi, message_6            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_6_size   ; length of the string
    syscall

    ; Read and display student name
    mov rax, 0          ; syscall number for sys_read
    mov rdi, format_string         ; file descriptor 0 (stdin)
    lea rsi, [new_student + StudentNameOffset]  ; pointer to the buffer for student name
    mov rdx, 50         ; maximum number of characters to read (adjust as needed)
    call scanf

    mov rax, 1
    mov rdi, 1
    mov rsi, message_2            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_2_size   ; length of the string
    syscall

    mov rax, 0          ; syscall number for sys_read
    mov rdi, format_string         ; file descriptor 0 (stdin)
    lea rsi, [new_student + StudentSurnameOffset]  ; pointer to the buffer for student name
    mov rdx, 50         ; maximum number of characters to read (adjust as needed)
    call scanf

    mov rax, 1
    mov rdi, 1
    mov rsi, message_3            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_3_size   ; length of the string
    syscall

    ; Example: Read and display age
    mov rax, 0
    mov rdi, format_int
    lea rsi, [new_student + StudentAgeOffset]
    call scanf

    mov rax, 1
    mov rdi, 1
    mov rsi, message_4            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_4_size   ; length of the string
    syscall

    ; Example: Read and display grade
    mov rax, 0
    mov rdi, format_int
    lea rsi, [new_student + StudentGradeOffset]
    call scanf

    ; new_student.id = target_id;
    mov eax, [target_id]
    mov dword [new_student + StudentIdOffset], eax

    ; Call update_record(academy, &new_student);
    mov rdi, Academy
    mov rsi, new_student
    ; call update_record
    
    jmp menu_loop

delete_record_option:
    ; Check if academy->size <= 0
    mov rdi, Academy            ; Pointer to Academy structure
    mov eax, [rdi + AcademySizeOffset]  ; Load size field
    cmp eax, 0                  ; Compare size with 0
    jle size_less_than_or_equal_zero ; Jump if less than or equal to zero    

    ; Print prompt for entering the ID of the record to delete
    mov rax, 1                   ; syscall number for sys_write
    mov rdi, 1                   ; file descriptor 1 (stdout)
    lea rsi, [delete_prompt]     ; pointer to the string
    mov rdx, delete_prompt_size  ; length of the string
    syscall

    ; Read the ID of the record to delete
    mov rax, 0                   ; syscall number for sys_read
    mov rdi, format_int          ; file descriptor 0 (stdin)
    lea rsi, [delete_id]         ; pointer to the variable to store the read integer
    call scanf

    ; Validate the entered ID
    mov ecx, [rdi + AcademySizeOffset] ; Load academy->size
    cmp dword [delete_id], 0                  ; Check if delete_id < 0
    jl invalid_id_prompt                ; Jump if less than 0
    cmp [delete_id], ecx                ; Check if delete_id >= academy->size
    jge invalid_id_prompt               ; Jump if greater than or equal to academy->size

    ; call delete_record(academy, delete_id)  ; Call delete_record function
    jmp end_delete_process              ; Jump to the end of the process

invalid_id_prompt:
    ; Print invalid ID message
    mov rax, 1                   ; syscall number for sys_write
    mov rdi, 1                   ; file descriptor 1 (stdout)
    lea rsi, [invalid_id_message] ; pointer to the string
    mov rdx, invalid_id_message_size ; length of the string
    syscall

    ; Repeat the process until a valid ID is entered
    jmp size_less_than_or_equal_zero

end_delete_process:
    ; call delete_record

size_less_than_or_equal_zero:
    mov rax, 1
    mov rdi, 1
    mov rsi, message_7            ; pointer to the string   ; length (0xFFFFFFFF means print until null terminator)
    mov rdx, message_7_size   ; length of the string
    syscall

    jmp menu_loop

invalid_choice:
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_choice_message     ; pointer to the string
    mov rdx, invalid_choice_message_size   ; length of the string
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
     ret

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

read_int:
    mov rax, 0          ; syscall number for sys_read
    mov rdi, format_int          ; file descriptor 0 (stdin)
    mov  rsi, choice   ; pointer to the variable to store the read integer
    call scanf
    jmp l1

exit:
    lea rdi, [Academy]
    ; call write_in_file
    mov rax, 0
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
    mov eax, [rsi] ; Assuming the first field is an integer (id)
    mov [rsi + StudentIdOffset], eax

    lea rsi, [rsi + StudentNameOffset]
    lea rsi, [rsi + StudentSurnameOffset]
    lea rsi, [rsi + StudentAgeOffset]
    lea rsi, [rsi + StudentGradeOffset]

    ret

; Function to add a student to the academy
add_student:
    mov eax, [rdi + AcademySizeOffset] ; Load size field
    mov rbx, [rsi + StudentIdOffset]   ; Load student->id

    ; Calculate the offset for the new student
    mov r8, rax                          ; Copy academy->size to r8
    imul r8, r8, StudentSize             ; Calculate offset by multiplying size with StudentSize
    add r8, [rdi + AcademyStudentsOffset] ; Add the base address of academy->students
    add r8, StudentIdOffset              ; Add the offset of StudentIdOffset

    ; Set academy->students[academy->size].id = student->id
    mov [r8], ebx

    cmp eax, STUDENT_MAX_COUNT       ; Compare with STUDENT_MAX_COUNT
    je no_space_available           ; Jump if equal

    ; Increase academy->size
    inc dword [rdi + AcademySizeOffset]

    ; Assuming the student and academy structures are defined similarly as in your original code

    ; Copy student->name to academy->students[academy->size].name
    mov rsi, [rsi + StudentNameOffset]         ; Load student->name address
    mov rdi, [rdi + AcademyStudentsOffset]     ; Load base address of academy->students
    mov rdx, [rdi + AcademySizeOffset]         ; Load academy->size
    mov rax, StudentSize                        ; Load size of Student structure
    imul rdx, rdx, rax                         ; Calculate offset by multiplying size with StudentSize
    add rdi, rdx                               ; Add the offset to the base address
    mov rdx, 50                                ; Maximum number of characters to copy
    call strcpy                                ; Call a strcpy-like function

    ; Copy student->surname to academy->students[academy->size].surname
    mov rsi, [rsi + StudentSurnameOffset]     ; Load student->surname address
    mov rdi, [rdi + AcademyStudentsOffset]    ; Load base address of academy->students
    mov rdx, [rdi + AcademySizeOffset]        ; Load academy->size
    mov rax, StudentSize                       ; Load size of Student structure
    imul rdx, rdx, rax                         ; Calculate offset by multiplying size with StudentSize
    add rdi, rdx                               ; Add the offset to the base address
    mov rdx, 50                                ; Maximum number of characters to copy
    call strcpy                                ; Call a strcpy-like function

    ; Copy student->age to academy->students[academy->size].age
    mov rsi, [rsi + StudentAgeOffset]         ; Load student->age
    mov rdi, [rdi + AcademyStudentsOffset]    ; Load base address of academy->students
    mov rdx, [rdi + AcademySizeOffset]        ; Load academy->size
    mov rax, StudentSize                       ; Load size of Student structure
    ; imul rdx, rax, rdx                         ; Calculate offset by multiplying size with StudentSize
    mul rdx, rax
    add rdi, rdx                               ; Add the offset to the base address
    mov [rdi + StudentAgeOffset], rsi         ; Copy student->age to academy->students[academy->size].age

    ; Copy student->grade to academy->students[academy->size].grade
    mov rsi, [rsi + StudentGradeOffset]       ; Load student->grade
    mov rdi, [rdi + AcademyStudentsOffset]    ; Load base address of academy->students
    mov rdx, [rdi + AcademySizeOffset]        ; Load academy->size
    mov rax, StudentSize                       ; Load size of Student structure
    imul rdx, rdx, rax                         ; Calculate offset by multiplying size with StudentSize
    add rdi, rdx                               ; Add the offset to the base address
    mov [rdi + StudentGradeOffset], rsi       ; Copy student->grade to academy->students[academy->size].grade

    ; Increment academy->size
    inc dword [rdi + AcademySizeOffset]        ; Increment academy->size

    jmp l2

no_space_available:
    ; Print error message for lack of space
    mov rax, 1                       ; syscall number for sys_write
    mov rdi, 1                       ; file descriptor 1 (stdout)
    lea rsi, [no_space_message]      ; pointer to the string
    mov rdx, no_space_message_size   ; length of the string
    syscall
l2:    
    ret


read_records:
    
    ret
