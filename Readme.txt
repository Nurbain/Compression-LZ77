 Nom Prenom
 IBIS Ibrahim
 URBAIN Nathan
 
 
###################################################
# Rendu du projet d'architectures des ordinateurs #
###################################################

Explications des fonctionnalit�s impl�ment�es : 

compression.s : 
  Au lancement, le programme demande tout d'abord la taille du tampon de lecture
  puis la taille du tampon de recherche et puis enfin le nom du fichier texte.
  Exemple de saisi : 5 puis 6 puis Pirouette.txt
  
  Le programme affiche la taille du tampon de lecture / recherche, la taille de
  la fenetre mais �galement la taille du fichier d'entr�e et de sortie
  
  En sortie nous obtenons un fichier reprenant le nom du fichier d'entr�e 
  Avec l'exemple precedent on obtiens Pirouette.lz77.
  
decompression.s :
  Au lancement, le programme demande le nom du fichier de type .lz77
  Exemple de saisi : Pirouette.lz77
  
  En sortie nous obtenons un fichier reprenant le nom du fichier d'entr�e
  soit Pirouette.txt avec l'exemple precedent.







 
    � Le taux de compression est-il le m�me pour les trois fichiers .txt? Pourquoi? 
TR = Tampon Recherche
TL = Tampon Lecture
 
( Formule utilis� pour le taux de compression : T = 1 - ( Volume final / Volume initial ) )

                       Taille TR | Taille TL | Pirouette.txt | Lepetitprince.txt | Voltaire.txt
Taux de compresssion      6           5             -1,39            -1,23            -1.28
                          23         22             -0,72            -0.67            -0.65
                          31         30             -0.51            -0.66            -0.60

Le taux de compression d�pend de la taille de la fen�tre, de la r�partition de la taille du tampon 
de recherche et du tampon de lecture mais �galement de la fr�quence de mots qui se suivent se ressemblant. 

    � La compression peut-elle �tre n�gative? Si oui, dans quels cas? 
Oui, quand la fen�tre est trop petite le nombre de triplet est beaucoup plus grande en octet que 
la taille du texte initial donc on a une compression n�gative

    � Peut-on obtenir un meilleur taux de compression avec d�autres valeurs de N et/ou de F ? 

Oui voir le tableau de comparaison plus haut. On peut apercevoir qu'en augmentant les tailles des tampons
on a un meilleur taux de compression.

    � Quels sont les points fort/faibles de l�algorithme LZ77?

Points forts :
l'algorithme est compris par toutes les machines, il a l'avantage d'�tre rapide mais aussi 
asym�trique ( l'algorithme de d�compression est diff�rent de celui de compression ), ce 
qui peut permettre de faire un algorithme de compression performant et un algorithme de 
d�compression rapide. Il a aussi l'avantage de ne pas avoir de perte de donn�es


Points faibles : 
le plus gros point faible de cet algorithme est qu'il ne fonctionne qu'avec des fichiers textes 
( par exemple on ne pourra pas compresser une image). Il arrive aussi que la compression ne 
fonctionne pas pour des cas sp�ciaux. Pour des tailles de fen�tre trop petites, on a un taux de
compression qui est n�gatif donc inutile dans ce cas.