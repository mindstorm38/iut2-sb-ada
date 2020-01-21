with p_vue_graph, p_fenbase, text_io, p_virus, ada.exceptions;
use p_vue_graph, p_fenbase, text_io, p_virus, ada.exceptions;

procedure av_graph is

	use p_piece_io;

	NIVEAU_MAX: constant integer := 20;

	fenetre_accueil: TR_Fenetre;
	fenetre_jeu: TR_Fenetre;
	fenetre_regles: TR_Fenetre;
	etat: T_Etat;
	dernier_etat: T_Etat;

	info_partie: TR_InfoPartie;
	grille: TV_Grille;
	pieces: TV_Pieces;

	clic_ligne: T_Lig;
	clic_col: T_Col;
	clic_couleur: T_coul;
	clic_direction: T_Direction;

	f: p_piece_io.file_type;

	procedure Quitter is
	begin
		etat := QUITTER;
	end Quitter;

	function AttendreBoutonFenetreActuelle return String is
		-- {} => {Attend, en fonction de la fenetre actuelle, le clic des boutons}
	begin

		if etat in T_EtatEnJeu'Range then
			return AttendreBouton(fenetre_jeu);
		elsif etat = REGLES then
			return AttendreBouton(fenetre_regles);
		else
			return AttendreBouton(fenetre_accueil);
		end if;

	end AttendreBoutonFenetreActuelle;

begin

	open(f, in_file, "Parties");

	InitialiserFenetres;

	CreerFenetreAccueil(fenetre_accueil);
	CreerFenetreJeu(fenetre_jeu);
	CreerFenetreRegles(fenetre_regles);

	etat := ACCUEIL;
	MontrerFenetre(fenetre_accueil);

	while etat /= QUITTER loop

		declare
			nom_bouton: String := AttendreBoutonFenetreActuelle;
		begin

			if etat = ACCUEIL then

				if AccueilBoutonEstQuitter(nom_bouton) then
					Quitter;
				elsif AccueilBoutonEstValider(nom_bouton) then

					begin

						info_partie := AccueilRecupInfos(fenetre_accueil, NIVEAU_MAX);

						-- Afficher un message vide permet de s'assurer que le texte message n'est plus visible.
						AccueilAfficherMessage(fenetre_accueil, "");

						InitPartie(grille, pieces);
						Configurer(f, info_partie.niveau, grille, pieces);

						JeuAfficherGrille(fenetre_jeu, grille, info_partie);

						etat := SELECTION_CASE;
						CacherFenetre(fenetre_accueil);
						MontrerFenetre(fenetre_jeu);

					exception
						when Err: INFO_PARTIE_ERREUR =>
							-- Utilisation de Exception_Message pour afficher le message de l'exception dans la boite de message de la fenêtre.
							AccueilAfficherMessage(fenetre_accueil, Exception_Message(Err));
					end;

				elsif AccueilBoutonEstRegles(nom_bouton) then

					-- On défini dernier_etat à ACCUEIL afin que la fenêtre des règles puisse revenir à l'accueil.
					dernier_etat := ACCUEIL;
					etat := REGLES;
					CacherFenetre(fenetre_accueil);
					MontrerFenetre(fenetre_regles);

				end if;

			elsif etat = REGLES then

				if ReglesBoutonEstQuitter(nom_bouton) then

					-- Si on veut quitter la fenètre de règle, alors on revient à l'état qu'on avait avant.
					etat := dernier_etat;
					CacherFenetre(fenetre_regles);

					-- Suivant le dernier état, on va sur la bonne fenêtre.
					if etat in T_EtatEnJeu'Range then
						MontrerFenetre(fenetre_jeu);
					elsif etat = ACCUEIL then
						MontrerFenetre(fenetre_accueil);
					end if;

				end if;

			elsif etat in T_EtatEnJeu'Range then

				-- Peut importe l'état si on est en jeu, alors on vérifie les évennement Recommencer, Quitter.

				if JeuBoutonEstRecommencer(nom_bouton) then
					put("recommencer");
				elsif JeuBoutonEstQuitter(nom_bouton) then

					etat := ACCUEIL;
					CacherFenetre(fenetre_jeu);
					MontrerFenetre(fenetre_accueil);

				elsif etat = SELECTION_CASE and JeuBoutonEstClicCouleur(nom_bouton, clic_ligne, clic_col) then

					clic_couleur := grille(clic_ligne, clic_col);

					-- On vérifie que la case est bien valide pour cette grille
					if clic_couleur in T_CoulP'Range and then clic_couleur /= blanc and then pieces(clic_couleur) then

						JeuSelectCouleurs(fenetre_jeu, grille, clic_couleur);
						etat := SELECTION_DIR;

					end if;

				elsif etat = SELECTION_DIR and JeuBoutonEstDirection(nom_bouton, clic_direction) then

					if Possible(grille, clic_couleur, clic_direction) then
						MajGrille(grille, clic_couleur, clic_direction);
					else
						info_partie.nb_erreurs := info_partie.nb_erreurs + 1;
					end if;

					etat := SELECTION_CASE;
					JeuAfficherGrille(fenetre_jeu, grille, info_partie);

				end if;

			end if;

		end;

	end loop;

end av_graph;
