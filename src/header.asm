BITS 16

start:

	;The bootloader has initalized ax to our memory location
    mov ds, ax
    mov es, ax

	add ax, 288
    mov ss, ax
    mov sp, 4096

	;invoke _main
	invoke _io_print_string, welcome_string

	welcome_string db 'Welcome to ReactiveOS 0.0.1!', 13, 10, 0

_io_print_string:
    push bp
    push si
    push ax

    mov bp, sp
    mov si, [bp+8]

    mov ah, 0Eh

.repeat
    lodsb
    cmp al, 0
    je .done
    int 10h
    jmp .repeat

.done
    pop ax
    pop si
    pop bp
    ret 2
