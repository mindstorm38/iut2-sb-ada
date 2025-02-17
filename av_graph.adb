with p_vue_graph, p_fenbase, text_io, p_virus, ada.exceptions;
use p_vue_graph, p_fenbase, text_io, p_virus, ada.exceptions;

procedure av_graph is

	use p_piece_io;
	use p_partie_io;

	NIVEAU_MAX: constant integer := 20;

	fenetre_accueil: TR_Fenetre;
	fenetre_jeu: TR_Fenetre;
	fenetre_regles: TR_Fenetre;
	fenetre_fin: TR_Fenetre;
	etat: T_Etat;
	dernier_etat: T_Etat;

	info_partie: TR_InfoPartie;
	grille: TV_Grille;
	pieces: TV_Pieces;

	clic_ligne: T_Lig;
	clic_col: T_Col;
	clic_couleur: T_coul;
	clic_direction: T_Direction;

	derniere_sauv: TR_Sauvegarde;

	f: p_piece_io.file_type;
	f_historique: p_partie_io.file_type;

	function AttendreBoutonFenetreActuelle return String is
		-- {} => {Attend, en fonction de la fenetre actuelle, le clic des boutons}
	begin

		if etat in T_EtatEnJeu'Range then
			return AttendreBouton(fenetre_jeu);
		elsif etat = REGLES then
			return AttendreBouton(fenetre_regles);
		elsif etat = SUCCES then
			return AttendreBouton(fenetre_fin);
		else
			return AttendreBouton(fenetre_accueil);
		end if;

	end AttendreBoutonFenetreActuelle;

	procedure InitEtConfigDepuisInfoPartie is
		-- {} => {La partie a été initialisé et configuré}
	begin

		InitPartie(grille, pieces);
		Configurer(f, info_partie.niveau, grille, pieces);

	end InitEtConfigDepuisInfoPartie;

	procedure DefinirDerniereSauv is
		-- {} => {Defini la dernière sauvegarde par rapport à l'état actuel du jeu}
	begin
		derniere_sauv := (grille, info_partie.nb_erreurs, info_partie.nb_deplacements);
	end DefinirDerniereSauv;

	procedure OuvrirFichierHistorique is
		-- {} => {f_historique a été ouvert, ou créé si non existant}
	begin
		open(f_historique, in_file, "Historique");
	exception
		when p_partie_io.NAME_ERROR => create(f_historique, out_file, "Historique");
 	end OuvrirFichierHistorique;

begin

	open(f, in_file, "Parties");
	OuvrirFichierHistorique;

	InitialiserFenetres;

	CreerFenetreAccueil(fenetre_accueil);
	CreerFenetreJeu(fenetre_jeu);
	CreerFenetreRegles(fenetre_regles);
	CreerFenetreFin(fenetre_fin);

	etat := ACCUEIL;
	MontrerFenetre(fenetre_accueil);

	while etat /= QUITTER loop

		declare
			nom_bouton: String := AttendreBoutonFenetreActuelle;
		begin

			if etat = ACCUEIL then

				if AccueilBoutonEstQuitter(nom_bouton) then
					etat := QUITTER;
				elsif AccueilBoutonEstValider(nom_bouton) then

					begin

						info_partie := AccueilRecupInfos(fenetre_accueil, NIVEAU_MAX);

						-- Afficher un message vide permet de s'assurer que le texte message n'est plus visible.
						AccueilAfficherMessage(fenetre_accueil, "");

						InitEtConfigDepuisInfoPartie;
						JeuAfficherGrille(fenetre_jeu, grille, info_partie);

						DefinirDerniereSauv;
						JeuAutoriserAnnuler(fenetre_jeu, false);

						-- On défini le temps de debut de partie
						DefinirDebutPartie(info_partie);

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

					-- On (re)défini le temps de debut de partie et on met à (re)met à zéro le nb_erreurs et nb_deplacements
					DefinirDebutPartie(info_partie);

					-- On appel l'initialisation puis la configuration de la partie, comme on le fait au début du jeu. Et on defini la dernière sauvegarde.
					InitEtConfigDepuisInfoPartie;
					JeuAfficherGrille(fenetre_jeu, grille, info_partie);

					DefinirDerniereSauv;
					JeuAutoriserAnnuler(fenetre_jeu, false);

					etat := SELECTION_CASE;

				elsif JeuBoutonEstQuitter(nom_bouton) then

					etat := ACCUEIL;
					CacherFenetre(fenetre_jeu);
					MontrerFenetre(fenetre_accueil);

				elsif JeuBoutonEstRegles(nom_bouton) then

					-- On défini dernier_etat à l'état du jeu actuel afin que la fenêtre des règles puisse revenir à l'accueil.
					dernier_etat := etat;
					etat := REGLES;
					CacherFenetre(fenetre_jeu);
					MontrerFenetre(fenetre_regles);

				elsif JeuBoutonEstAnnuler(nom_bouton) then

					grille := derniere_sauv.grille;
					info_partie.nb_deplacements := derniere_sauv.nb_deplacements;
					info_partie.nb_erreurs := derniere_sauv.nb_erreurs + 1; -- Annuler rajoute une erreur

					-- Après avoir remis les informations du dernier coup,
					JeuAfficherGrille(fenetre_jeu, grille, info_partie);
					JeuAutoriserAnnuler(fenetre_jeu, false);

				elsif JeuBoutonEstClicCouleur(nom_bouton, clic_ligne, clic_col) then

					clic_couleur := grille(clic_ligne, clic_col);

					-- On vérifie que la case est bien valide pour cette grille
					if clic_couleur in T_CoulP'Range and then clic_couleur /= blanc and then pieces(clic_couleur) then

						JeuSelectCouleurs(fenetre_jeu, grille, clic_couleur);
						etat := SELECTION_DIR;

					end if;

				elsif etat = SELECTION_DIR and JeuBoutonEstDirection(nom_bouton, clic_direction) then

					DefinirDerniereSauv;
					JeuAutoriserAnnuler(fenetre_jeu, true);

					if Possible(grille, clic_couleur, clic_direction) then

						MajGrille(grille, clic_couleur, clic_direction);
						info_partie.nb_deplacements := info_partie.nb_deplacements + 1;

					else
						info_partie.nb_erreurs := info_partie.nb_erreurs + 1;
					end if;

					JeuAfficherGrille(fenetre_jeu, grille, info_partie);

					-- On test le gain de la partie
					if Guerison(grille) then

						etat := SUCCES;

						DefinirFinPartie(info_partie);

						-- Dans ce declare on recupère le vecteur depuis le fichier d'historique puis on y ajoute la nouvelle partie au bon endroit.
						declare
							vec_parties: TV_Parties := RecupVecteurFichier(f_historique);
						begin
							EcrireFichierAvecNouvellePartie(f_historique, vec_parties, info_partie);
							-- OuvrirFichierHistorique; -- On réouvre le fichier puisque la procedure au dessus appel 'close' afin de finaliser la lecture.
						end;

						FinAfficherStats(fenetre_fin, info_partie, RecupVecteurFichier(f_historique));

						CacherFenetre(fenetre_jeu);
						MontrerFenetre(fenetre_fin);

					else
						etat := SELECTION_CASE;
					end if;

				end if;

			elsif etat = SUCCES then

				if FinBoutonEstQuitter(nom_bouton) then

					etat := ACCUEIL;
					CacherFenetre(fenetre_fin);
					MontrerFenetre(fenetre_accueil);

				end if;

			end if;

		end;

	end loop;

end av_graph;
