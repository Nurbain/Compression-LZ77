.data
str1 :  .asciiz "Nom du fichier ? :"	

filename: .byte 0:30 					# nom du fichier	
filenamecopy : .byte 0:30				# nom du fichier de sortie

decompressedtext: .byte 0:10000			# buffer de sortie
buffer : .byte 0:10000					# buffer d'entree

extension : .asciiz "txt"				# extension du fichier de sortie


.text
.globl __start



__start:
		
la $a0,str1 							# Demande nom du fichier
li $v0,4
syscall

li $v0,8 								# Lecture du nom du fichier
la $a0, filename 						# Stockage dans filename
li $a1, 30								# Longueur chaine
move $t0,$a0
syscall


li $s0,0 								
Remove: 								# permet d'enlever le "\n" du nom de fichier 
    lb $a3,filename($s0)    
    addi $s0,$s0,1      	
    bnez $a3,Remove     
    subiu $s0,$s0,2     
    sb $0, filename($s0) 


##################################
#Permet de créer le nom de sortie#
##################################

li $s0,46
li $a3,0
CopieBase:								# recupere la base du nom de fichier
	beq $s0 $s1 FinCopieBase
	lb $s1, filename($a3)
	sb $s1, filenamecopy($a3)
	addi $a3,$a3,1
jal CopieBase

FinCopieBase:

li $s0,0
li $s2,0
addi $s0,$a3,4
AjoutExtension:							# ajoute l'extension .lz77
	bgt $a3 $s0 FinAjout
		lb $s1, extension($s2)			# data source 
		sb $s1, filenamecopy($a3)		# ajout a la fin de filenamecopy
		addi $a3,$a3,1
		addi $s2,$s2,1
	jal AjoutExtension
FinAjout:


#################################
#Ouverture et lecture du fichier#
#################################

fileRead:
    
    li   $v0, 13       					# system call pour l'ouverture
    la   $a0, filename   				# nom du fichier
    li   $a1, 0        					# flag for reading
    li   $a2, 0        					# mode ignorer
    syscall            				
    move $s0, $v0      					# file descriptor

    									# lecture
    li   $v0, 14       					# system call pour la lecture
    move $a0, $s0      					# file descriptor 
    la   $a1, buffer   					# adresse du buffer
    li   $a2, 100000   					# longueur buffer
    syscall            				
	move $s7, $v0  						# $s7 nombre totale de byte 



 		
li $s3, 0								# taille du texte de sortie
li $s1, 0								# position lecture
li $s2, 0              				    # position ecriture


####################################
#Boucle permettant la decompression#
####################################

li $t0, 0               
li $t1, 0	  

Boucle :
	addi $t2, $s1, 2
	bge $t2, $s7, Fin					# Condition fin de boucle

	lb $t0, buffer($s1)					# position 
	subi $t0, $t0, 48		

	beqz $t0, Boucle1					# Si p=0 on a (0,0,c) -> Boucle1
	
	addi $t3, $s1, 1
	lb $t1, buffer($t3)					# longueur 
	subi $t1, $t1, 49
	

	li $t4, 0
	Boucle2 :
		addu $t5, $s2, $t4  
		subu $t6, $t5, $t0 	

		lb $a0, decompressedtext($t6)	# recupere le caractere ( position $t6 ) 	
		sb $a0, decompressedtext($t5)	# stocke le caractere ( position $t5 )
		addi $s3, $s3, 1 
		addi $t4, $t4, 1
		ble $t4, $t1, Boucle2
	j FinBoucle2
		
	FinBoucle2 :
		addu $s2, $s2, $t1
		addi $s2, $s2, 1
	

	Boucle1:
		addi $t2, $s1, 2
		lb $a1, buffer($t2)				# recupere le caractere
		sb $a1, decompressedtext($s2)	
		addi $s3, $s3, 1 
		addi $s2, $s2, 1


addi, $s1, $s1, 3						# on passe au prochaine triplet 
	
j Boucle

Fin : 
	


Ecriture: 
	file_open:							# ouverture du nouveau fichier
    li $v0, 13
    la $a0, filenamecopy				# nom du fichier de sortie
    li $a1, 1							# flags
    li $a2, 0							# mode
    syscall  							# retourne $v0 = file descriptor
file_write:								# ecriture
    move $a0, $v0  						# on move le file descriptor
    li $v0, 15
	move $a2,$s3						# longueur chaine
    la $a1, decompressedtext
    syscall
file_close:								# fermeture
    li $v0, 16  						
    syscall

							

j Exit

Exit: 
li $v0, 10
syscall

