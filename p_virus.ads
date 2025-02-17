with text_io, sequential_io;
use text_io;

package p_virus is

	-- Types pour representer la grille de jeu
	subtype T_Col is character range 'A'..'G';
	subtype T_Lig is integer range 1..7;
	type T_Coul is (rouge, turquoise, orange, rose, marron, bleu, violet, vert, jaune, blanc, vide);

	-- Type et vecteur constants utiles pour connaitre l'indice d'une colonne,
	-- par exemple la colonne B => indice 2, utilise pour la procedure AfficheGrille
	type TV_ColIndice is array (T_Col) of integer;
	COLONNE_INDICES: constant TV_ColIndice := (1, 2, 3, 4, 5, 6, 7);

	-- Grille
	type TV_Grille is array (T_lig,T_col) of T_Coul;

	-- Type pour les pièces du jeu
	subtype T_CoulP is T_Coul range rouge..blanc;

	-- Package pour la lecture des couleurs, nous avons décider de ne pas utilise le package de p_esiut
	package p_coul_io is new enumeration_io(T_CoulP);
	use p_coul_io;

	-- Package pour la lecture des entiers
	package p_int_io is new integer_io(integer);
	use p_int_io;

	type TR_ElemP is record	-- 	un élément constituant une pièce
		colonne	:	T_Col;			-- 	la colonne qu'il occupe dans la grille
		ligne	:	T_Lig;				-- 	la ligne qu'il occupe dans la grille
		couleur	:	T_CoulP;		--	sa couleur
	end record;

	type TV_Pieces is array(T_coulP) of boolean;

	---- Instanciation de sequential_io pour un fichier de TR_ElemP
	package p_piece_io is new sequential_io(TR_ElemP);
	use p_piece_io;

	---- type pour les directions de déplacement des pièces
	type T_Direction is (bg, hg, bd, hd);
	-- package p_dir_io is new p_enum(T_Direction);
	package p_dir_io is new enumeration_io(T_Direction);
	use p_dir_io;

	--------------- Primitives d'initialisation d'une partie

	procedure InitPartie(Grille : in out TV_Grille; Pieces : in out TV_Pieces);
	-- {} => {Tous les éléments de Grille ont été initialisés avec la couleur vide
	--				Tous les élements de Pieces ont été initialisés à false}

	procedure Configurer(f : in out p_piece_io.file_type; nb : in integer;
											 Grille : in out TV_Grille; Pieces : in out TV_Pieces);
	-- {f ouvert, nb est un numéro de configuration (appelé numéro de partie)
	--	une configuration décrit le placement des pièces du jeu, pour chaque configuration :
	--	* les éléments d'une même pièce (même couleur) sont stockés consécutivement
	--	* les deux éléments constituant le virus (couleur rouge) terminent la configuration}
	-- 			=> {Grille a été mis à jour par lecture dans f de la configuration de numéro nb
	--					Pieces a été initialisé en fonction des pièces de cette configuration}

	-- pour test configuration
	procedure PosPiece(Grille : in TV_Grille; coul : in T_coulP);
	-- {} => {la position de la pièce de couleur coul a été affichée :
	--				exemple : ROUGE : F4 - G5}

	--------------- Contrôle du jeu

	function Possible(Grille : in TV_Grille; coul : in T_CoulP; Dir : in T_Direction) return boolean;
	-- {coul /= blanc}
	--	=> {resultat = vrai si la pièce de couleur coul peut être déplacée dans la direction Dir}

	procedure MajGrille(Grille : in out TV_Grille; coul : in T_CoulP; Dir : in T_Direction);
	-- {la pièce de couleur coul peut être déplacée dans la direction Dir}
	--	=> {Grille a été mis à jour suite au deplacement}

	function Guerison(Grille : in TV_Grille) return boolean;
	-- {} => {resultat = la piece rouge est prete à sortir (coin haut gauche)}

end p_virus;
