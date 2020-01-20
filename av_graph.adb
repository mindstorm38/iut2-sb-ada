with p_vue_graph, p_fenbase, text_io, p_virus, ada.exceptions;
use p_vue_graph, p_fenbase, text_io, p_virus, ada.exceptions;

procedure av_graph is

	use p_piece_io;

	NIVEAU_MAX: constant integer := 20;

	fenetre_accueil: TR_Fenetre;
	fenetre_jeu: TR_Fenetre;
	etat: T_Etat;

	info_part: TR_InfoPartie;
	grille: TV_Grille;
	pieces: TV_Pieces;

	clic_ligne: T_Lig;
	clic_col: T_Col;
	clic_couleur: T_coul;

	f: p_piece_io.file_type;

	procedure Quitter is
	begin
		etat := QUITTER;
	end Quitter;

	temp: boolean;

begin

	open(f, in_file, "Parties");

	InitialiserFenetres;

	CreerFenetreAccueil(fenetre_accueil);
	CreerFenetreJeu(fenetre_jeu);

	etat := ACCUEIL;
	MontrerFenetre(fenetre_accueil);

	while etat /= QUITTER loop

		if etat = ACCUEIL then

			if AccueilEstValide(fenetre_accueil) then

				begin

					info_part := AccueilRecupInfos(fenetre_accueil, NIVEAU_MAX);

					-- Afficher un message vide permet de s'assurer que le texte message n'est plus visible.
					AccueilAfficherMessage(fenetre_accueil, "");

					InitPartie(grille, pieces);
					Configurer(f, info_part.niveau, grille, pieces);

					JeuAfficherGrille(fenetre_jeu, grille);

					etat := SELECTION_CASE;
					CacherFenetre(fenetre_accueil);
					MontrerFenetre(fenetre_jeu);

				exception
					when Err: INFO_PARTIE_ERREUR =>
						-- Utilisation de Exception_Message pour afficher le message de l'exception dans la boite de message de la fenêtre.
						AccueilAfficherMessage(fenetre_accueil, Exception_Message(Err));
				end;

			else
				Quitter;
			end if;

		elsif etat = SELECTION_CASE then

			if JeuAttendreClicCouleur(fenetre_jeu, clic_ligne, clic_col) then

				clic_couleur := grille(clic_ligne, clic_col);
				etat := SELECTION_DIR;

				put_line("Ligne: " & T_Lig'Image(clic_ligne));
				put_line("Colonne: " & T_Col'Image(clic_col));
				put_line("Couleur: " & T_coul'Image(clic_couleur));

			end if;

		elsif etat := SELECTION_DIR then

			temp := true;

		end if;

	end loop;

end av_graph;
