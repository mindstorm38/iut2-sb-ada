with p_fenbase, forms, text_io, p_virus, ada.calendar;
use p_fenbase, forms, text_io, p_virus, ada.calendar;

package body p_vue_graph is

	-- Constante pour le caractère de retour à la ligne
	NEW_LINE: constant character := character'Val(10);

	use p_partie_io;

	------------------------------------
	-- GESTION PARTIES ET SAUVEGARDES --
	------------------------------------

	procedure DefinirDebutPartie(info_partie: in out TR_InfoPartie) is
		-- {} => {info_partie.debut_partie est défini au temps actuel, info_partie.nb_erreurs et info_partie.nb_deplacements sont mis à zero}
	begin

		info_partie.debut_partie := clock;
		info_partie.nb_erreurs := 0;
		info_partie.nb_deplacements := 0;

	end DefinirDebutPartie;


	procedure DefinirFinPartie(info_partie: in out TR_InfoPartie) is
		-- {} => {info_partie.fin_partie est défini et info_partie.duree_partie est calculé}
	begin
		info_partie.fin_partie := clock;
		info_partie.duree_partie := integer(info_partie.fin_partie - info_partie.debut_partie);
	end DefinirFinPartie;


	function PartieStrictInf(partie, autre: in TR_InfoPartie) return boolean is
		-- {} => {Retourne True si partie est inférieur à autre}
	begin
		return partie.nb_deplacements < autre.nb_deplacements or else (partie.nb_deplacements = autre.nb_deplacements and partie.duree_partie < autre.duree_partie);
	end PartieStrictInf;

	function RecupVecteurFichier(f: in out p_partie_io.file_type) return TV_Parties is
		-- {f ouvert} => {Retourne un vecteur avec toutes les parties du fichier historique}
		tampon : TR_InfoPartie;
		nb_elem_f: integer := 0;
		compteur: integer;
	begin

		reset(f, in_file);

		-- Comptage du le nombre d elements
		while not end_of_file(f) loop
			read(f,tampon);
			nb_elem_f := nb_elem_f + 1;
		end loop;

		reset(f, in_file);

		-- Copie du fichier dans un vecteur de même taille
		declare
			V: TV_Parties(1..nb_elem_f);
		begin

			compteur := 1;

			while not end_of_file(f) loop
				read(f,tampon);
				V(compteur) := tampon;
				compteur := compteur + 1;
			end loop;

			return V;

		end;

	end RecupVecteurFichier;


	function RecupMeilleursPartiesNiveau(vec_parties: in TV_Parties; niveau, nb_parties_max: in integer) return TV_Parties is
		-- {vec_parties est trié} => {Retourne un vecteur avec toutes les parties de niveau, mais limite le nombre de résultats à nb_parties_max}

		-- Le -1 est pour être sûr d'avoir un indice invalide comme marqueur.
		INDICE_INVALIDE: constant integer := vec_parties'First - 1;
		VECTEUR_VIDE: TV_Parties(1..0);

		nb_parties: integer := 0;
		idx_premiere_partie: integer := INDICE_INVALIDE;

	begin

		for i in vec_parties'Range loop

			if vec_parties(i).niveau = niveau then

				if idx_premiere_partie = INDICE_INVALIDE then
					idx_premiere_partie := i;
				end if;

				nb_parties := nb_parties + 1;

				if nb_parties = nb_parties_max then
					exit;
				end if;

			elsif vec_parties(i).niveau > niveau then
				exit;
			end if;

		end loop;

		if nb_parties /= 0 then

			declare
				ret: TV_Parties(1..nb_parties);
				j: integer := 1;
			begin

				for i in idx_premiere_partie..(idx_premiere_partie + nb_parties - 1) loop
					ret(j) := vec_parties(i);
					j := j + 1;
				end loop;

				return ret;

			end;

		else
			return VECTEUR_VIDE;
		end if;

	end RecupMeilleursPartiesNiveau;


	procedure EcrireFichierAvecNouvellePartie(f: in out p_partie_io.file_type; vec_parties: in TV_Parties; nouvelle_partie: in TR_InfoPartie) is
		-- {f ouvert, vec_parties est trié suivant le niveau et PartieStrictInf} => {Les parties sont écrites dans le fichier historique, f est fermé}
		insere: boolean := false;
		meilleur_score: boolean := true;
	begin

		-- Par défaut meilleur_score est à true, donc il faut le passer à false si un autre score dans ce niveau et ce pseudo est meilleur
		for i in vec_parties'Range loop
			if vec_parties(i).niveau = nouvelle_partie.niveau and then vec_parties(i).pseudo = nouvelle_partie.pseudo and then PartieStrictInf(vec_parties(i), nouvelle_partie) then
				meilleur_score := false;
				exit;
			end if;
		end loop;

		reset(f, out_file);

		for i in vec_parties'Range loop

			-- On cherche à écrire le nouveau joueur uniquement si son score est meilleur que le précédent et qu'il n'a pas été déjà inséré.
			if meilleur_score and not insere then

				-- On insère notre nouvelle partie uniquement si on est arrivé à la fin du niveau,
				-- ou que la partie qu'on est en train de lire est inférieur à la partie qu'on veut ajouter.
				if (vec_parties(i).niveau = nouvelle_partie.niveau and then PartieStrictInf(nouvelle_partie, vec_parties(i))) or (vec_parties(i).niveau > nouvelle_partie.niveau) then

					write(f, nouvelle_partie);
					insere := true;

				end if;

			end if;

			-- Si le niveau n'est pas celui dans lequel on veut insérer, alors on écrit bêtement les parties.
			-- Sinon on regarde que le joueur n'ai pas fait un meilleur score, dans ce cas on cherche pas en exclure un.
			-- Dans le dernier cas si le niveau est celui qu'on cherche et que le joueur à fait un meilleur score alors on vérifie que le pseudo n'est pas celui du joueur
			if vec_parties(i).niveau /= nouvelle_partie.niveau or else not meilleur_score or else vec_parties(i).pseudo /= nouvelle_partie.pseudo then
				write(f, vec_parties(i));
			end if;

		end loop;

		-- En dernier cas si le joueur a fait un meilleur score mais qu'il n'a pas été inséré, on l'insère à la fin du fichier.
		if meilleur_score and not insere then
			write(f, nouvelle_partie);
		end if;

		-- close(f);

	end EcrireFichierAvecNouvellePartie;

	---------------------
	-- FENETRE ACCUEIL --
	---------------------

	CHAMPS_ACC_PSEUDO: constant String := "accueil_pseudo";
	CHAMPS_ACC_NIVEAU: constant String := "accueil_niveau";
	TEXTE_ACC_MESSAGE: constant String := "accueil_message";
	BOUTON_ACC_VALIDER: constant String := "accueil_valider";
	BOUTON_ACC_QUITTER: constant String := "accueil_quitter";
	BOUTON_ACC_REGLES: constant String := "accueil_regles";

	procedure CreerFenetreAccueil(fen: out TR_Fenetre) is
		-- {} => {Création de la fenetre avec ses boutons}
	begin

		fen := DebutFenetre("Anti-Virus - Accueil", 480, 400);

		-- Titre
		AjouterTexte(fen, "accueil_titre", "Anti-Virus - Accueil", 20, 30, 440, 40);
		ChangerTailleTexte(fen, "accueil_titre", 30);
		ChangerAlignementTexte(fen, "accueil_titre", FL_ALIGN_CENTER);
		ChangerStyleTexte(fen, "accueil_titre", FL_TIMESBOLD_STYLE);

		-- Champs pseudo
		AjouterTexte(fen, "accueil_pseudo_label", "Votre pseudo", 80, 100, 320, 20);
		ChangerAlignementTexte(fen, "accueil_pseudo_label", FL_ALIGN_CENTER);

		AjouterChamp(fen, CHAMPS_ACC_PSEUDO, "", "Nouveau joueur", 80, 125, 320, 40);

		-- Partie à jouer
		AjouterTexte(fen, "accueil_niveau_label", "Niveau de la partie", 80, 175, 320, 20);
		ChangerAlignementTexte(fen, "accueil_niveau_label", FL_ALIGN_CENTER);

		AjouterChamp(fen, CHAMPS_ACC_NIVEAU, "", "1", 80, 200, 320, 40);

		-- Message optionel
		AjouterTexte(fen, TEXTE_ACC_MESSAGE, "", 80, 250, 320, 20);
		ChangerAlignementTexte(fen, TEXTE_ACC_MESSAGE, FL_ALIGN_CENTER);
		ChangerCouleurTexte(fen, TEXTE_ACC_MESSAGE, FL_RED);
		CacherElem(fen, TEXTE_ACC_MESSAGE);

		-- Boutons
		AjouterBouton(fen, BOUTON_ACC_VALIDER, "Valider", 80, 300, 150, 40, FL_RETURN_BUTTON);
		AjouterBouton(fen, BOUTON_ACC_QUITTER, "Quitter", 250, 300, 150, 40);
		AjouterBouton(fen, BOUTON_ACC_REGLES, "Regles", 165, 350, 150, 30);

		FinFenetre(fen);

	end CreerFenetreAccueil;


	function AccueilRecupInfos(fen: in TR_Fenetre; niveau_max: in positive) return TR_InfoPartie is
		-- {} => {Retour l'information sur la partie à partir des informations entrées}
		pseudo_brut: String := ConsulterContenu(fen, CHAMPS_ACC_PSEUDO);
		niveau_brut: String := ConsulterContenu(fen, CHAMPS_ACC_NIVEAU);
		pseudo: T_Pseudo := (others => ' ');
		niveau: integer;
	begin

		-- Vérification de la taille, voir si le pseudo n'est ni vide, ni trop long
		if pseudo_brut'Length not in T_Pseudo'Range then

			-- Si le pseudo est vide ou trop long
			raise INFO_PARTIE_ERREUR with "Le pseudo est soit vide soit trop long !";

		else

			niveau := integer'Value(niveau_brut);

			if niveau in 1..niveau_max then

				-- On n'écrase que les caractères nécessaires pour éviter les CONSTRAINT_ERROR
				pseudo(1..pseudo_brut'Length) := pseudo_brut;
				return (pseudo, niveau, pseudo_brut'Length, 0, 0, clock, clock, 0);

			else
				raise INFO_PARTIE_ERREUR with "Niveau invalide !";
			end if;

		end if;

	exception
		-- Si le niveau ne peut pas être parser alors une erreur est émise.
		when CONSTRAINT_ERROR => raise INFO_PARTIE_ERREUR with "Niveau invalide !";

	end AccueilRecupInfos;


	procedure AccueilAfficherMessage(fen: in out TR_Fenetre; message: in String) is
		-- {} => {Un message a été affiché}
	begin

		if message'Length > 0 then

			MontrerElem(fen, TEXTE_ACC_MESSAGE);
			ChangerTexte(fen, TEXTE_ACC_MESSAGE, message);

		else
			CacherElem(fen, TEXTE_ACC_MESSAGE);
		end if;

	end AccueilAfficherMessage;


	function AccueilBoutonEstQuitter(nom_bouton: in String) return boolean is
		-- {} => {True si le nom de bouton est la bouton quitter}
	begin
		return nom_bouton = BOUTON_ACC_QUITTER;
	end AccueilBoutonEstQuitter;


	function AccueilBoutonEstValider(nom_bouton: in String) return boolean is
		-- {} => {True si le nom de bouton est le bouton valider}
	begin
		return nom_bouton = BOUTON_ACC_VALIDER;
	end AccueilBoutonEstValider;


	function AccueilBoutonEstRegles(nom_bouton: in String) return boolean is
		-- {} => {True si le nom de bouton est le bouton règles}
	begin
		return nom_bouton = BOUTON_ACC_REGLES;
	end AccueilBoutonEstRegles;


	-----------------
	-- FENETRE JEU --
	-----------------


	-- Ces fonctions ne sont défini dans le .ads puisqu'elles sont utilent seulement ici --
	-- Prefix pour les boutons cases et longueur
	BC_PREFIX: constant String := "bouton_case_";
	BC_PREFIX_LEN: constant integer := BC_PREFIX'Length;

	function RecupBoutonCaseName(ligne: in T_Lig; col: in T_Col) return String is
		-- {} => {Donne le nom interne du bouton pour une ligne/col donnés}
	begin
		return BC_PREFIX & col & T_Lig'image(ligne);
	end RecupBoutonCaseName;


	function EstBoutonCase(nom: in String) return boolean is
		-- {} => {True si le bouton avec le nom est bien un bouton de case}
	begin
		return nom'Length >= BC_PREFIX_LEN and then nom(1..BC_PREFIX_LEN) = BC_PREFIX;
	end EstBoutonCase;


	procedure RecupBoutonCasePosition(nom: in String; ligne: out T_Lig; col: out T_Col) is
		-- {nom doit être le nom d'un bouton case valide} => {ligne et col sont défini à la position du bouton}
		ligne_brut: String := nom(BC_PREFIX_LEN+2..BC_PREFIX_LEN+3);
		col_brut: character := nom(BC_PREFIX_LEN+1); -- Ne pas oublier que la colonne est placé avant la ligne
	begin
		ligne := T_Lig'Value(ligne_brut);
		col := col_brut;
	end RecupBoutonCasePosition;

	-- Constantes pour les noms des boutons
	BOUTON_DIR_CASE: constant String := "bouton_dir_case";
	BOUTON_DIR_BG: constant String := "bouton_dir_bg";
	BOUTON_DIR_HG: constant String := "bouton_dir_hg";
	BOUTON_DIR_BD: constant String := "bouton_dir_bd";
	BOUTON_DIR_HD: constant String := "bouton_dir_hd";
	BOUTON_JEU_QUITTER: constant String := "bouton_jeu_quitter";
	BOUTON_JEU_RECOMMENCER: constant String := "bouton_jeu_recommencer";
	BOUTON_JEU_REGLES: constant String := "bouton_jeu_regles";
	TEXTE_JEU_ERREURS: constant String := "texte_jeu_erreurs";
	BOUTON_JEU_ANNULER: constant String := "bouton_jeu_annuler";

	procedure CreerFenetreJeu(fen: out TR_Fenetre) is
		-- {} => {Création de la fenêtre de jeu}
		x, y : integer;
		larg_b : constant integer := 50;
		haut_b : constant integer := 50;
	begin

		x := 10;
		y := 10;

		fen := DebutFenetre("Anti-Virus - Partie en cours", 460, 550);

		for col in T_Col'Range loop

			x := x + larg_b;
			AjouterTexte(fen, "nom_col_" & col, col & "", x, y, larg_b, haut_b);
			ChangerAlignementTexte(fen, "nom_col_" & col, FL_ALIGN_CENTER);

		end loop;

		x := 10;
		y := y + haut_b;

		for ligne in T_Lig'Range loop

			AjouterTexte(fen, "nom_ligne_" & integer'image(ligne), integer'image(ligne) & "", x + 10, y, larg_b, haut_b);
			x := x + larg_b;

			for col in T_Col'Range loop

				if COLONNE_INDICES(col) mod 2 = ligne mod 2 then
					AjouterBouton(fen, RecupBoutonCaseName(ligne, col), "", x, y, larg_b, haut_b);
				end if;

				x := x + larg_b;

			end loop;

			x := 10;
			y := y + haut_b;

		end loop;

		-- Le bouton au centre des bouton de direction servant à savoir quelle couleur on veut bouger.
		AjouterBouton(fen, BOUTON_DIR_CASE, "", 215, 462, 30, 30);
		ChangerEtatBouton(fen, BOUTON_DIR_CASE, ARRET);

		-- Ajout des boutons de direction avec leurs images
		AjouterBoutonImage(fen, BOUTON_DIR_BG, "", "fleche_bg.xpm", 185, 483, 40, 40);
		AjouterBoutonImage(fen, BOUTON_DIR_HG, "", "fleche_hg.xpm", 185, 433, 40, 40);
		AjouterBoutonImage(fen, BOUTON_DIR_BD, "", "fleche_bd.xpm", 235, 483, 40, 40);
		AjouterBoutonImage(fen, BOUTON_DIR_HD, "", "fleche_hd.xpm", 235, 433, 40, 40);

		ChangerCouleurFond(fen, BOUTON_DIR_BG, FL_WHITE);
		ChangerCouleurFond(fen, BOUTON_DIR_HG, FL_WHITE);
		ChangerCouleurFond(fen, BOUTON_DIR_BD, FL_WHITE);
		ChangerCouleurFond(fen, BOUTON_DIR_HD, FL_WHITE);

		-- Boutons de gestion de partie
		AjouterBouton(fen, BOUTON_JEU_RECOMMENCER, "Recommencer", 25, 432, 120, 24);
		AjouterBouton(fen, BOUTON_JEU_QUITTER, "Quitter", 25, 466, 120, 24);
		AjouterBouton(fen, BOUTON_JEU_REGLES, "Regles", 25, 500, 120, 24);

		-- Ajout du texte du status de la partie (nb_erreur et nb_deplacements)
		AjouterTexte(fen, TEXTE_JEU_ERREURS, "", 290, 430, 140, 40);
		ChangerAlignementTexte(fen, TEXTE_JEU_ERREURS, FL_ALIGN_CENTER);

		-- Ajout du bouton pour annuler le dernier déplacement
		AjouterBouton(fen, BOUTON_JEU_ANNULER, "Annuler", 300, 480, 120, 24);

		FinFenetre(fen);

	end CreerFenetreJeu;


	procedure JeuAfficherGrille(fen: in out TR_Fenetre; grille: in TV_Grille; info_partie: in TR_InfoPartie) is
		-- {} => {Défini les couleurs des cases}
		coul: T_coul;
	begin

		CacherElem(fen, BOUTON_DIR_CASE);
		CacherElem(fen, BOUTON_DIR_BG);
		CacherElem(fen, BOUTON_DIR_HG);
		CacherElem(fen, BOUTON_DIR_BD);
		CacherElem(fen, BOUTON_DIR_HD);

		ChangerTexte(fen, TEXTE_JEU_ERREURS, "Nombre d'erreurs :" & integer'Image(info_partie.nb_erreurs) & NEW_LINE & "Deplacements :" & integer'Image(info_partie.nb_deplacements));

		for ligne in T_Lig'Range loop
			for col in T_Col'Range loop

				coul := grille(ligne, col);
				MontrerElem(fen, RecupBoutonCaseName(ligne, col));
				ChangerCouleurFond(fen, RecupBoutonCaseName(ligne, col), COULEURS_FENETRES(coul));

				-- On laisse activé seulement les cases possible au déplacement.
				if coul = vide or coul = blanc then
					ChangerEtatBouton(fen, RecupBoutonCaseName(ligne, col), ARRET);
				else
					ChangerEtatBouton(fen, RecupBoutonCaseName(ligne, col), MARCHE);
				end if;

			end loop;
		end loop;

	end JeuAfficherGrille;


	procedure JeuAutoriserAnnuler(fen: in out TR_Fenetre; autoriser: in boolean) is
	-- {} => {Affiche ou non le bouton pour annuler le dernier déplacement selon 'autoriser'}
	begin

		if autoriser then
			MontrerElem(fen, BOUTON_JEU_ANNULER);
		else
			CacherElem(fen, BOUTON_JEU_ANNULER);
		end if;

	end JeuAutoriserAnnuler;


	function JeuBoutonEstClicCouleur(nom_bouton: in String; ligne: out T_Lig; col: out T_Col) return boolean is
		-- {} => {Si le nom_bouton est celui d'une case couleur, alors ligne et col sont défini et True est retourné}
	begin

		if EstBoutonCase(nom_bouton) then
			RecupBoutonCasePosition(nom_bouton, ligne, col);
			return true;
		else
			return false;
		end if;

	end JeuBoutonEstClicCouleur;


	procedure JeuSelectCouleurs(fen: in out TR_Fenetre; grille: in TV_Grille; couleur: T_coul) is
		-- {} => {Affiche les boutons directionnel pour la couleur}
	begin

		ChangerCouleurFond(fen, BOUTON_DIR_CASE, COULEURS_FENETRES(couleur));
		MontrerElem(fen, BOUTON_DIR_CASE);
		MontrerElem(fen, BOUTON_DIR_BG);
		MontrerElem(fen, BOUTON_DIR_HG);
		MontrerElem(fen, BOUTON_DIR_BD);
		MontrerElem(fen, BOUTON_DIR_HD);

	end JeuSelectCouleurs;


	function JeuBoutonEstDirection(nom_bouton: in String; dir: out T_Direction) return boolean is
		-- {} => {Si le bouton est un bouton de direction, dir est mis à jour et True est retourné}
	begin

		if nom_bouton = BOUTON_DIR_BG then
			dir := bg;
		elsif nom_bouton = BOUTON_DIR_HG then
			dir := hg;
		elsif nom_bouton = BOUTON_DIR_BD then
			dir := bd;
		elsif nom_bouton = BOUTON_DIR_HD then
			dir := hd;
		else
			return false;
		end if;

		return true;

	end JeuBoutonEstDirection;


	function JeuBoutonEstRecommencer(nom_bouton: in String) return boolean is
		-- {} => {Retourne True si le nom du bouton est celui de recommencer}
	begin
		return nom_bouton = BOUTON_JEU_RECOMMENCER;
	end JeuBoutonEstRecommencer;


	function JeuBoutonEstQuitter(nom_bouton: in String) return boolean is
		-- {} => {Retourne True si le nom du bouton est celui de quitter}
	begin
		return nom_bouton = BOUTON_JEU_QUITTER;
	end JeuBoutonEstQuitter;


	function JeuBoutonEstRegles(nom_bouton: in String) return boolean is
		-- {} => {Retourne True si le nom du bouton est celui de Règles}
	begin
		return nom_bouton = BOUTON_JEU_REGLES;
	end JeuBoutonEstRegles;


	function JeuBoutonEstAnnuler(nom_bouton: in String) return boolean is
		-- {} => {Retourne True si le nom du bouton est celui de Annuler (le dernier voup)}
	begin
		return nom_bouton = BOUTON_JEU_ANNULER;
	end JeuBoutonEstAnnuler;


	-----------------
	-- FENETRE FIN --
	-----------------

	BOUTON_FIN_QUITTER: String := "fin_quitter";
	TEXTE_FIN_STATS: String := "fin_stats";
	MAX_TAILLE_HISTORIQUE: integer := 3;

	function RecupNomLigneHistorique(i: in integer) return String is
	begin
		return "historique_ligne_" & integer'Image(i);
	end RecupNomLigneHistorique;

	procedure CreerFenetreFin(fen : out TR_Fenetre) is
		-- {} => {Création de la fenetre de congratulation de fin de partie}
		y: integer;
	begin
		fen := DebutFenetre("Anti-Virus - Felicitations", 480, 600);

		AjouterTexte(fen, "felecitations_titre",
			"FELICITATIONS,"
			& NEW_LINE &
			"VOUS AVEZ GAGNE !",
			25, 5, 430, 100);

		ChangerTailleTexte(fen, "felecitations_titre", 30);
		ChangerAlignementTexte(fen, "felecitations_titre", FL_ALIGN_CENTER);
		ChangerStyleTexte(fen, "felecitations_titre", FL_TIMESBOLD_STYLE);

		AjouterImage(fen, "felicitations_image1", "trumpet_boi_left.xpm", "", 5, 110, 155, 417);

		AjouterImage(fen, "felicitations_image2", "trumpet_boi_right.xpm", "", 320, 110, 155, 417);

		AjouterTexte(fen, TEXTE_FIN_STATS, "", 140, 120, 200, 100);
		ChangerAlignementTexte(fen, TEXTE_FIN_STATS, FL_ALIGN_CENTER);

		AjouterTexte(fen, "felecitations_classement", "CLASSEMENT", 160, 250, 160, 20);
		ChangerTailleTexte(fen, "felecitations_classement", 15);
		ChangerAlignementTexte(fen, "felecitations_classement", FL_ALIGN_CENTER);
		ChangerStyleTexte(fen, "felecitations_classement", FL_TIMESBOLD_STYLE);

		y := 280;
		for i in 1..MAX_TAILLE_HISTORIQUE loop

			AjouterTexte(fen, RecupNomLigneHistorique(i), "", 160, y, 160, 70);
			ChangerAlignementTexte(fen, RecupNomLigneHistorique(i), FL_ALIGN_CENTER);

			y := y + 80;

		end loop;

		AjouterBouton(fen, BOUTON_FIN_QUITTER, "Quitter", 140, 530, 200, 40);

		FinFenetre(fen);

	end CreerFenetreFin;


	procedure FinAfficherStats(fen : in out TR_Fenetre; info_partie: in TR_InfoPartie; historique: in TV_Parties) is
		-- {} => {Affichage des stats de la partie}
		suffix_err: character := ' ';
		meilleur_parties: TV_Parties := RecupMeilleursPartiesNiveau(historique, info_partie.niveau, MAX_TAILLE_HISTORIQUE);
	begin

		if info_partie.nb_erreurs > 1 then
			suffix_err := 's';
		end if;

		ChangerTexte(fen, TEXTE_FIN_STATS,
			info_partie.pseudo(1..info_partie.taille_pseudo) & "," & NEW_LINE & "voici vos stats :"
			& NEW_LINE
			& NEW_LINE
			&
			"Temps partie :" & integer'Image(info_partie.duree_partie) & "s"
			& NEW_LINE
			&
			"Deplacements :" & integer'Image(info_partie.nb_deplacements)
			& NEW_LINE
			&
			"Erreur" & suffix_err & " :" & integer'Image(info_partie.nb_erreurs)
		);

		for i in 1..3 loop

			if i in meilleur_parties'Range then

				ChangerTexte(fen, RecupNomLigneHistorique(i),
					"Num" & integer'Image(i) & " : "
					& NEW_LINE
					& "> " & meilleur_parties(i).pseudo(1..meilleur_parties(i).taille_pseudo) & " <"
					& NEW_LINE
					& "Deplacements : " & integer'image(meilleur_parties(i).nb_deplacements)
					& NEW_LINE
					& "Temps : " & integer'image(meilleur_parties(i).duree_partie) & "s"
				);

			else
				ChangerTexte(fen, RecupNomLigneHistorique(i), "");
			end if;

		end loop;

	end FinAfficherStats;


	function FinBoutonEstQuitter(nom_bouton: in String) return boolean is
		-- {} => {True si le nom_bouton est le bouton Quitter}
	begin
		return nom_bouton = BOUTON_FIN_QUITTER;
	end FinBoutonEstQuitter;


	----------------
	-- EXTENTIONS --
	----------------

	-- Constantes pour les noms des boutonss
	BOUTON_REGLES_QUITTER: constant String := "regles_quitter";

	procedure CreerFenetreRegles(fen : out TR_Fenetre) is
		-- {} => {Création de la fenêtre des règles}
	begin
		fen := DebutFenetre("Regles", 440, 440);
		AjouterTexte(fen,"Regles_Titre", "Regles",5, 5, 430, 70);
		ChangerTailleTexte(fen, "Regles_Titre", 30);
		ChangerAlignementTexte(fen, "Regles_Titre", FL_ALIGN_CENTER);
		ChangerStyleTexte(fen, "Regles_Titre", FL_TIMESBOLD_STYLE);

		AjouterTexte(fen,"Regles_L",
			"Objectif : sortir le virus (en rouge) de la cellule en le placant en haut " & NEW_LINE & "a gauche du plateau en un minimum de coups."
				& NEW_LINE
				& NEW_LINE
				&
				"Niveaux : il y a un total de 20 niveaux, de difficulte croissante."
				& NEW_LINE
				& NEW_LINE
				&
				"Obstacles : des molecules sont presentes dans la cellule et genent" & NEW_LINE & "le deplacement du virus."
				& NEW_LINE
				& NEW_LINE
				&
				"Comment jouer ? " & NEW_LINE & "Cliquez sur le virus ou une molecule pour la selectionner, puis" & NEW_LINE & "cliquez sur une des fleches directionnelles qui apparaitront en bas" & NEW_LINE & "pour la deplacer. La couleur selectionnee s affiche au milieu des" & NEW_LINE & "fleches directionnelles."
				& NEW_LINE
				& NEW_LINE
				&
				"Contraintes :"
				& NEW_LINE
				&
				" - Les pieces ne sont deplacables qu en diagonale et ne peuvent " & NEW_LINE & "pas pivoter."
				& NEW_LINE
				&
				" - Les pieces blanches ne sont pas deplacables"
			,5, 70, 430, 300);

		AjouterBouton(fen, BOUTON_REGLES_QUITTER, "Quitter", 120, 380, 200, 40);

		FinFenetre(fen);

	end CreerFenetreRegles;

	function ReglesBoutonEstQuitter(nom_bouton: in String) return boolean is
		-- {} => {Retourne True si nom_bouton est celui de Quitter}
	begin
		return nom_bouton = BOUTON_REGLES_QUITTER;
	end ReglesBoutonEstQuitter;

end p_vue_graph;
