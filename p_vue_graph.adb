with p_fenbase, forms, text_io;
use p_fenbase, forms, text_io;

package body p_vue_graph is

	procedure CreerFenetreAccueil(fen: out TR_Fenetre) is
		-- {} => {Création de la fenetre avec ses boutons}
	begin

		fen := DebutFenetre("Accueil", 480, 360);

		-- Titre
		AjouterTexte(fen, "accueil_titre", "Anti-Virus - Accueil", 20, 30, 440, 40);
		ChangerTailleTexte(fen, "accueil_titre", 30);
		ChangerAlignementTexte(fen, "accueil_titre", FL_ALIGN_CENTER);
		ChangerStyleTexte(fen, "accueil_titre", FL_TIMESBOLD_STYLE);

		-- Champs pseudo
		AjouterTexte(fen, "accueil_pseudo_label", "Votre pseudo", 80, 100, 320, 20);
		ChangerAlignementTexte(fen, "accueil_pseudo_label", FL_ALIGN_CENTER);

		AjouterChamp(fen, "accueil_pseudo", "", "Nouveau joueur", 80, 125, 320, 40);

		-- Partie à jouer
		AjouterTexte(fen, "accueil_niveau_label", "Niveau de la partie", 80, 175, 320, 20);
		ChangerAlignementTexte(fen, "accueil_niveau_label", FL_ALIGN_CENTER);

		AjouterChamp(fen, "accueil_niveau", "", "1", 80, 200, 320, 40);

		-- Boutons
		AjouterBouton(fen, "accueil_valider", "Valider", 80, 260, 150, 40, FL_RETURN_BUTTON);
		AjouterBouton(fen, "accueil_quitter", "Quitter", 250, 260, 150, 40);

		FinFenetre(fen);

	end CreerFenetreAccueil;

	procedure CreerFenetreJeu(fen: out TR_Fenetre) is
		-- {} => {Création de la fenêtre de jeu}
	begin

		fen := DebutFenetre("Jeu", 480, 360);
		AjouterTexte(fen,"Noms_Colonnes","A B C D E F",30,30,100,20);
		AjouterTexte(fen,"Noms_Lignes",'1' & Character'Val (10) & '2' & Character'Val (10) & '3' & Character'Val (10) & '4' & Character'Val (10) & '5' & Character'Val (10) & '6' & Character'Val (10),30,30,20,120);

		FinFenetre(fen);

	end CreerFenetreJeu;

	function AccueilEstValide(fen: in TR_Fenetre) return boolean is
		-- {} => {True si l'evennement de la fenetre accueil est valide}
	begin
		return AttendreBouton(fen) = "accueil_valider";
	end AccueilEstValide;

end p_vue_graph;
