org 0x7C00
bits 16


%define ENDL 0x0D, 0x0A
;
; FAT12 header
; 
jmp strict short start
nop


bdb_oem : db "MSWIN4.1"
bdb_bytes_per_sector : dw 512
bdb_sectors_per_cluster : db 1
bdb_reserved_sectors : dw 1
bdb_fat_count: db 2
bdb_dir_entries_count: db 0E0h
bdb_total_sectors : dw 2880
bdb_media_descriptor_type : db 0F0h
bdb_sectors_per_fat : dw 9
bdb_sectors_per_track : dw 18
bdb_heads_per_cylinder : dw 2
bdb_hidden_sectors : dd 0
bdb_total_sectors_large : dd 0


; extended boot record
ebr_drive_number : db 0
                 db 0
ebr_signature: db 29h
ebr_volume_id : dd 12h, 34h, 56h, 78h
ebr_volume_label: db ' Haard OS '
ebr_system_id : db ' FAT12  '                
start:
    jmp main


;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret
    

main:
    ; setup data segments
    mov ax, 0           ; can't set ds/es directly
    mov ds, ax
    mov es, ax
    
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00      ; stack grows downwards from where we are loaded in memory

    ; print hello world message
    mov si, msg_hello
    call puts

    hlt

.halt:
    jmp .halt



msg_hello: db 'Hello world!', ENDL, 0


times 510-($-$$) db 0
dw 0AA55h