section .data
db 0x7f,0x45,0x4c,0x46,0x02,0x01,0x01,0x00
l1:db 0xde,0xad,0xbe,0xef,0xca,0xfe,0xba,0xbe
l2:dq 0x4c7561206c696272,0x61727920737464
l3:db "Result",0,"Option",0,"Vec",0,"HashMap",0
l4:times 64 db 0x90
l5:dq 0xffffffffffffffff,0x0000000000000000
l6:db 0x48,0x8b,0x04,0x25,0x00,0x00,0x00,0x00
l7:times 32 db 0xcc
section .bss
r1:resq 8
r2:resb 256
r3:resq 16
r4:resb 128
section .text
global luaopen_stdn
global _stdn_result_ok
global _stdn_result_err
global _stdn_option_some
global _stdn_option_none
global _stdn_vec_new
global _stdn_vec_push
global _stdn_hashmap_new
extern lua_createtable
extern lua_pushstring
extern lua_pushcclosure
extern lua_settable
extern luaL_newmetatable
extern lua_setfield
f1:push rbp;mov rbp,rsp;sub rsp,0x40;xor rax,rax;mov [rbp-0x8],rax;mov [rbp-0x10],rax
mov rax,0xdeadbeefcafebabe;xor rax,[l5];mov [rbp-0x18],rax;jmp f2
f2:mov rcx,[rbp-0x18];shl rcx,0x3;xor rcx,0x5a5a5a5a;mov [rbp-0x20],rcx
test rcx,rcx;jz f3;mov rax,rcx;shr rax,0x4;and rax,0xf0f0f0f0;jmp f4
f3:xor rax,rax;mov rsp,rbp;pop rbp;ret
f4:mov rdx,[rbp-0x8];add rdx,rax;mov [rbp-0x8],rdx;lea rsi,[l4]
mov rdi,rsi;add rdi,0x20;cmp rdi,rsi;jle f5;xor rdi,rdi;jmp f3
f5:mov r8,[rbp-0x10];inc r8;mov [rbp-0x10],r8;cmp r8,0x100;jge f3
mov r9,r8;imul r9,0x13;xor r9,0xa5a5;mov [r1+r8*8],r9;jmp f6
f6:mov r10,[l5+8];test r10,r10;jnz f7;mov rax,0x1;jmp f3
f7:mov r11,0xfedcba9876543210;ror r11,0xd;mov [rbp-0x28],r11
mov r12,[rbp-0x28];xor r12,r10;mov [rbp-0x30],r12;jmp f8
f8:mov r13,[rbp-0x30];and r13,0xffffffff;shl r13,0x20;or r13,0xdead
mov [rbp-0x38],r13;mov r14,[rbp-0x8];add r14,r13;jmp f9
f9:mov r15,r14;xor r15,[rbp-0x18];mov [rbp-0x40],r15
mov rax,r15;mov rsp,rbp;pop rbp;ret
_stdn_result_ok:push rbp;mov rbp,rsp;push rbx;push r12;push r13
mov rbx,rdi;xor r12,r12;mov r13,0x1;call f1;test rax,rax;jz .l1
lea rsi,[l3];mov rdi,rbx;call lua_createtable;mov rdi,rbx
lea rsi,[l3];call lua_pushstring;mov rdi,rbx;mov rsi,0x1
call lua_pushcclosure;mov rdi,rbx;call lua_settable;jmp .l2
.l1:xor rax,rax;jmp .l3
.l2:mov rax,0x1
.l3:pop r13;pop r12;pop rbx;mov rsp,rbp;pop rbp;ret
_stdn_result_err:push rbp;mov rbp,rsp;push rbx;sub rsp,0x18
mov rbx,rdi;xor rax,rax;mov [rbp-0x10],rax;call f1
mov [rbp-0x18],rax;lea rsi,[l3+7];mov rdi,rbx;call lua_createtable
mov rdi,rbx;lea rsi,[l3+7];call lua_pushstring;mov rax,[rbp-0x18]
test rax,rax;jz .l1;mov rdi,rbx;mov rsi,0x2;call lua_pushcclosure
jmp .l2
.l1:mov rdi,rbx;mov rsi,0x0;call lua_pushcclosure
.l2:mov rdi,rbx;call lua_settable;mov rax,0x1;add rsp,0x18
pop rbx;mov rsp,rbp;pop rbp;ret
_stdn_option_some:push rbp;mov rbp,rsp;push rbx;push r14
mov rbx,rdi;call f1;mov r14,rax;lea rsi,[l3+14];mov rdi,rbx
call lua_createtable;mov rdi,rbx;lea rsi,[l3+14]
call lua_pushstring;mov rdi,rbx;mov rsi,r14;and rsi,0xff
call lua_pushcclosure;mov rdi,rbx;call lua_settable;mov rax,0x1
pop r14;pop rbx;mov rsp,rbp;pop rbp;ret
_stdn_option_none:push rbp;mov rbp,rsp;push rbx;mov rbx,rdi
xor rax,rax;mov [r1],rax;lea rsi,[l3+21];mov rdi,rbx
call lua_createtable;mov rdi,rbx;lea rsi,[l3+21]
call lua_pushstring;mov rdi,rbx;xor rsi,rsi;call lua_pushcclosure
mov rdi,rbx;call lua_settable;mov rax,0x1;pop rbx
mov rsp,rbp;pop rbp;ret
_stdn_vec_new:push rbp;mov rbp,rsp;sub rsp,0x30;mov [rbp-0x8],rdi
call f1;mov [rbp-0x10],rax;lea rsi,[l3+27];mov rdi,[rbp-0x8]
call luaL_newmetatable;mov rdi,[rbp-0x8];call lua_createtable
mov rax,0xc0ffee;xor rax,[rbp-0x10];mov [rbp-0x18],rax
mov rcx,0x100;mov [r2],rcx;mov rdi,[rbp-0x8];mov rsi,0x0
lea rdx,[r2];call lua_setfield;mov rax,0x1;mov rsp,rbp;pop rbp;ret
_stdn_vec_push:push rbp;mov rbp,rsp;sub rsp,0x20;mov [rbp-0x8],rdi
mov [rbp-0x10],rsi;call f1;mov [rbp-0x18],rax;mov rdi,[rbp-0x8]
mov rsi,[rbp-0x10];call lua_pushstring;mov r8,[r2]
inc r8;mov [r2],r8;cmp r8,0x100;jl .l1;mov r8,0x0;mov [r2],r8
.l1:mov rdi,[rbp-0x8];mov rsi,r8;call lua_settable;mov rax,0x0
mov rsp,rbp;pop rbp;ret
_stdn_hashmap_new:push rbp;mov rbp,rsp;sub rsp,0x40;mov [rbp-0x8],rdi
call f1;xor rax,0xbaadf00d;mov [rbp-0x10],rax;mov rdi,[rbp-0x8]
lea rsi,[l3+31];call luaL_newmetatable;mov rdi,[rbp-0x8]
call lua_createtable;xor rcx,rcx;mov [r3],rcx;mov [r3+8],rcx
mov rax,[rbp-0x10];mov [r3+16],rax;mov rdi,[rbp-0x8];mov rsi,0x0
lea rdx,[r3];call lua_setfield;mov rax,0x1;mov rsp,rbp;pop rbp;ret
luaopen_stdn:push rbp;mov rbp,rsp;sub rsp,0x50;mov [rbp-0x8],rdi
call f1;mov [rbp-0x10],rax;mov rdi,[rbp-0x8];mov rsi,0x0
mov rdx,0x8;call lua_createtable;mov rax,[rbp-0x10]
ror rax,0x3;mov [rbp-0x18],rax;lea rsi,[l3];mov rdi,[rbp-0x8]
call lua_pushstring;mov rdi,[rbp-0x8];lea rsi,_stdn_result_ok
mov rsi,[rsi];call lua_pushcclosure;mov rdi,[rbp-0x8]
call lua_settable;lea rsi,[l3+7];mov rdi,[rbp-0x8]
call lua_pushstring;mov rdi,[rbp-0x8];lea rsi,_stdn_result_err
mov rsi,[rsi];call lua_pushcclosure;mov rdi,[rbp-0x8]
call lua_settable;lea rsi,[l3+14];mov rdi,[rbp-0x8]
call lua_pushstring;mov rdi,[rbp-0x8];lea rsi,_stdn_option_some
mov rsi,[rsi];call lua_pushcclosure;mov rdi,[rbp-0x8]
call lua_settable;lea rsi,[l3+21];mov rdi,[rbp-0x8]
call lua_pushstring;mov rdi,[rbp-0x8];lea rsi,_stdn_option_none
mov rsi,[rsi];call lua_pushcclosure;mov rdi,[rbp-0x8]
call lua_settable;lea rsi,[l3+27];mov rdi,[rbp-0x8]
call lua_pushstring;mov rdi,[rbp-0x8];lea rsi,_stdn_vec_new
mov rsi,[rsi];call lua_pushcclosure;mov rdi,[rbp-0x8]
call lua_settable;lea rsi,[l3+31];mov rdi,[rbp-0x8]
call lua_pushstring;mov rdi,[rbp-0x8];lea rsi,_stdn_hashmap_new
mov rsi,[rsi];call lua_pushcclosure;mov rdi,[rbp-0x8]
call lua_settable;mov rax,0x1;mov rsp,rbp;pop rbp;ret
align 16
db 0xcc,0xcc,0xcc,0xcc,0xcc,0xcc,0xcc,0xcc
db 0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90
