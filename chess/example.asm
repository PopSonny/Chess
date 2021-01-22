.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf:proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Sah",0
area_width EQU 640
area_height EQU 480
area DD 0
matrice_tabla   DB 'T','L','N','Q','K','N','L','T'
				DB 'P','P','P','P','P','P','P','P'
				DB ' ',' ',' ',' ',' ',' ',' ',' '
				DB ' ',' ',' ',' ',' ',' ',' ',' '
				DB ' ',' ',' ',' ',' ',' ',' ',' '
				DB ' ',' ',' ',' ',' ',' ',' ',' '
				DB 'Z','Z','Z','Z','Z','Z','Z','Z'
				DB 'W','Y','X','V','U','X','Y','W' 
lungime equ $-matrice_tabla ;aflarea nr de elemente din x
counter DD 0 ; numara evenimentele de tip timer

variabila_mutare_caracter DD 0
variabila_litera_curenta DD 0
variabila_litera_necurenta DD 0
variabila_cord_x DD 0
variabila_cord_y DD 0

contor_clicks DD 0

indice_spatiu DD 0

variabila_de_mutare_piesa DD 0

ajutor db "%d",13,10,0

afisare db "%d %d %d %d",13,10,0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
num1 dd 0
casuta EQU 50
coloare EQU 0CA6F1Eh
coloare2 EQU 0F0B27Ah
arg5 db 8
arg6 db 50
arg7 db 10
arg8 db 2

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

include pion_alb.inc
include pion_negru.inc
include cal_alb.inc
include cal_negru.inc
include nebun_alb.inc
include nebun_negru.inc
include tura_alba.inc
include tura_neagra.inc
include regina_alba.inc
include regina_neagra.inc
include rege_alb.inc
include rege_negru.inc

coordonata_click1_x DD 0
coordonata_click1_y DD 0
coordonata_click2_x DD 0
coordonata_click2_y DD 0

coordonata_highlight1 DD 0
coordonata_highlight2 DD 0

i1 DB 0
i2 DB 0
j1 DB 0
j2 DB 0

i1_spatiu DB 0
j1_spatiu DB 0

indice1 DD 0
indice2 DD 0
indice_mutare DB 0

repornire DD 0

tabla_x EQU 50
tabla_y EQU 50
tabla_range EQU 400

variabila_salvatoare db 0

indicele_ptr_rege DD 0

variabila_apasat_buton DD 0

randultau DD 0
alba_neagra DD 0
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh ; aici trebe inlocuit culoare bg
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

verifica_rege macro indice
local final,mat
mov EDX,indice
cmp byte ptr matrice_tabla[EDX],'K'
je mat
cmp byte ptr matrice_tabla[EDX],'U'
je mat
jmp final
mat:
sah_mat

final:

endm

highlight macro x1,y1


; pushad
; mov EDX,x1
; mov ECX,y1
; mov coordonata_highlight1,EDX
; mov coordonata_highlight2,ECX
; highlight coordonata_highlight1,coordonata_highlight2
; popad

linie_x x1+10,y1,100,029E117h
linie_x x1+30,y1,10,029E117h

linie_y x1,y1+10,100,029E117h
linie_y x1,y1+30,100,029E117h

endm 

buton_restart macro i,j
local final
mov EDX,i
mov ECX,j

cmp EDX,500
jl final
cmp EDX,570
jg final
cmp ECX,430
jl final
cmp ECX,450
jg final

make_text_macro ' ' ,area,500,380
make_text_macro ' ' ,area,510,380
make_text_macro ' ' ,area,520,380
make_text_macro ' ' ,area,540,380
make_text_macro ' ' ,area,550,380
make_text_macro ' ' ,area,560,380

mov matrice_tabla(0),'T'
mov matrice_tabla(1),'L'
mov matrice_tabla(2),'N'
mov matrice_tabla(3),'Q'
mov matrice_tabla(4),'K'
mov matrice_tabla(5),'N'
mov matrice_tabla(6),'L'
mov matrice_tabla(7),'T'

mov matrice_tabla(8),'P'
mov matrice_tabla(9),'P'
mov matrice_tabla(10),'P'
mov matrice_tabla(11),'P'
mov matrice_tabla(12),'P'
mov matrice_tabla(13),'P'
mov matrice_tabla(14),'P'
mov matrice_tabla(15),'P'

mov matrice_tabla(16),' '
mov matrice_tabla(17),' '
mov matrice_tabla(18),' '
mov matrice_tabla(19),' '
mov matrice_tabla(20),' '
mov matrice_tabla(21),' '
mov matrice_tabla(22),' '
mov matrice_tabla(23),' '

mov matrice_tabla(24),' '
mov matrice_tabla(25),' '
mov matrice_tabla(26),' '
mov matrice_tabla(27),' '
mov matrice_tabla(28),' '
mov matrice_tabla(29),' '
mov matrice_tabla(30),' '
mov matrice_tabla(31),' '

mov matrice_tabla(32),' '
mov matrice_tabla(33),' '
mov matrice_tabla(34),' '
mov matrice_tabla(35),' '
mov matrice_tabla(36),' '
mov matrice_tabla(37),' '
mov matrice_tabla(38),' '
mov matrice_tabla(39),' '

mov matrice_tabla(40),' '
mov matrice_tabla(41),' '
mov matrice_tabla(42),' '
mov matrice_tabla(43),' '
mov matrice_tabla(44),' '
mov matrice_tabla(45),' '
mov matrice_tabla(46),' '
mov matrice_tabla(47),' '

mov matrice_tabla(48),'Z'
mov matrice_tabla(49),'Z'
mov matrice_tabla(50),'Z'
mov matrice_tabla(51),'Z'
mov matrice_tabla(52),'Z'
mov matrice_tabla(53),'Z'
mov matrice_tabla(54),'Z'
mov matrice_tabla(55),'Z'

mov matrice_tabla(56),'W'
mov matrice_tabla(57),'Y'
mov matrice_tabla(58),'X'
mov matrice_tabla(59),'V'
mov matrice_tabla(60),'U'
mov matrice_tabla(61),'X'
mov matrice_tabla(62),'Y'
mov matrice_tabla(63),'W'

make_text_macro ' ' ,area,500,350
make_text_macro ' ' ,area,510,350
make_text_macro ' ' ,area,520,350
make_text_macro ' ' ,area,530,350
make_text_macro ' ' ,area,540,350
make_text_macro ' ' ,area,550,350
make_text_macro ' ' ,area,560,350
make_text_macro ' ' ,area,570,350
make_text_macro ' ' ,area,580,350
make_text_macro ' ' ,area,590,350

mov repornire,0

mov randultau,0
mov variabila_apasat_buton,1


final:
endm

play_again macro 

make_text_macro 'R', area, 500,430
make_text_macro 'E', area, 510,430
make_text_macro 'S', area, 520,430
make_text_macro 'J', area, 530,430
make_text_macro 'A', area, 540,430
make_text_macro 'R', area, 550,430
make_text_macro 'J', area, 560,430
linie_x 500,430,70,00066ffh
linie_x 500,450,70,00066ffh
linie_y 499,430,20,00066ffh
linie_y 570,430,20,00066ffh

endm

sah_mat macro

make_text_macro 'S' ,area,500,380
make_text_macro 'A' ,area,510,380
make_text_macro 'H' ,area,520,380
make_text_macro 'M' ,area,540,380
make_text_macro 'A' ,area,550,380
make_text_macro 'J' ,area,560,380
mov repornire,1

endm

albul_muta macro

make_text_macro 'A' ,area,500,350
make_text_macro 'I' ,area,510,350
make_text_macro 'B' ,area,520,350
make_text_macro ' ' ,area,530,350
make_text_macro 'M' ,area,540,350
make_text_macro 'O' ,area,550,350
make_text_macro 'J' ,area,560,350
make_text_macro 'A' ,area,570,350
make_text_macro ' ' ,area,580,350
make_text_macro ' ' ,area,590,350

endm

negrul_muta macro
make_text_macro '0' ,area,500,350
make_text_macro 'E' ,area,510,350
make_text_macro 'G' ,area,520,350
make_text_macro 'R' ,area,530,350
make_text_macro 'O' ,area,540,350
make_text_macro ' ' ,area,550,350
make_text_macro 'M' ,area,560,350
make_text_macro 'O' ,area,570,350
make_text_macro 'J' ,area,580,350
make_text_macro 'A' ,area,590,350

endm
; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

piesa_alba macro indice1
local alba,neagra,spatiu,final

mov EDX,indice1

cmp byte ptr matrice_tabla[EDX],'P'
je alba
cmp byte ptr matrice_tabla[EDX],'Q'
je alba
cmp byte ptr matrice_tabla[EDX],'K'
je alba
cmp byte ptr matrice_tabla[EDX],'L'
je alba
cmp byte ptr matrice_tabla[EDX],'T'
je alba
cmp byte ptr matrice_tabla[EDX],'N'
je alba

cmp byte ptr matrice_tabla[EDX],'V'
je neagra
cmp byte ptr matrice_tabla[EDX],'U'
je neagra
cmp byte ptr matrice_tabla[EDX],'X'
je neagra
cmp byte ptr matrice_tabla[EDX],'Y'
je neagra
cmp byte ptr matrice_tabla[EDX],'W'
je neagra
cmp byte ptr matrice_tabla[EDX],'Z'
je neagra

cmp byte ptr matrice_tabla[EDX],' '
je spatiu

alba:
mov alba_neagra,0
jmp final

neagra:
mov alba_neagra,1
jmp final


spatiu:
mov alba_neagra,2
jmp final

final:

endm

mutare_pion macro click1,click2,i,ptr_regina
local negru,mutare_buna,final_pion,atac,conditie_speciala_alb,conditie_speciala_negru
local next,next_negru,regina1,regina2,regina_alba_schimbare
mov EDX,0
mov EBX,0
mov EDX,click1
mov EBX,click2
cmp byte ptr matrice_tabla[EDX],'P'
jne negru

mov EAX,0
mov EAX,click1
add EAX,8
cmp EAX,EBX
je mutare_buna

pushad
mov ECX,EBX
sub EBX,EDX
cmp EBX,16
je conditie_speciala_alb
popad

mov ECX,click1


add ECX,8
add ECX,1

cmp ECX,click2
jne next
cmp byte ptr matrice_tabla[ECX],'Z'
je atac
cmp byte ptr matrice_tabla[ECX],'X'
je atac
cmp byte ptr matrice_tabla[ECX],'Y'
je atac
cmp byte ptr matrice_tabla[ECX],'W'
je atac
cmp byte ptr matrice_tabla[ECX],'V'
je atac
cmp byte ptr matrice_tabla[ECX],'U'
je atac



next:
sub ECX,2
cmp ECX,click2
jne final_pion
cmp byte ptr matrice_tabla[ECX],'Z'
je atac
cmp byte ptr matrice_tabla[ECX],'X'
je atac
cmp byte ptr matrice_tabla[ECX],'Y'
je atac
cmp byte ptr matrice_tabla[ECX],'W'
je atac
cmp byte ptr matrice_tabla[ECX],'V'
je atac
cmp byte ptr matrice_tabla[ECX],'U'
je atac

jmp final_pion

atac:
inc randultau
pushad
verifica_rege indicele_ptr_rege
popad
mov CL,byte ptr matrice_tabla[edx]
mov byte ptr matrice_tabla[ebx], CL
mov byte ptr matrice_tabla[edx],' '



mov al,ptr_regina
cmp al,7
je regina_alba_schimbare
cmp al,0
jne final_pion
mov byte ptr matrice_tabla[EBX],'V'
jmp final_pion

regina_alba_schimbare:
mov byte ptr matrice_tabla[EBX],'Q'
jmp final_pion

negru:
mov EAX,click1
sub EAX,8
cmp EAX,click2
je mutare_buna

pushad
mov ECX,EDX
sub EDX,EBX
cmp EDX,16
je conditie_speciala_negru
popad


mov ECX,EAX
inc ECX
cmp ECX,indice2
jne next_negru
cmp byte ptr matrice_tabla[ECX],'T'
je atac
cmp byte ptr matrice_tabla[ECX],'K'
je atac
cmp byte ptr matrice_tabla[ECX],'Q'
je atac
cmp byte ptr matrice_tabla[ECX],'P'
je atac
cmp byte ptr matrice_tabla[ECX],'L'
je atac
cmp byte ptr matrice_tabla[ECX],'N'
je atac
next_negru:
sub ECX,2
cmp ECX,indice2
jne final_pion
cmp byte ptr matrice_tabla[ECX],'T'
je atac
cmp byte ptr matrice_tabla[ECX],'K'
je atac
cmp byte ptr matrice_tabla[ECX],'Q'
je atac
cmp byte ptr matrice_tabla[ECX],'P'
je atac
cmp byte ptr matrice_tabla[ECX],'L'
je atac
cmp byte ptr matrice_tabla[ECX],'N'
je atac


jmp final_pion

mutare_buna:
inc randultau
mov CL,byte ptr matrice_tabla[ebx]
cmp CL,' '
jne final_pion
pushad
verifica_rege indicele_ptr_rege
popad
mov CL,byte ptr matrice_tabla[edx]
mov byte ptr matrice_tabla[ebx], CL
mov byte ptr matrice_tabla[edx],' '
mov al,ptr_regina
cmp al,0
jne final_pion
mov byte ptr matrice_tabla[EBX],'Q'


jmp final_pion

conditie_speciala_alb:
cmp i,1
jne final_pion
mov EBX,ECX
mov ECX,EDX
add ECX,8
mov AL,byte ptr matrice_tabla[ecx]
cmp AL,' '
jne final_pion
mov CL,byte ptr matrice_tabla[ebx]
cmp CL,' '
jne final_pion
mov CL,byte ptr matrice_tabla[edx]
mov byte ptr matrice_tabla[ebx], CL
mov byte ptr matrice_tabla[edx],' '
inc randultau
jmp final_pion

conditie_speciala_negru:
cmp i,6
jne final_pion
mov EDX,ECX
mov ECX,EBX
add ECX,8
mov AL,byte ptr matrice_tabla[ecx]
cmp AL,' '
jne final_pion
mov CL,byte ptr matrice_tabla[ebx]
cmp CL,' '
jne final_pion
mov CL,byte ptr matrice_tabla[edx]
mov byte ptr matrice_tabla[ebx], CL
mov byte ptr matrice_tabla[edx],' '
inc randultau
jne final_pion


jmp final_pion

final_pion:

endm

mutare_rege macro indice1,indice2
local negru,miscare,final_mutare,mutare,miscare_negru

mov EDX,indice1
mov EBX,indice2

mov EAX,EDX
cmp byte ptr matrice_tabla[EDX],'K'
jne negru
add EAX,8
cmp EAX,indice2
je miscare
add EAX,1
cmp EAX,indice2
je miscare
sub EAX,8
cmp EAX,indice2
je miscare
sub EAX,8
cmp EAX,indice2
je miscare
dec EAX
cmp EAX,indice2
je miscare
dec EAX
cmp EAX,indice2
je miscare
add EAX,8
cmp EAX,indice2
je miscare
add EAX,8
cmp EAX,indice2
je miscare
jmp final_mutare


miscare:
cmp byte ptr matrice_tabla[EBX],'Z'
je mutare
cmp byte ptr matrice_tabla[EBX],'Y'
je mutare
cmp byte ptr matrice_tabla[EBX],'X'
je mutare
cmp byte ptr matrice_tabla[EBX],'W'
je mutare
cmp byte ptr matrice_tabla[EBX],'V'
je mutare
cmp byte ptr matrice_tabla[EBX],'U'
je mutare
cmp byte ptr matrice_tabla[EBX],' '
je mutare
jmp final_mutare

mutare:
pushad
verifica_rege indicele_ptr_rege
popad
mov CL,byte ptr matrice_tabla[EDX]
mov byte ptr matrice_tabla[EBX],CL
mov byte ptr matrice_tabla[EDX],' '
inc randultau
jmp final_mutare

negru:

mov EDX,indice1
mov EBX,indice2
mov EAX,EDX

add EAX,8
cmp EAX,indice2
je miscare_negru
add EAX,1
cmp EAX,indice2
je miscare_negru
sub EAX,8
cmp EAX,indice2
je miscare_negru
sub EAX,8
cmp EAX,indice2
je miscare_negru
dec EAX
cmp EAX,indice2
je miscare_negru
dec EAX
cmp EAX,indice2
je miscare_negru
add EAX,8
cmp EAX,indice2
je miscare_negru
add EAX,8
cmp EAX,indice2
je miscare_negru
jmp final_mutare

miscare_negru:
cmp byte ptr matrice_tabla[EBX],'P'
je mutare
cmp byte ptr matrice_tabla[EBX],'K'
je mutare
cmp byte ptr matrice_tabla[EBX],'Q'
je mutare
cmp byte ptr matrice_tabla[EBX],'L'
je mutare
cmp byte ptr matrice_tabla[EBX],'N'
je mutare
cmp byte ptr matrice_tabla[EBX],'T'
je mutare
cmp byte ptr matrice_tabla[EBX],' '
je mutare
jmp final_mutare

final_mutare:

endm 

mutare_cal macro indice1,indice2
local negru,miscare,mutare,final_mutare,miscare_negru
mov EDX,indice1
mov EBX,indice2

cmp byte ptr matrice_tabla[EDX],'L'
jne negru
mov EAX,EDX
add EAX,16
inc EAX
cmp EAX,indice2
je miscare
inc EAX
sub EAX,8
cmp EAX,indice2
je miscare
sub EAX,16
cmp EAX,indice2
je miscare
sub EAX,8
dec EAX
cmp EAX,indice2
je miscare
sub EAX,2
cmp EAX,indice2
je miscare
dec EAX
add EAX,8
cmp EAX,indice2
je miscare
add EAX,16
cmp EAX,indice2
je miscare
add EAX,8
inc EAX
cmp EAX,indice2
je miscare
jmp final_mutare

miscare:

cmp byte ptr matrice_tabla[EBX],'Z'
je mutare
cmp byte ptr matrice_tabla[EBX],'Y'
je mutare
cmp byte ptr matrice_tabla[EBX],'X'
je mutare
cmp byte ptr matrice_tabla[EBX],'W'
je mutare
cmp byte ptr matrice_tabla[EBX],'V'
je mutare
cmp byte ptr matrice_tabla[EBX],'U'
je mutare
cmp byte ptr matrice_tabla[EBX],' '
je mutare
jmp final_mutare

mutare:
inc randultau
pushad
verifica_rege indicele_ptr_rege
popad
mov CL,byte ptr matrice_tabla[EDX]
mov byte ptr matrice_tabla[EBX],CL
mov byte ptr matrice_tabla[EDX],' '
jmp final_mutare

negru:
mov EDX,indice1
mov EBX,indice2

mov EAX,EDX

add EAX,16
inc EAX
cmp EAX,indice2
je miscare_negru
inc EAX
sub EAX,8
cmp EAX,indice2
je miscare_negru
sub EAX,16
cmp EAX,indice2
je miscare_negru
sub EAX,8
dec EAX
cmp EAX,indice2
je miscare_negru
sub EAX,2
cmp EAX,indice2
je miscare_negru
dec EAX
add EAX,8
cmp EAX,indice2
je miscare_negru
add EAX,16
cmp EAX,indice2
je miscare_negru
add EAX,8
inc EAX
cmp EAX,indice2
je miscare_negru
jmp final_mutare

miscare_negru:

cmp byte ptr matrice_tabla[EBX],'P'
je mutare
cmp byte ptr matrice_tabla[EBX],'Q'
je mutare
cmp byte ptr matrice_tabla[EBX],'K'
je mutare
cmp byte ptr matrice_tabla[EBX],'L'
je mutare
cmp byte ptr matrice_tabla[EBX],'T'
je mutare
cmp byte ptr matrice_tabla[EBX],'N'
je mutare
cmp byte ptr matrice_tabla[EBX],' '
je mutare
jmp final_mutare


final_mutare:
endm

mutare_tura macro indice1,indice2,i1,j1,i2,j2
local verificare_1,final_mutare,negru,verificare_2,verificare_3,linie_diferita
local miscare,a_mai_mic,loop_1,loop_2,loop_3,loop_4,coloana_diferita
local a_mai_mic1
mov AL,i1
mov BL,i2
mov DL,j1
mov CL,j2
cmp AL,BL
je verificare_1
cmp DL,CL
je verificare_1
jmp final_mutare

verificare_1:
mov EDX,indice1
mov EBX,indice2
cmp byte ptr matrice_tabla[EDX],'T'
jne negru
jmp verificare_2

verificare_2:
mov EDX,indice1
mov EBX,indice2

cmp byte ptr matrice_tabla[EBX],' '
je verificare_3
cmp byte ptr matrice_tabla[EBX],'Z'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'Y'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'X'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'W'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'V'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'U'
je verificare_3
jmp final_mutare

negru:

mov EDX,indice1
mov EBX,indice2
cmp byte ptr matrice_tabla[EBX],' '
je verificare_3
cmp byte ptr matrice_tabla[EBX],'P'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'K'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'Q'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'L'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'T'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'N'
je verificare_3
jmp final_mutare

verificare_3:
;jmp miscare
mov al,i1
mov bl,i2
cmp al,bl
jne linie_diferita
mov al,j1
mov bl,j2
cmp al,bl
jne coloana_diferita
jmp final_mutare

linie_diferita:
cmp al,bl
jl a_mai_mic
sub al,bl
mov ECX,0
mov cl,al
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je miscare
loop_2:
sub EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_2
jmp miscare


a_mai_mic:
sub bl,al
mov ECX,0
mov cl,bl
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je miscare
pushad
push ECX
push offset ajutor
call printf
add ESP,8
popad
loop_1:
add EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_1
jmp miscare

coloana_diferita:

cmp al,bl
jl a_mai_mic1
sub al,bl
mov ECX,0
mov cl,al
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je miscare
loop_3:
sub EDX,1
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_3
jmp miscare


a_mai_mic1:
sub bl,al
mov ECX,0
mov cl,bl
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je miscare
loop_4:
add EDX,1
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_4
jmp miscare

jmp final_mutare
miscare:
inc randultau
mov EDX,indice1
mov EBX,indice2
pushad
verifica_rege indicele_ptr_rege
popad
mov CL,byte ptr matrice_tabla[EDX]
mov byte ptr matrice_tabla[EBX],CL
mov byte ptr matrice_tabla[EDX],' '
jmp final_mutare

final_mutare:

endm

mutare_nebun macro indice1,indice2,i1,j1,i2,j2
local final_mutare,negru,verificare,caz1,caz2,caz3,caz4
local i1_mai_mare,j1_mai_mare,j2_mai_mare,d1_mai_mare
local loop_1,loop_2,loop_3,loop_4,mutare,d1_mai_mare_caz_2
mov EDX,indice1
mov EBX,indice2
cmp byte ptr matrice_tabla[EDX],'N'
jne negru

cmp byte ptr matrice_tabla[EBX],' '
je verificare
cmp byte ptr matrice_tabla[EBX],'U'
je verificare
cmp byte ptr matrice_tabla[EBX],'V'
je verificare
cmp byte ptr matrice_tabla[EBX],'X'
je verificare
cmp byte ptr matrice_tabla[EBX],'Y'
je verificare
cmp byte ptr matrice_tabla[EBX],'Z'
je verificare
cmp byte ptr matrice_tabla[EBX],'W'
je verificare
jmp final_mutare

negru:

cmp byte ptr matrice_tabla[EBX],' '
je verificare
cmp byte ptr matrice_tabla[EBX],'P'
je verificare
cmp byte ptr matrice_tabla[EBX],'K'
je verificare
cmp byte ptr matrice_tabla[EBX],'Q'
je verificare
cmp byte ptr matrice_tabla[EBX],'L'
je verificare
cmp byte ptr matrice_tabla[EBX],'N'
je verificare
cmp byte ptr matrice_tabla[EBX],'T'
je verificare
jmp final_mutare

verificare:
mov al,i1
mov bl,i2
mov dl,j1
mov cl,j2
cmp al,bl
je final_mutare
cmp dl,cl
je final_mutare
cmp al,bl
jg i1_mai_mare
;i1 mai mic
cmp dl,cl
jg d1_mai_mare
;j1 mai mic

;caz dreapta jos
;i1 mai mic, j1 mai mic

pushad
sub bl,al
sub cl,dl
cmp bl,cl
jne final_mutare
popad


sub bl,al
mov ECX,0
mov cl,bl
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_1:
inc EDX
add EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_1
jmp mutare

d1_mai_mare:
;caz stanga jos
;i1 mai mic j1 mai mare

pushad
sub bl,al
sub dl,cl
cmp bl,dl
jne final_mutare
popad

sub bl,al
mov ECX,0
mov cl,bl
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_2:
dec EDX
add EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_2
jmp mutare

i1_mai_mare:
;i1 mai mare
mov al,i1
mov bl,i2
mov dl,j1
mov cl,j2

cmp dl,cl
jg d1_mai_mare_caz_2
;caz dreapta sus
;i1 mai mare j2 mai mare

pushad
sub al,bl
sub cl,dl
cmp al,cl
jne final_mutare
popad

sub cl,dl
mov al,cl
mov ECX,0
mov cl,al
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_3:
inc EDX
sub EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_3
jmp mutare

d1_mai_mare_caz_2:
;caz stanga sus
;i1 mai mare j1 mai mare

pushad
sub al,bl
sub dl,cl
cmp al,dl
jne final_mutare
popad

sub al,bl
mov ECX,0
mov cl,al
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_4:
dec EDX
sub EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_4
jmp mutare

jmp final_mutare

mutare:
inc randultau
mov EDX,indice1
mov EBX,indice2
pushad
verifica_rege indicele_ptr_rege
popad
mov CL,byte ptr matrice_tabla[EDX]
mov byte ptr matrice_tabla[EBX],CL
mov byte ptr matrice_tabla[EDX],' '
jmp final_mutare

final_mutare:

endm

mutare_regina macro indice1,indice2,i1,j1,i2,j2
local final_mutare,negru,verificare,caz1,caz2,caz3,caz4
local i1_mai_mare,j1_mai_mare,j2_mai_mare,d1_mai_mare
local loop_1,loop_2,loop_3,loop_4,mutare,d1_mai_mare_caz_2,regina_ca_tura
local linie_diferita,coloana_diferita,loop_1_t,loop_2_t,loop_3_t,loop_4_t
local a_mai_mic,a_mai_mic1,negru_tura
mov EDX,indice1
mov EBX,indice2
cmp byte ptr matrice_tabla[EDX],'Q'
jne negru

cmp byte ptr matrice_tabla[EBX],' '
je verificare
cmp byte ptr matrice_tabla[EBX],'U'
je verificare
cmp byte ptr matrice_tabla[EBX],'V'
je verificare
cmp byte ptr matrice_tabla[EBX],'X'
je verificare
cmp byte ptr matrice_tabla[EBX],'Y'
je verificare
cmp byte ptr matrice_tabla[EBX],'Z'
je verificare
cmp byte ptr matrice_tabla[EBX],'W'
je verificare
jmp final_mutare

negru:

cmp byte ptr matrice_tabla[EBX],' '
je verificare
cmp byte ptr matrice_tabla[EBX],'P'
je verificare
cmp byte ptr matrice_tabla[EBX],'K'
je verificare
cmp byte ptr matrice_tabla[EBX],'Q'
je verificare
cmp byte ptr matrice_tabla[EBX],'L'
je verificare
cmp byte ptr matrice_tabla[EBX],'N'
je verificare
cmp byte ptr matrice_tabla[EBX],'T'
je verificare
jmp final_mutare

verificare:
mov al,i1
mov bl,i2
mov dl,j1
mov cl,j2
cmp al,bl
je regina_ca_tura
cmp dl,cl
je regina_ca_tura
cmp al,bl
jg i1_mai_mare
;i1 mai mic
cmp dl,cl
jg d1_mai_mare
;j1 mai mic

;caz dreapta jos
;i1 mai mic, j1 mai mic

pushad
sub bl,al
sub cl,dl
cmp bl,cl
jne final_mutare
popad

sub bl,al
mov ECX,0
mov cl,bl
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_1:
inc EDX
add EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_1
jmp mutare

d1_mai_mare:
;caz stanga jos
;i1 mai mic j1 mai mare

pushad
sub bl,al
sub dl,cl
cmp bl,dl
jne final_mutare
popad

sub bl,al
mov ECX,0
mov cl,bl
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_2:
dec EDX
add EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_2
jmp mutare

i1_mai_mare:
;i1 mai mare
mov al,i1
mov bl,i2
mov dl,j1
mov cl,j2

cmp dl,cl
jg d1_mai_mare_caz_2
;caz dreapta sus
;i1 mai mare j2 mai mare

pushad
sub al,bl
sub cl,dl
cmp al,cl
jne final_mutare
popad


sub cl,dl
mov al,cl
mov ECX,0
mov cl,al
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_3:
inc EDX
sub EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_3
jmp mutare

d1_mai_mare_caz_2:
;caz stanga sus
;i1 mai mare j1 mai mare

pushad
sub al,bl
sub dl,cl
cmp al,dl
jne final_mutare
popad


sub al,bl
mov ECX,0
mov cl,al
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_4:
dec EDX
sub EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_4
jmp mutare

regina_ca_tura:


mov EDX,indice1
mov EBX,indice2
cmp byte ptr matrice_tabla[EDX],'Q'
jne negru_tura
jmp verificare_2

verificare_2:
mov EDX,indice1
mov EBX,indice2

cmp byte ptr matrice_tabla[EBX],' '
je verificare_3
cmp byte ptr matrice_tabla[EBX],'Z'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'Y'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'X'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'W'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'V'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'U'
je verificare_3
jmp final_mutare

negru_tura:

mov EDX,indice1
mov EBX,indice2
cmp byte ptr matrice_tabla[EBX],' '
je verificare_3
cmp byte ptr matrice_tabla[EBX],'P'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'K'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'Q'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'L'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'T'
je verificare_3
cmp byte ptr matrice_tabla[EBX],'N'
je verificare_3
jmp final_mutare

verificare_3:
mov al,i1
mov bl,i2
cmp al,bl
jne linie_diferita
mov al,j1
mov bl,j2
cmp al,bl
jne coloana_diferita
jmp final_mutare

linie_diferita:
cmp al,bl
jl a_mai_mic
sub al,bl
mov ECX,0
mov cl,al
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_2_t:
sub EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_2_t
jmp mutare


a_mai_mic:
sub bl,al
mov ECX,0
mov cl,bl
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_1_t:
add EDX,8
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_1_t
jmp mutare

coloana_diferita:

cmp al,bl
jl a_mai_mic1
sub al,bl
mov ECX,0
mov cl,al
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_3_t:
sub EDX,1
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_3_t
jmp mutare


a_mai_mic1:
sub bl,al
mov ECX,0
mov cl,bl
mov EDX,indice1
mov EBX,indice2
dec ECX
cmp ECX,0
je mutare
loop_4_t:
add EDX,1
cmp byte ptr matrice_tabla[EDX],' '
jne final_mutare
loop loop_4_t
jmp mutare


jmp final_mutare


mutare:
inc randultau
mov EDX,indice1
mov EBX,indice2
pushad
verifica_rege indicele_ptr_rege
popad
mov CL,byte ptr matrice_tabla[EDX]
mov byte ptr matrice_tabla[EBX],CL
mov byte ptr matrice_tabla[EDX],' '
jmp final_mutare

final_mutare:


endm

mutare_piese macro x1,y1,x2,y2,matrice_tabla
local final_mutare,mutare_p,mutare_k,mutare_c,mutare_t,mutare_n
local mutare_r,piesa_alba_gasita,piesa_neagra_gasita,continua,continua_alb,continua_negru
local minus,final_mare_2,final_mutare_2,negru_rand,final_mare_3

mov eax,x1
div arg6
mov j1,AL
mov eax,x2
div arg6
mov j2,AL
mov eax,y1
div arg6
mov i1,AL
mov eax,y2
div arg6
mov i2,AL
dec i1
dec i2
dec j1
dec j2

mov eax,0
mov al,i1
mov indice_mutare,al
mul arg5
add al,j1

mov indice1,eax

mov eax,0
mov al,i2
mul arg5
add al,j2

mov indice2,eax
mov EBX,indice1
mov EDX,indice2
pushad
cmp EBX,EDX
je final_mutare
popad


mov indicele_ptr_rege,EDX 

cmp repornire,1
je final_mutare

;verificare daca este piesa alba
;variabila alba_neagra este 0 cand este alb,1 negru si 2 spatiu
pushad
piesa_alba indice1
popad

cmp alba_neagra,2
je final_mutare

cmp alba_neagra,0
jne neagra_piesa

mov EAX,randultau
div arg8
cmp AH,0
je continua_alb
jmp final_mutare

neagra_piesa:
cmp alba_neagra,1
jne final_mutare
mov EAX,randultau
div arg8
cmp AH,1
je continua_negru
jmp final_mutare

continua_alb:
negrul_muta

jmp continua
continua_negru:
albul_muta

continua:

; pushad
; mov EAX,randultau
; push EAX
; push offset ajutor
; call printf
; add ESP,8
; popad

mov EDX,indice1
mov CL,byte ptr matrice_tabla[EDX]
mov variabila_salvatoare,cl

cmp byte ptr matrice_tabla[EBX],'P'
je mutare_p
cmp byte ptr matrice_tabla[EBX],'Z'
je mutare_p

cmp byte ptr matrice_tabla[EBX],'K'
je mutare_k
cmp byte ptr matrice_tabla[EBX],'U'
je mutare_k

cmp byte ptr matrice_tabla[EBX],'L'
je mutare_c
cmp byte ptr matrice_tabla[EBX],'Y'
je mutare_c

cmp byte ptr matrice_tabla[EBX],'T'
je mutare_t
cmp byte ptr matrice_tabla[EBX],'W'
je mutare_t

cmp byte ptr matrice_tabla[EBX],'N'
je mutare_n
cmp byte ptr matrice_tabla[EBX],'X'
je mutare_n

cmp byte ptr matrice_tabla[EBX],'Q'
je mutare_r
cmp byte ptr matrice_tabla[EBX],'V'
je mutare_r

jmp final_mutare

mutare_p:
pushad
mutare_pion indice1,indice2,indice_mutare,i2
popad
jmp final_mutare

mutare_k:
pushad
mutare_rege indice1,indice2
popad
jmp final_mutare

mutare_c:
pushad
mutare_cal indice1,indice2
popad
jmp final_mutare

mutare_t:
pushad
mutare_tura indice1,indice2,i1,j1,i2,j2
popad
jmp final_mutare

mutare_n:
pushad
mutare_nebun indice1,indice2,i1,j1,i2,j2
popad
jmp final_mutare

mutare_r:
pushad
mutare_regina indice1,indice2,i1,j1,i2,j2
popad
jmp final_mutare


final_mutare:

pushad
mov EAX,randultau
div arg8
cmp ah,1
je negru_rand
popad
albul_muta
jmp final_mare_3
negru_rand:
popad
negrul_muta

final_mare_3:
;printf("%d%d%d%d",i1,j1,i2,j2);
; mov EAX,0
; mov EBX,0
; mov ECX,0
; mov EDX,0
; mov AL,j2
; mov BL,i2
; mov CL,j1
; mov DL,i1

; push EAX
; push EBX
; push ECX
; push EDX
; push offset afisare
; call printf
; add ESP,20
endm

alfabet_parti macro

make_text_macro '8',area,30,65
make_text_macro '7',area,30,115
make_text_macro '6',area,30,165
make_text_macro '5',area,30,215
make_text_macro '4',area,30,265
make_text_macro '3',area,30,315
make_text_macro '2',area,30,365
make_text_macro '1',area,30,415

make_text_macro '8',area,460,65
make_text_macro '7',area,460,115
make_text_macro '6',area,460,165
make_text_macro '5',area,460,215
make_text_macro '4',area,460,265
make_text_macro '3',area,460,315
make_text_macro '2',area,460,365
make_text_macro '1',area,460,415

make_text_macro 'A',area,70,25
make_text_macro 'B',area,120,25
make_text_macro 'C',area,170,25
make_text_macro 'D',area,220,25
make_text_macro 'E',area,270,25
make_text_macro 'F',area,320,25
make_text_macro 'G',area,370,25
make_text_macro 'H',area,420,25

make_text_macro 'A',area,70,455
make_text_macro 'B',area,120,455
make_text_macro 'C',area,170,455
make_text_macro 'D',area,220,455
make_text_macro 'E',area,270,455
make_text_macro 'F',area,320,455
make_text_macro 'G',area,370,455
make_text_macro 'H',area,420,455

endm 

piese_sah macro matrice_tabla
local compararea,final_mare,alb_pion,negru_pion,alb_cal,negru_cal,alb_nebun,negru_nebun
local alb_tura,negru_tura,alb_regina,negru_regina,alb_rege,negru_rege,draw_final
local bucla_linii,bucla_coloane,simbol_pixel_alb1,simbol_pixel_next1
push ebp
mov ebp, esp
pusha
mov edx,63
mov eax, [ebp+arg1]
compararea:
cmp edx,-1
je final_mare
dec edx
mov variabila_de_mutare_piesa,edx
cmp matrice_tabla(variabila_de_mutare_piesa),'P'
je alb_pion
cmp matrice_tabla(variabila_de_mutare_piesa),'p'
je negru_pion
cmp matrice_tabla(variabila_de_mutare_piesa),'C'
je alb_cal
cmp matrice_tabla(variabila_de_mutare_piesa),'c'
je negru_cal
cmp matrice_tabla(variabila_de_mutare_piesa),'N'
je alb_nebun
cmp matrice_tabla(variabila_de_mutare_piesa),'n'
je negru_nebun
cmp matrice_tabla(variabila_de_mutare_piesa),'T'
je alb_tura
cmp matrice_tabla(variabila_de_mutare_piesa),'t'
je negru_tura
cmp matrice_tabla(variabila_de_mutare_piesa),'Q'
je alb_regina
cmp matrice_tabla(variabila_de_mutare_piesa),'q'
je negru_regina
cmp matrice_tabla(variabila_de_mutare_piesa),'K'
je alb_rege
cmp matrice_tabla(variabila_de_mutare_piesa),'k'
je negru_rege

alb_pion:
lea esi, pion_a
jmp draw_final
negru_pion:
lea esi, pion_n
jmp draw_final

alb_cal:
lea esi, cal_a
jmp draw_final
negru_cal:
lea esi, cal_n
jmp draw_final

alb_nebun:
lea esi, neb_a
jmp draw_final
negru_nebun:
lea esi, neb_n
jmp draw_final

alb_regina:
lea esi, regi_a
jmp draw_final
negru_regina:
lea esi, regi_n
jmp draw_final

alb_rege:
lea esi, rege_a
jmp draw_final
negru_rege:
lea esi, rege_n
jmp draw_final

alb_tura:
lea esi, tura_a
jmp draw_final
negru_tura:
lea esi, tura_n
jmp draw_final


draw_final:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb1
	mov dword ptr [edi], 0
	jmp simbol_pixel_next1
simbol_pixel_alb1:
	mov dword ptr [edi], 0FFFFFFh ; aici trebe inlocuit culoare bg
simbol_pixel_next1:
	inc esi
	add edi, 4
	loop bucla_coloane
	pop ecx
	loop bucla_linii
	popa
	mov esp, ebp
	pop ebp

jmp compararea
final_mare:

endm

piese_sah_call macro symbol, drawArea, x, y,matrice_tabla
	push y
	push x
	push drawArea
	push symbol
	pushad
	piese_sah matrice_tabla
	popad
	add esp, 16
endm

linie_x macro x,y,len,color
local bucla_l,sar_3
	mov eax, y 
	mov ebx,area_width
	mul ebx
	add eax, x
	shl eax,2
	add eax,area
		mov ecx,len
		mov edx,0000000h
		bucla_l :
		cmp edx,dword ptr[eax]
		je sar_3
		mov dword ptr[eax],color
		sar_3:
		add eax,4
		loop bucla_l
endm

colorare_inauntru macro x,y,lungime,color
local bucla_mare
mov ecx,lungime
mov eax,y
bucla_mare:
pushad
linie_x x,eax,lungime,color
popad
inc eax
loop bucla_mare
endm

linie_y macro x,y,len,color
local bucla_v
mov eax,y
mov ebx,area_width
mul ebx
add eax,x
shl eax,2
add eax,area
mov ecx,len
bucla_v:
mov dword ptr[eax],color
mov ebx,eax
mov eax,area_width
shl eax,2
add ebx,eax
mov eax,ebx
loop bucla_v
endm

colorare_tabla_mare macro x
local loop_mic,loop_mare,final_colorare,loop_mare2,loop_mic1,sar1,sar2,sari_colorare_tabla
mov eax,x
cmp eax,1
je sari_colorare_tabla
	;esi counter while, edi ptr x , edx ptr y
	mov esi,8
	mov edi,50
	loop_mic1:
	mov ecx,4
	mov edx,50
	test esi,1; 0-par, 1  impar
	jz sar1
	mov edx,100
	sar1:
	loop_mare:
	pushad
	colorare_inauntru edi,edx,casuta,coloare
	popad
	add edx,100
	loop loop_mare
	add edi,50
	dec esi
	cmp esi,0
	jne loop_mic1
	jmp final_colorare
	sari_colorare_tabla	:
	mov esi,8
	mov edi,50
	loop_mic:
	mov ecx,4
	mov edx,50
	test esi,1; 0-par, 1  impar
	jnz sar2
	mov edx,100
	sar2:
	loop_mare2:
	pushad
	colorare_inauntru edi,edx,casuta,coloare2
	popad
	add edx,100
	loop loop_mare2
	add edi,50
	dec esi
	cmp esi,0
	jne loop_mic
	final_colorare:
	endm

asezare_matrice macro matrice_tabla
local 	loop_matrice
	lea esi,matrice_tabla
	mov ecx,64
	loop_matrice :
	mov eax, 0
	lodsb ;mov al,[esi]
	;inc esi
	mov variabila_litera_curenta,eax
	mov ebx,esi
	lea edx,matrice_tabla
	sub ebx,edx; in bl avem pozitia din vectorul mare
    sub ebx,1	
	mov edx,0
	mov dl,al
	mov variabila_mutare_caracter,edx
	mov eax,ebx
	div arg5 ;coloanele adica j in ah si in al este i
	mov ebx,0
	mov bl,ah
	inc eax
	mul arg6
	add eax,15
	mov variabila_cord_x,eax
	inc ebx
	mov eax,ebx
	mul arg6
	add eax,20
	mov variabila_cord_y,eax
	pushad
	make_text_macro variabila_mutare_caracter,area,variabila_cord_y,variabila_cord_x
	popad
	
	;mov al ,[esi]
	;add esi,1
	loop loop_matrice
	endm
	
asezare_linimar_matrice macro
	make_text_macro 'S', area, 530, 70
	make_text_macro 'A', area, 540, 70
	make_text_macro 'H', area, 550, 70
	make_text_macro 'S', area, 520, 100
	make_text_macro 'C', area, 530, 100
	make_text_macro '9', area, 540, 100
	make_text_macro 'R', area, 550, 100
	make_text_macro 'E', area, 560, 100
	
	make_text_macro 'K', area, 510, 150
	make_text_macro 'Q', area, 510, 180
	make_text_macro 'T', area, 510, 210
	make_text_macro 'N', area, 510, 240
	make_text_macro 'L', area, 510, 270
	make_text_macro 'P', area, 510, 300
	
	make_text_macro 'G', area, 540 ,150
	make_text_macro 'G', area, 550 ,150
	make_text_macro '8', area, 540 ,180
	make_text_macro '5', area, 540 ,210
	make_text_macro '3', area, 540 ,240
	make_text_macro '3', area, 540 ,270
	make_text_macro '1', area, 540 ,300
	
	
	linie_x tabla_x,tabla_y,tabla_range,0
	linie_x tabla_x,tabla_y+tabla_range,tabla_range,0
	linie_y tabla_x,tabla_y,tabla_range,0
	linie_y tabla_x+tabla_range,tabla_y,tabla_range,0
	
	linie_x tabla_x,tabla_y+50*1,tabla_range,0
	linie_x tabla_x,tabla_y+50*2,tabla_range,0
	linie_x tabla_x,tabla_y+50*3,tabla_range,0
	linie_x tabla_x,tabla_y+50*4,tabla_range,0
	linie_x tabla_x,tabla_y+50*5,tabla_range,0
	linie_x tabla_x,tabla_y+50*6,tabla_range,0
	linie_x tabla_x,tabla_y+50*7,tabla_range,0
	linie_x tabla_x,tabla_y+50*8,tabla_range,0
	linie_y tabla_x+50*1,tabla_y,tabla_range,0
	linie_y tabla_x+50*2,tabla_y,tabla_range,0
	linie_y tabla_x+50*3,tabla_y,tabla_range,0
	linie_y tabla_x+50*4,tabla_y,tabla_range,0
	linie_y tabla_x+50*5,tabla_y,tabla_range,0
	linie_y tabla_x+50*6,tabla_y,tabla_range,0
	linie_y tabla_x+50*7,tabla_y,tabla_range,0
	linie_y tabla_x+50*8,tabla_y,tabla_range,0
	
	endm
	
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	cmp contor_clicks,2
	je mutare_player
	cmp contor_clicks,1
	je al_doilea_click
	mov edx, [ebp+arg2]
	mov coordonata_click1_x,edx
	mov edx, [ebp+arg3]
	mov coordonata_click1_y,edx
	
	pushad
	mov eax,coordonata_click1_x
	div arg6
	mov j1_spatiu,AL
	mov eax,coordonata_click1_y
	div arg6
	mov i1_spatiu,AL
	dec i1_spatiu
	dec j1_spatiu

	mov eax,0
	mov al,i1_spatiu
	mov indice_mutare,al
	mul arg5
	add al,j1_spatiu
	mov indice_spatiu,eax
	
	cmp byte ptr matrice_tabla[EAX],' '
	je afisare_litere
	
	popad
	
	;aici buton ptr restart
	mov variabila_apasat_buton,0
	pushad
	buton_restart coordonata_click1_x,coordonata_click1_y
	popad
	cmp variabila_apasat_buton,1
	je afisare_litere
	
	inc contor_clicks
	jmp afisare_litere
	
	al_doilea_click:
	mov edx, [ebp+arg2]
	mov coordonata_click2_x,edx
	mov edx, [ebp+arg3]
	mov coordonata_click2_y,edx
	inc contor_clicks
	jmp mutare_player
	
	mutare_player:
	;afisam coordonatele in pixeli
	; mov edx,coordonata_click1_x
	; push edx
	; push offset ajutor
	; call printf
	; add ESP,8
	; mov edx,coordonata_click1_y
	; push edx
	; push offset ajutor
	; call printf
	; add ESP,8
	
	; mov edx,coordonata_click2_x
	; push edx
	; push offset ajutor
	; call printf
	; add ESP,8
	
	; mov edx,coordonata_click2_y
	; push edx
	; push offset ajutor
	; call printf
	; add ESP,8
	
	;mutarea playerului
	pushad
	mutare_piese coordonata_click1_x,coordonata_click1_y,coordonata_click2_x,coordonata_click2_y,matrice_tabla
	popad
	mov contor_clicks,0
	jmp afisare_litere 
	
evt_timer:
	inc counter
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	;make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	;make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	;make_text_macro edx, area, 10, 10
	
	asezare_linimar_matrice
	
	asezare_matrice matrice_tabla
	
	colorare_tabla_mare 1
	colorare_tabla_mare 0

	alfabet_parti
	play_again
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
