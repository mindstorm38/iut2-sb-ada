with p_virus;
use p_virus;

package p_vuetxt is

	-- Type vecteur uniquement pour les code d'échappement ANSI pour l'affichage en couleurs dans le terminal.
	type TV_CouleurANSI is array (T_CoulP) of String(1..10);
	COULEUR_ANSI: constant TV_CouleurANSI := ("[38;5;196m", "[38;5;033m", "[38;5;202m", "[38;5;206m", "[38;5;052m", "[38;5;021m", "[38;5;055m", "[38;5;028m", "[38;5;220m", "[38;5;231m");
	RESET_ANSI: constant String := "[0m";

	procedure AfficheGrille(grille: in TV_Grille);
		-- {} => {la grille a été affichée selon les spécifications suivantes :
		--        * la sortie estindiquée par la lettre S
		--        * une case inactive ne contient aucun caractère
		--        * une case de couleur vide contientun point
		--        * une case de couleur blanchecontientle caractère F (Fixe)
		--        * une case de la couleur d’une pièce mobilecontientle chiffre correspondant à la
		--          position de cettecouleur dans le type T_Coul}

end p_vuetxt;
