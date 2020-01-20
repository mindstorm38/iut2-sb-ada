with p_esiut, sequencial_io;
use p_esiut;
salut
package body p_virus is

	procedure InitPartie(grille: in out TV_Grille; pieces: in out TV_Pieces) is
		--{} => {Tous les éléments de Grilleont été initialisés avec la couleur vide
		--       y compris les cases inutilisables
		--       Tous les éléments de Pieces ont été initialisés à false}
	begin

		grille := (others => vide);
		pieces := (others => false);

	end InitPartie;

	procedure Configurer(f: in out p_pieces_io.file_type; nb: in positive; grille: in out TV_Grille; pieces: in out TV_Pieces) is

		--{f ouvert,nb est un numéro de configuration (appelé numéro de partie),
		-- une configurationdécrit le placement des pièces du jeu, pour chaqueconfiguration:
		-- * les éléments d’une même pièce (même couleur) sont stockés consécutivement
		-- * il n’y a pas deux pièces mobiles ayant la même couleur
		-- * les deux éléments constituant levirus (couleur rouge) terminent la configuration}
		-- => {Grille a été mis à jour par lecture dans f dela configurationde numéronb
		--     Pieces a été initialisé en fonction despièces de cette configuration}

		elem_piece: TR_ElemP;
		derniere_couleur: T_CoulP;
		premier_passe: boolean := false;
		config_nb: integer := 1;

	begin

		reset(f, in_file);

		while not end_of_file(f) and config_nb <= nb loop

			derniere_couleur := elem_piece.couleur;
			read(f, elem_piece);

			if config_nb = nb then

				grille(elem_piece.ligne, elem_piece.colonne) := elem_piece.couleur;
				pieces(elem_piece.couleur) := true;

			end if;

			if premier_passe then

				if derniere_couleur /= elem_piece.couleur and derniere_couleur = rouge then
					config_nb := config_nb + 1;
				end if;

			else
				premier_passe := true;
			end if;

		end loop;

	end Configurer;

	procedure PosPiece(grille: in TV_Grille; coul: in T_CoulP) is
		--{} => {la position de la pièce de couleur coul a été affichéesi cette pièce est dans Grille
		--       exemple: ROUGE: F4 G5}
	begin



	end PosPiece;

end p_virus;
