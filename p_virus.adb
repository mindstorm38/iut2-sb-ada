with text_io, sequential_io;
use text_io;

package body p_virus is

	procedure InitPartie(grille: in out TV_Grille; pieces: in out TV_Pieces) is
		--{} => {Tous les éléments de Grilleont été initialisés avec la couleur vide
		--       y compris les cases inutilisables
		--       Tous les éléments de Pieces ont été initialisés à false}
	begin

		for ligne in T_Lig'Range loop
			for col in T_Col'Range loop
				grille(ligne, col) := vide;
			end loop;
		end loop;

		pieces := (others => false);

	end InitPartie;

	procedure Configurer(f: in out p_piece_io.file_type; nb: in integer; grille: in out TV_Grille; pieces: in out TV_Pieces) is

		--{f ouvert,nb est un numéro de configuration (appelé numéro de partie),
		-- une configuration décrit le placement des pièces du jeu, pour chaque configuration:
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

			if premier_passe then

				if derniere_couleur /= elem_piece.couleur and derniere_couleur = rouge then
					config_nb := config_nb + 1;
				end if;

			else
				premier_passe := true;
			end if;

			if config_nb = nb then

				grille(elem_piece.ligne, elem_piece.colonne) := elem_piece.couleur;
				pieces(elem_piece.couleur) := true;

			end if;

		end loop;

	end Configurer;

	procedure PosPiece(grille: in TV_Grille; coul: in T_CoulP) is
		--{} => {la position de la pièce de couleur coul a été affichée si cette pièce est dans Grille
		--       exemple: ROUGE: F4 G5}
		present: boolean := false;
	begin

		for ligne in T_Lig'Range loop
			for col in T_Col'Range loop

				if grille(ligne, col) = coul then

					if not present then
						put(T_CoulP'Image(coul) & ": ");
						present := true;
					end if;

					put(col);
					put(ligne, 0);
					put(' ');

				end if;

			end loop;
		end loop;

		new_line;

	end PosPiece;

	function Possible(grille: in TV_Grille; coul: T_CoulP; dir: in T_Direction) return boolean is
		-- {coul /= blanc}
		-- => {résultat= vrai si la pièce de couleur coul peut être déplacée dans la direction Dir}
		ligne_temp: integer;
		col_temp: character;
		grille_coul: T_coul;
	begin

		for ligne in T_Lig'Range loop
			for col in T_Col'Range loop

				if grille(ligne, col) = coul then

					-- bg, hg, bd, hd
					case dir is
						when bg =>
							ligne_temp := ligne + 1;
							col_temp := T_Col'pred(col);
						when hg =>
							ligne_temp := ligne - 1;
							col_temp := T_Col'pred(col);
						when bd =>
							ligne_temp := ligne + 1;
							col_temp := T_Col'succ(col);
						when hd =>
							ligne_temp := ligne - 1;
							col_temp := T_Col'succ(col);
					end case;

					grille_coul := grille(ligne_temp, col_temp);
					if ligne_temp not in T_Lig'Range or else col not in T_Col'Range or else (grille_coul /= vide and grille_coul /= coul) then
						return false;
					end if;

				end if;

			end loop;
		end loop;

		return true;

	end Possible;

	procedure MajGrille (grille: in out TV_Grille; coul: in T_coulP; dir: in T_Direction) is
		-- {la pièce de couleur coul peut  être déplacée  dans la direction Dir}
		-- => {Grille  a été mis  à  jour suite au déplacement}
		ligne_temp: T_Lig;
		col_temp: T_Col;
		new_grille: TV_Grille;
	begin

		for ligne in T_Lig'Range loop
			for col in T_Col'Range loop
				new_grille(ligne, col) := vide;
			end loop;
		end loop;

		for ligne in T_Lig'Range loop
			for col in T_Col'Range loop

				if grille(ligne, col) = coul then

					case dir is
						when bg =>
							ligne_temp := ligne + 1;
							col_temp := T_Col'pred(col);
						when hg =>
							ligne_temp := ligne - 1;
							col_temp := T_Col'pred(col);
						when bd =>
							ligne_temp := ligne + 1;
							col_temp := T_Col'succ(col);
						when hd =>
							ligne_temp := ligne - 1;
							col_temp := T_Col'succ(col);
					end case;

					new_grille(ligne_temp, col_temp) := grille(ligne, col);

				elsif new_grille(ligne, col) = vide then
					new_grille(ligne, col) := grille(ligne, col);
				end if;

			end loop;
		end loop;

		grille := new_grille;

	end MajGrille;

	function Guerison(grille: in TV_Grille) return boolean is
		-- {} => {résultat = le virus (pièce rouge) est prêt à sortir (position coin haut gauche)}
	begin
		return grille(1, 'A') = rouge and grille(2, 'B') = rouge;
	end Guerison;

end p_virus;
