# Compression-LZ77

 Auteurs
 IBIS Ibrahim
 URBAIN Nathan
 
# Projet d'architectures des ordinateurs #

Explications des fonctionnalités implémentées : 

# compression.s : 
  Au lancement, le programme demande tout d'abord la taille du tampon de lecture
  puis la taille du tampon de recherche et puis enfin le nom du fichier texte.
  Exemple de saisi : 5 puis 6 puis Pirouette.txt
  
  Le programme affiche la taille du tampon de lecture / recherche, la taille de
  la fenetre mais également la taille du fichier d'entrée et de sortie
  
  En sortie nous obtenons un fichier reprenant le nom du fichier d'entrée 
  Avec l'exemple precedent on obtiens Pirouette.lz77.
  
# decompression.s :
  Au lancement, le programme demande le nom du fichier de type .lz77
  Exemple de saisi : Pirouette.lz77
  
  En sortie nous obtenons un fichier reprenant le nom du fichier d'entrée
  soit Pirouette.txt avec l'exemple precedent.
  
  Le taux de compression est-il le même pour les trois fichiers .txt? Pourquoi? 
TR = Tampon Recherche
TL = Tampon Lecture
 
( Formule utilisé pour le taux de compression : T = 1 - ( Volume final / Volume initial ) 

![alt text](http://image.noelshack.com/fichiers/2017/40/6/1507330108-cats.jpg)

Le taux de compression dépend de la taille de la fenêtre, de la répartition de la taille du tampon 
de recherche et du tampon de lecture mais également de la fréquence de mots qui se suivent se ressemblant. 

    • La compression peut-elle être négative? Si oui, dans quels cas? 
Oui, quand la fenêtre est trop petite le nombre de triplet est beaucoup plus grande en octet que 
la taille du texte initial donc on a une compression négative

    • Peut-on obtenir un meilleur taux de compression avec d’autres valeurs de N et/ou de F ? 

Oui voir le tableau de comparaison plus haut. On peut apercevoir qu'en augmentant les tailles des tampons
on a un meilleur taux de compression.

    • Quels sont les points fort/faibles de l’algorithme LZ77?

Points forts :
l'algorithme est compris par toutes les machines, il a l'avantage d'être rapide mais aussi asymétrique ( l'algorithme de décompression est différent de celui de compression ), ce qui peut permettre de faire un algorithme de compression performant et un algorithme de  décompression rapide. Il a aussi l'avantage de ne pas avoir de perte de données


Points faibles : 
le plus gros point faible de cet algorithme est qu'il ne fonctionne qu'avec des fichiers textes ( par exemple on ne pourra pas compresser une image). Il arrive aussi que la compression ne fonctionne pas pour des cas spéciaux. Pour des tailles de fenêtre trop petites, on a un taux de compression qui est négatif donc inutile dans ce cas.
