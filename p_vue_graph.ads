with p_fenbase, forms;
use p_fenbase, forms;

package p_vue_graph is

	type T_Etat is (ACCUEIL, EN_COURS, SUCCES, QUITTER);

	procedure CreerFenetreAccueil(fen: out TR_Fenetre);
		-- {} => {Création de la fenetre d'accueil avec ses boutons}

	procedure CreerFenetreJeu(fen: out TR_Fenetre);
		-- {} => {Création de la fenêtre de jeu}

	function AccueilEstValide(fen: in TR_Fenetre) return boolean;
		-- {} => {True si l'evennement de la fenetre accueil est valide}

end p_vue_graph;
