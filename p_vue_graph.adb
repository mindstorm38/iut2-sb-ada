with p_fenbase, forms, text_io, p_virus;
use p_fenbase, forms, text_io, p_virus;

package body p_vue_graph is


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
				return (pseudo, niveau, pseudo_brut'Length, 0, 0);

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

		AjouterBouton(fen, BOUTON_DIR_CASE, "", 215, 462, 30, 30);
		ChangerEtatBouton(fen, BOUTON_DIR_CASE, ARRET);

		AjouterBoutonImage(fen, BOUTON_DIR_BG, "", "fleche_bg.xpm", 185, 483, 40, 40);
		AjouterBoutonImage(fen, BOUTON_DIR_HG, "", "fleche_hg.xpm", 185, 433, 40, 40);
		AjouterBoutonImage(fen, BOUTON_DIR_BD, "", "fleche_bd.xpm", 235, 483, 40, 40);
		AjouterBoutonImage(fen, BOUTON_DIR_HD, "", "fleche_hd.xpm", 235, 433, 40, 40);

		ChangerCouleurFond(fen, BOUTON_DIR_BG, FL_WHITE);
		ChangerCouleurFond(fen, BOUTON_DIR_HG, FL_WHITE);
		ChangerCouleurFond(fen, BOUTON_DIR_BD, FL_WHITE);
		ChangerCouleurFond(fen, BOUTON_DIR_HD, FL_WHITE);

		AjouterBouton(fen, BOUTON_JEU_RECOMMENCER, "Recommencer", 25, 432, 120, 24);
		AjouterBouton(fen, BOUTON_JEU_QUITTER, "Quitter", 25, 466, 120, 24);
		AjouterBouton(fen, BOUTON_JEU_REGLES, "Regles", 25, 500, 120, 24);

		AjouterTexte(fen, TEXTE_JEU_ERREURS, "", 290, 430, 140, 30);
		ChangerAlignementTexte(fen, TEXTE_JEU_ERREURS, FL_ALIGN_CENTER);

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

		ChangerTexte(fen, TEXTE_JEU_ERREURS, "Nombre d'erreurs :" & integer'Image(info_partie.nb_erreurs));

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

		for ligne in T_Lig'Range loop
			for col in T_Col'Range loop
				ChangerEtatBouton(fen, RecupBoutonCaseName(ligne, col), ARRET);
			end loop;
		end loop;

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

	----------------
	-- EXTENTIONS --
	----------------

	-- Constantes pour les noms des boutonss
	BOUTON_REGLES_QUITTER: constant String := "regles_quitter";

	procedure CreerFenetreRegles(fen : out TR_Fenetre) is
		-- {} => {Création de la fenêtre des règles}
		NewLine : constant Character := Character'Val (10); --retour chariot

	begin
		fen := DebutFenetre("Regles", 440, 440);
		AjouterTexte(fen,"Regles_Titre", "Regles",5, 5, 430, 70);
		ChangerTailleTexte(fen, "Regles_Titre", 30);
		ChangerAlignementTexte(fen, "Regles_Titre", FL_ALIGN_CENTER);
		ChangerStyleTexte(fen, "Regles_Titre", FL_TIMESBOLD_STYLE);

		AjouterTexte(fen,"Regles_L",
			"Objectif : sortir le virus (en rouge) de la cellule en le placant en haut " & NewLine & "a gauche du plateau en un minimum de coups."
				& NewLine
				& NewLine
				&
				"Niveaux : il y a un total de 20 niveaux, de difficulte croissante."
				& NewLine
				& NewLine
				&
				"Obstacles : des molecules sont presentes dans la cellule et genent" & NewLine & "le deplacement du virus."
				& NewLine
				& NewLine
				&
				"Comment jouer ? " & NewLine & "Cliquez sur le virus ou une molecule pour la selectionner, puis" & NewLine & "cliquez sur une des fleches directionnelles qui apparatront en bas" & NewLine & "pour la deplacer. La couleur selectionnee s affiche au milieu des" & NewLine & "fleches directionnelles."
				& NewLine
				& NewLine
				&
				"Contraintes :"
				& NewLine
				&
				" - Les pieces ne sont deplacables qu en diagonale et ne peuvent " & NewLine & "pas pivoter."
				& NewLine
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
