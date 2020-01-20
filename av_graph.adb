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

	f: p_piece_io.file_type;

	procedure Quitter is
	begin
		etat := QUITTER;
	end Quitter;

	procedure Jouer is
	begin
		etat := EN_JEU;
	end Jouer;

	procedure Accueil is
	begin
		etat := ACCUEIL;
	end Accueil;

	temp: boolean;

begin

	open(f, in_file, "Parties");

	InitialiserFenetres;

	CreerFenetreAccueil(fenetre_accueil);
	CreerFenetreJeu(fenetre_jeu);

	Accueil;
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

					Jouer;
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

		elsif etat = EN_JEU then

			

			temp := true;

		end if;

	end loop;

end av_graph;
