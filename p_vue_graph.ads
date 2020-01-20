with p_fenbase, forms, p_virus;
use p_fenbase, forms, p_virus;

package p_vue_graph is

	type T_Etat is (ACCUEIL, EN_JEU, SUCCES, QUITTER);
	subtype T_Pseudo is String(1..100);

	type TR_InfoPartie is record
		pseudo: T_Pseudo;
		niveau: integer;
		taille_pseudo: integer;
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

	function AccueilEstValide(fen: in TR_Fenetre) return boolean;
		-- {} => {True si l'evennement de la fenetre accueil est valide}

	-- FENETRE JEU

	procedure CreerFenetreJeu(fen: out TR_Fenetre);
		-- {} => {Création de la fenêtre de jeu}

	procedure JeuAfficherGrille(fen: in out TR_Fenetre; grille: in TV_Grille);
		-- {} => {Défini les couleurrs des cases}

	function JeuAttendreClicCouleur(fen: in TR_Fenetre; grille: in TV_Grille) return T_coul;
		-- {} => {Attend que l'utilisateur clic sur une case de couleur}


end p_vue_graph;
