        .data
txt_espaco:     .asciiz " "
txt_linha:      .asciiz "\n"
txt_menu:       .asciiz "\nMenu\n1 Inserir\n2 Remover\n3 Buscar\n4 Ordenar\n5 Exibir\n6 Sair\nOpcao: "
txt_insere:     .asciiz "\nValor a inserir: "
txt_buscar:     .asciiz "\nValor a buscar: "
txt_existe:     .asciiz "\nO elemento existe!\n"
txt_nao_existe: .asciiz "\nO elemento nao existe!\n"
txt_vazia:      .asciiz "\nLista vazia!\n"
txt_remover:    .asciiz "\nElemento a remover: "
txt_debug:      .asciiz "\nDebug\n"
        .text
main:
        li   $s0, 0     #s0 aponta para o inicio da lista, inicialmente NULL
        li   $s1, 10
        li   $s2, 40
        li   $s3, 4
        li   $s4, 19
menu:    
        la   $a0, txt_menu
        li   $v0, 4
        syscall
        li   $v0, 5
        syscall
        li   $t0, 1
        beq  $v0, $t0, inserir
        li   $t0, 2
        beq  $v0, $t0, remover
        li   $t0, 3
        beq  $v0, $t0, buscar
        li   $t0, 4
        beq  $v0, $t0, ordenar
        li   $t0, 5
        beq  $v0, $t0, print

        #se nao foi nenhuma dessas opcoes, sai do programa
        li   $v0, 10
        syscall
#FIM DO MENU

inserir:        
        li   $v0, 4
        la   $a0, txt_insere
        syscall         #print txt_insere
        li   $v0, 5
        syscall         #le valor a inserir
        move $t0, $v0   #t0 eh o valor a inserir
        beqz $s0, inserir_primeiro #se a lista eh vazia, insere o primeiro elemento

        #se nao, insere sempre no final da lista
        move $t1, $s0   #t1 eh o valor atual

        #t1 tem que apontar para o elemento cujo proximo elemento eh NULL
ins_loop_beg:   
        lw   $t2, 8 ($t1) #t2 aponta para t1->prox
        beqz $t2, ins_loop_end #se t1->prox == NULL, sai do loop

        move $t1, $t2   #se nao, t1 = t1->prox
        j    ins_loop_beg
ins_loop_end:   
        #agora, $t1 aponta para o ultimo elemento

        li   $a0, 12
        li   $v0, 9
        syscall         #alocar memoria para o novo elemento

        #v0 aponta para novo elemento

        sw   $v0, 8 ($t1) #t1->prox = v0
        sw   $t0, 0 ($v0) #valor do novo elemento eh t0
        sw   $t1, 4 ($v0) #v0->ant = $t1
        sw   $zero, 8 ($v0) #v0->prox = NULL

        j    menu

inserir_primeiro:       
        li   $a0, 12
        li   $v0, 9
        syscall         #aloca 12 bytes de memoria
        move $s0, $v0   #s0 aponta para o comeco da lista, que nao eh mais NULL
        sw   $t0, 0 ($s0) #primeiros 4 bytes armazenam o valor
        sw   $zero, 4 ($s0) #segundos  4 bytes apontam para o anterior
        sw   $zero, 8 ($s0) #terceiros 4 bytes apontam para o proximo
        j    menu

#FIM DA INSERCAO


print:
        la   $a0, txt_linha
        li   $v0, 4
        syscall         #print "\n"

        beqz $s0, print_vazia #se comeco da lista eh NULL

        #se nao, printa os elementos
        move $t1, $s0   #t1 aponta para o comeco da lista
prt_loop_beg: 
        beqz $t1, prt_loop_end #se o elemento atual for NULL, termina de printar
        lw   $a0, 0 ($t1)
        li   $v0, 1
        syscall          #print t1 (elemento atual)

        la   $a0, txt_espaco
        li   $v0, 4
        syscall         #print " "

        lw   $t1, 8 ($t1) #t1 = t1->next
        j    prt_loop_beg
prt_loop_end:   
        la   $a0, txt_linha
        li   $v0, 4
        syscall         #print "\n"

        j    menu

print_vazia:
        la   $a0, txt_vazia
        li   $v0, 4
        syscall         #print txt_vazia
        j    menu

#FIM DO PRINT


remover:
        la   $a0, txt_remover
        li   $v0, 4
        syscall         #print txt_remover

        li   $v0, 5
        syscall

        #v0 eh o elemento a ser removido

        move $t1, $s0 #t1 aponta para o elemento atual
        #t1 tem que parar no elemento a ser removido

rm_loop_beg:
        beqz $t1, menu  #caso nao exista o elemento a ser removido, volta pro menu
        lw   $t0, 0 ($t1) #t0 eh o valor do elemento atual
        beq  $t0, $v0, rm_loop_end #se encontrou o valor a remover, sai do loop
        lw   $t1, 8 ($t1) #t1 = t1->next
        j    rm_loop_beg
rm_loop_end:   
        #agora, o proximo do anterior tem que ser o proximo do atual
        #e o anterior do proximo tem que ser o anterior do atual

        bne  $s0, $t1, nao_primeiro   #se o elemento a ser removido eh o primeiro
        lw   $s0, 8 ($t1) #tem que atualizar s0 como t1->prox
nao_primeiro:

        lw   $t2, 4 ($t1) #t2 aponta para o anterior
        lw   $t3, 8 ($t1) #t3 aponta para o proximo


        #fazer reaponteirametno

        #if t1->prev != NULL:
        #    t1->prev->next = t1->next
        beqz $t2, prev_null
        sw   $t3, 8 ($t2)
prev_null:      

        #if t1->next != NULL:
        #    t1->next->prev = t1->prev
        beqz $t3, next_null
        sw   $t2, 4 ($t3)
next_null:      

        j    menu

        
#FIM DA REMOCAO

buscar:
        la   $a0, txt_buscar
        li   $v0, 4
        syscall         #print txt_buscar

        li   $v0, 5
        syscall         #v0 eh o valor a buscar
        
        beqz $s0, buscar_nao_encontrou #se a lista eh vazia nao encontra elemento

        move $t1, $s0 #t1 aponta para o elemento atual
buscar_loop_beg:        
        beqz $t1, buscar_nao_encontrou #se elemento atual eh NULL, nao encontrou
        lw   $t0, 0 ($t1) #t0 eh o valor do elemento atual
        beq  $t0, $v0, buscar_encontrou #se valor do elemento atual = valor a buscar, encontrou
        lw   $t1, 8 ($t1) #t1 = t1->next
        j    buscar_loop_beg
buscar_encontrou:
        li   $v0, 4
        la   $a0, txt_existe
        syscall         #print txt_existe
        j    menu
buscar_nao_encontrou:   
        li   $v0, 4
        la   $a0, txt_nao_existe
        syscall         #print txt_nao_existe
        j    menu
#FIM DA BUSCA        

ordenar:

        beqz $s0, menu #voce nao precisa ordenar se voce nao tem uma lista

        #t0 eh valor do elemento atual
        #t1 eh ponteiro p/ elemento atual
        #t2 eh o maior valor
        #t3 eh o tamanho da lista
        #t4 eh o n
        #t5 aponta para o vetor do radix
        #t6 eh o contador
        #t7 digito atual
        #t9 eh usado quando tem que fazer slt e outras coias
        #s1 = 10
        #s2 = 40
        #s3 = 4

        move $t1, $s0 #t1 esta apontando para o inicio da lista
        lw   $t2, 0 ($s0) #t2 (max) eh o primeiro valor inicialmente
        move $t3, $zero #t3 (tamanho_lista) eh inicialmente zero


ord_loop0_beg:          #loop para encontrar o valor maximo e o tamanho da lista
        beqz $t1, ord_loop0_end #se o elemento atual eh NULL, sai do loop
        lw   $t0, 0 ($t1)
        addi $t3, $t3, 1  #tamanho_lista++
        lw   $t1, 8 ($t1) #t1 = t1->next #prepara t1 para a proxima iteracao

        slt  $t9, $t2, $t0 #se max < elemento_atual, t9 = 1, senao t9 = 0
        
        #t9 vai ser 1 quando tem que atualizar max
        beqz $t9, ord_loop0_beg #se nao tem que atualizar max vai para o comeco do loop
        move $t2, $t0 #atualiza max como elemento_atual
        
        j    ord_loop0_beg
ord_loop0_end:

        li   $v0, 9
        move $a0, $t3
        syscall
        move $t5, $v0

        li   $t4, 1 #inicialmente n = 1

ord_loop_beg:
        slt  $t9, $t2, $t4 #se maior_valor < n : sai do loop
        bnez $t9, ord_loop_end

        move $t7, $zero

	move $t6, $t5 #t6 = endereco da primeira posicao do vetor radix

ord_d_beg:	#este loop roda 19 vezes para testar cada digito positivo e negativo
        beq  $t7, $s4, ord_d_end

        
        move $t1, $s0 #t1 = primeiro elemento da lista

ord_loop1_beg:
        beqz $t1, ord_loop1_end #se chegou no final da lista sai do loop
        lw   $t0, 0 ($t1) #t0 = t1->val

        #t8 = enesimo digito do numero
        #t8 = (t0 / n) % 10 + 9
        div  $t0, $t4
        mflo $t8 #t8 = t0 * t4
        div  $t8, $s1
        mfhi $t8 #t8 %= 10
        addi $t8, $t8, 9 #t8 += 9

        bne  $t8, $t7, nao_digito_atual
        #entra aqui se for o digito atual
        #entao tem que colocar no vetor do radix

        
        sw   $t0, 0 ($t6)

        addi $t6, $t6, 4  #vai para o proximo indice do vetor radix

nao_digito_atual:

        lw   $t1, 8 ($t1) #t1 = t1->next
        
        j    ord_loop1_beg
ord_loop1_end:

        addi $t7, $t7, 1
        j    ord_d_beg

ord_d_end:

	move $t1, $s0 #inicializa o t1 como o primeiro elemento da lista
	move $t6, $t5 #o "contador" recebe a posicao de memoria do vetor do radix
ord_loop2_beg:	#loop que passa de volta para a lista
	beqz $t1, ord_loop2_end #se chegou no fim da lista sai do loop

		
	lw   $t0, 0 ($t6)
	sw   $t0  0 ($t1)
	
	lw   $t1, 8 ($t1) #t1 = t1->next
	addi $t6, $t6, 4
	j    ord_loop2_beg
ord_loop2_end:

        #n *= 10
        mult $t4, $s1
        mflo $t4
        j    ord_loop_beg
ord_loop_end:


        j    menu
