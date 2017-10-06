.data


tamponl : .byte   0:5 					# contient le texte du tampon de lecture
tamponr : .byte   0:6 					# contient le texte du tampon de recherche
filename : .byte 0:30					# contient le nom du fichier
store : .byte   0:1						# permet le stockage d'un seul caractère

		
tamponvide : .byte   0:10000			# tamponvide



compressedtext : .byte 0:10000			# le contenu du fichier de sortie
filenamecopy : .byte 0:30				# nom du fichier de sortie

str_data_end:
buffercopie : .byte   0:10000 			# copie du buffer + initampon au debut
buffer: .byte   0:10000 				# contient tout le texte

str1 :  .asciiz "\nNom du fichier ? :"	
str2 :  .asciiz "\nTaille du tampon de lecture (F) ? :"
str3 :  .asciiz "\nTaille du tampon de recherche ? :"

aff1 :  .asciiz "\nTaille tampon lecture (F) : "
aff2 :	.asciiz "\nTaille tampon recherche : "
aff3 :	.asciiz "\nTaille fenetre (N) : "	
aff4 :  .asciiz "\nTaille du fichier d'entrée : "
aff5 :  .asciiz "\nTaille du fichier de sortie : "	
extension : .asciiz "lz77"				# extension du fichier de sortie
initampon : .asciiz " "	


ret : .asciiz "\n"

ttl: .byte 0:10
ttr: .byte 0:10

.text
.globl __start

__start:

###########################################
#Demande taille tampon lecture / recherche#
###########################################

li $a1,0

la $a0,str2 							# taille lecture
li $v0,4
syscall

li $v0,5
syscall
sub $v0,$v0,1
sb $v0, ttl($a1)

la $a0,str3 							# taille recherche
li $v0,4
syscall

li $v0,5
syscall
sub $v0,$v0,1
sb $v0, ttr($a1)



#######################################################
#Affichage taille tampon lecture / recherche / fenetre#
#######################################################
li $a1,0
lb $s1, ttl($a1)
lb $s2, ttr($a1)
addi $s1,$s1,1
addi $s2,$s2,1

add $a2,$s1,$s2
la $a0,aff3 							
li $v0,4
syscall

move $a0,$a2
li $v0,1
syscall


la $a0,aff1 							
li $v0,4
syscall
move $a0,$s1
li $v0,1
syscall


la $a0,aff2 							
li $v0,4
syscall
move $a0,$s2
li $v0,1
syscall



#######################################################

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

	la $a0,aff4							
	li $v0,4
	syscall
	
	move $a0,$s7
	li $v0,1
	syscall
##################################

li $t9,0 			   					# variable permettant de definir la position de la chaine 
li $t8,0			   					# compteur pour ecriture ( ne pas utiliser )


jal CopieTexte							# execute la fonction CopieTexte plus bas
InitialiseTampon:
	jal TamponLecture					# premier appel pour initialisation du tampon de lecture

BoucleCompression:						# boucle principale permettant de lier les differentes fonctions
		jal TestVide					# renvoie 1 si tampon lecture vide sinon 0
	Test:
		beq $s0 1 FinCompression		# si c'est vide va à l'ecriture
		jal Comparaison					# execute la fonction Comparaison plus bas
	SuiteCompression:					# incrementation des variables
		addi $t9,$t9,1
		add $t9,$t9,$a2
		jal TamponLecture				# decalage TamponLecture
		jal BoucleCompression			# on relance la boucle 
FinCompression:


######################################
#Ecriture du resultat dans un fichier#
######################################



li $s1,0								# calcule la longueur de la chaine
la $s0,compressedtext
BoucleC:   
	lb $a0,0($s0)
	beqz $a0,End
	addi $s0,$s0,1
	addi $s1,$s1,1
j BoucleC
End:   

la $a0,aff5
li $v0,4
syscall

move $a0,$s1
li $v0,1
syscall

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
	move $a2,$s1						# longueur chaine
    la $a1, compressedtext
    syscall
file_close:								# fermeture
    li $v0, 16  						
    syscall

	jal Close							# saut vers la fin
	
	








#################################################################
#Creation d'une copie du texte + espace pour tampon de recherche#
#################################################################
CopieTexte:


	li $s4,0 							# position 0
	lb $s3, ttl($s4)
	li $s2,0							
	
		lb $s1, initampon($s4)
	TamponVideInit:    					# fonction permettant l'ajout des espaces au debut dans buffercopie
		bgt $s2,$s3 FinVideInit
		sb $s1, tamponvide($s2)
		addi $s2,$s2,1
		jal TamponVideInit
	FinVideInit:

	li $s4,0 							# position 0
	lb $s3, ttr($s4)
	li $s2,0							
		lb $s1, initampon($s4)
	TamponRechercheInit:    			# fonction permettant l'ajout des espaces au debut dans buffercopie
		bgt $s2,$s3 FinInit
		sb $s1, buffercopie($s2)
		addi $s2,$s2,1
		jal TamponRechercheInit
	FinInit:
	
	li $s4,0	
	lb $t7, ttr($s4)
	add $t7,$t7,$s7 					# calcul de $t7 pour fin boucle
							

	TamponRechercheCopie:				# copie le contenu de buffer dans buffercopie après les espaces
		bgt $s4,$s7 FinCopie 			
		lb $s1, buffer($s4)
		sb $s1, buffercopie($s2)
		addi $s4,$s4,1
		addi $s2,$s2,1
		jal TamponRechercheCopie
FinCopie:
	jal InitialiseTampon


#################################################################
#Fonction qui permet de charger le mot dans le tampon de lecture#
#################################################################


TamponLecture:
	li $t2,0	
	move $t4,$t9
	lb $t3, ttl($t2)
	add $t3,$t3,$t4						# position max tampon de lecture, 4 ->(F=5)  
							

	TamponLectureBoucle:				# fonction qui charge le mot dans le tampon de lecture
		bgt $t4 $t3 FinLecture
		move $t0,$t4
		lb $t1, buffer($t0)
		sb $t1, tamponl($t2)
		addi $t4,$t4,1
		addi $t2,$t2,1
		jal TamponLectureBoucle
FinLecture :
	


###################################################################
#Fonction qui permet de charger le mot dans le tampon de recherche#
###################################################################

TamponRecherche:
	li $s3,0	
	li $s2,0						
	move $s4,$t9						# position min tampon de recherche
	lb $s3, ttr($s2)
	add $s3,$s3,$s4						# position max tampon de recherche, 5->(F=6)


	TamponRechercheBoucle:	    		# fonction qui charge le mot dans le tampon de lecture
		bgt $s4 $s3 FinRecherche
		move $s5,$s4
		lb $s1, buffercopie($s5)
		sb $s1, tamponr($s2)
		addi $s4,$s4,1
		addi $s2,$s2,1
		jal TamponRechercheBoucle
FinRecherche :
	jal BoucleCompression


#####################################################
#Test tampon de lecture vide pour arret de la boucle#
#####################################################
TestVide:
	li $a1,0 							# longueur de la chaine identique
	
	li $a2,0 							# compteur tampon lecture ( incrementation )
	li $a3,0 							# compteur chaine vide

	lb $s2, ttl($a1)
	lb $s3, ttr($a1)

	BoucleTest:
		bgt $a2 $s2 FinBoucleTest
		bgt $a3 $s2 FinBoucleTest
		lb $t1, tamponl($a2)
		lb $t2, tamponr($a3)
		beq $t1 $t2 Incrementation1
		SuiteTest:
		addi $a3,$a3,1
		addi $a2,$a2,1
		jal BoucleTest
	
	Incrementation1:
		addi $a1,$a1,1 					# longueur de la chaine 
		jal SuiteTest
	FinBoucleTest:
		beq $a1 $s3 Vrai				# si $a1 = longueur de la chaine => Vrai
		blt $a1 $s3 Faux				# si $a1 < longueur de la chaine => Faux
	Vrai:
		li $s0,1
		jal Fintest
	Faux:
		li $s0,0
	Fintest:
		jal Test

########################################################################################
#Boucle principale qui permet la compression du texte + stockage du retour dans un data#
########################################################################################


Comparaison :
	li $t7,0							# position de la chaine (p)
	li $a1,0 							# longueur de la chaine identique
	
	li $a2,0							# compteur tampon lecture
	lb $a3, ttr($a2)					# compteur tampon recherche
	move $s5,$a3
	li $s2,0
	lb $s6, ttl($s2)
	li $s7,0
	

	Boucle:
		bgt $a2 $s6 TestFin
		blt $a3 0 TestFin
		lb $t1, tamponl($a2)
		lb $t2, tamponr($a3)
		beq $t1 $t2 Incrementation
		beq $t1 32	FirstEspace
		Suite:
		sub $a3,$a3,1
		jal Boucle
	
	Incrementation:		
		addi $s7,$s7,1				
		move $t7,$a3 					
		jal Suite

	FirstEspace:
		
		BoucleEspace:
			bgt $a2 $s6 TestFin
			blt $a3 0 TestFin
			lb $t1, tamponl($a2)
			lb $t2, tamponr($a3)
			beq $t1 $t2 Move
			sub $a3,$a3,1
		jal BoucleEspace

	Move:
		addi $s7,$s7,1
		move $t7,$a3


	TestFin:
		beq $s7 0 FinBoucle
		addi $a1,$a1,1 	
		addi $a2,$a2,1
		move $a3,$t7
		addi $a3,$a3,1
		
		
		
	SuiteBoucle2:						
		bgt $a2 $s6 FinBoucle
		bgt $a3 $s5 FinBoucle 
		blt $a3 0 FinBoucle
		lb $t1, tamponl($a2)
		lb $t2, tamponr($a3)
		beq $t1 $t2 Incrementation2
		bne $t1 $t2 FinBoucle
		Suite2:
		add $a3,$a3,1
		jal SuiteBoucle2

	Incrementation2:
		addi $a1,$a1,1 
		addi $a2,$a2,1
		beq $1 1 Next
		move $t7,$a3 
		Next:
		add $a3,$a3,1
		jal Suite2

	FinBoucle:
		beq $a1 0 Retourne2

		Retourne1:
			li $t2,0
			lb $s2, ttr($t2)
			addi $s2,$s2,1

			sub,$t7,$s2,$t7	
			move $a0,$t7
			addi $a0,$a0,48				# transformation ascii
			sb $a0, compressedtext($t8)	# p -> position
			addi $t8,$t8,1
			li $s2,0

			move $a0,$a1
			addi $a0,$a0,48				# transformation ascii
			sb $a0, compressedtext($t8) # l -> longueur
			addi $t8,$t8,1

			li $s3,0
			add $s3,$s3,$a1
			lb $t2, tamponl($s3)		
			sb $t2, compressedtext($t8)	# c -> caractère
			addi $t8,$t8,1
	
			jal FinComparaison

		Retourne2:
			li $s2,0
			move $a0,$t7
			addi $a0,$a0,48				# transformation ascii
			sb $a0, compressedtext($t8) # p -> position
			addi $t8,$t8,1
				

			move $a0,$a1
			addi $a0,$a0,48				# transformation ascii
			sb $a0, compressedtext($t8)	# l -> longueur
			addi $t8,$t8,1

			li $s3,0
			lb $t2, tamponl($s3)
			sb $t2, compressedtext($t8) # c -> caractère
			addi $t8,$t8,1
		
			jal FinComparaison

FinComparaison:
	move $a2,$a1 						# recupere la longueur dans $a2
	jal SuiteCompression


############################
#Fermeture du fichier texte#
############################

Close:
	li	$v0,16							# Fermeture
	move $a0, $s6						# Load File descriptor
	syscall
	j	Done							
 

Done:
	li	$v0, 10							# Exit Syscall
	syscall
