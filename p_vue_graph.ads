with p_fenbase, forms, p_virus;
use p_fenbase, forms, p_virus;

package p_vue_graph is

	type T_Etat is (ACCUEIL, REGLES, SELECTION_CASE, SELECTION_DIR, SUCCES, QUITTER);
	subtype T_EtatEnJeu is T_Etat range SELECTION_CASE..SELECTION_DIR;

	subtype T_Pseudo is String(1..100);

	type TR_InfoPartie is record
		pseudo: T_Pseudo;
		niveau: integer;
		taille_pseudo: integer;
		nb_erreurs: integer;
		nb_deplacements: integer;
	end record;

	INFO_PARTIE_ERREUR: exception;

	-- Mapping des couleurs du package p_virus vers les couleurs des fenêtres
	type TV_CouleurFenetre is array(T_Coul) of T_Couleur;
	COULEURS_FENETRES: constant TV_CouleurFenetre := (FL_RED, FL_CYAN, FL_DARKORANGE, FL_MAGENTA, FL_DARKTOMATO, FL_DODGERBLUE, FL_DARKVIOLET, FL_CHARTREUSE, FL_YELLOW, FL_WHITE, FL_INACTIVE);

	-- FENETRE ACCUEIL

	procedure CreerFenetreAccueil(fen: out TR_Fenetre);
		-- {} => {Création de la fenetre d'accueil avec ses boutons}

	function AccueilRecupInfos(fen: in TR_Fenetre; niveau_max: in positive) return TR_InfoPartie;
		-- {} => {Retour l'information sur la partie à partir des informations entrées, et affiche des erreurs si les champs sont invalide}

	procedure AccueilAfficherMessage(fen: in out TR_Fenetre; message: in String);
		-- {} => {Un message a été affiché}

	function AccueilBoutonEstQuitter(nom_bouton: in String) return boolean;
		-- {} => {True si le nom de bouton est la bouton quitter}

	function AccueilBoutonEstValider(nom_bouton: in String) return boolean;
		-- {} => {True si le nom de bouton est le bouton valider}

	function AccueilBoutonEstRegles(nom_bouton: in String) return boolean;
		-- {} => {True si le nom de bouton est le bouton règles}

	-- FENETRE JEU

	procedure CreerFenetreJeu(fen: out TR_Fenetre);
		-- {} => {Création de la fenêtre de jeu}

	procedure JeuAfficherGrille(fen: in out TR_Fenetre; grille: in TV_Grille; info_partie: in TR_InfoPartie);
		-- {} => {Défini les couleurs des cases}

	function JeuBoutonEstClicCouleur(nom_bouton: in String; ligne: out T_Lig; col: out T_Col) return boolean;
		-- {} => {Si le nom_bouton est celui d'une case couleur, alors ligne et col sont défini et True est retourné}

 	procedure JeuSelectCouleurs(fen: in out TR_Fenetre; grille: in TV_Grille; couleur: T_coul);
		-- {} => {Affiche les boutons directionnel pour la couleur}

	function JeuBoutonEstDirection(nom_bouton: in String; dir: out T_Direction) return boolean;
		-- {} => {Si le bouton est un bouton de direction, dir est mis à jour et True est retourné}

	function JeuBoutonEstRecommencer(nom_bouton: in String) return boolean;
		-- {} => {Retourne True si le nom du bouton est celui de recommencer}

	function JeuBoutonEstQuitter(nom_bouton: in String) return boolean;
		-- {} => {Retourne True si le nom du bouton est celui de quitter}

	function JeuBoutonEstRegles(nom_bouton: in String) return boolean;
		-- {} => {Retourne True si le nom du bouton est celui de Règles}

	----------------
	-- EXTENTIONS --
	----------------

	procedure CreerFenetreRegles(fen : out TR_Fenetre);
		-- {} => {Création de la fenêtre des règles}

	function ReglesBoutonEstQuitter(nom_bouton: in String) return boolean;
		-- {} => {Retourne True si nom_bouton est celui de Quitter}


end p_vue_graph;
