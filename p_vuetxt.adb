with text_io, p_virus, ada.characters.latin_1;
use text_io, p_virus, ada.characters.latin_1;

package body p_vuetxt is

	use p_int_io;

	procedure AfficheGrille(grille: in TV_Grille) is
		-- {} => {la grille a été affichée selon les spécifications suivantes :
		--        * la sortie estindiquée par la lettre S
		--        * une case inactive ne contient aucun caractère
		--        * une case de couleur vide contientun point
		--        * une case de couleur blanchecontientle caractère F (Fixe)
		--        * une case de la couleur d’une pièce mobilecontientle chiffre correspondant à la
		--          position de cettecouleur dans le type T_Coul}
		couleur: T_Coul;
	begin

		-- Affichage du header

		put("    ");
		for col in T_Col'Range loop
			put(col);
			put(' ');
		end loop;

		new_line;
		put("  S ");
		for col in T_Col'Range loop
			put("- ");
		end loop;

		-- Affichage des lignes
		for ligne in T_Lig'Range loop

			-- Affichage du header latéral
			new_line;
			put(ligne, 0);
			put(" | ");

			for col in T_Col'Range loop

				couleur := grille(ligne, col);

				-- Cette comparaison permet de n'afficher que les case comme vu dans la consigne
				if COLONNE_INDICES(col) mod 2 = ligne mod 2 then

					-- Suivant la couleur on n'affiche différents caractères
					case couleur is
						when vide => put(". ");
						when blanc => put("F ");
						when others =>
							put(ESC);
							put(COULEUR_ANSI(couleur));
							put(T_Coul'Pos(couleur), 0);
							put(' ');
							put(ESC);
							put(RESET_ANSI);
					end case;

				else
					put("  ");
				end if;

			end loop;

		end loop;

		new_line;

	end AfficheGrille;

end p_vuetxt;
