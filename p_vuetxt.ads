with p_virus;
use p_virus;

package p_vuetxt is

	procedure AfficheGrille(grille: in TV_Grille);
		-- {} => {la grille a été affichée selon les spécifications suivantes :
		--        * la sortie estindiquée par la lettre S
		--        * une case inactive ne contient aucun caractère
		--        * une case de couleur vide contientun point
		--        * une case de couleur blanchecontientle caractère F (Fixe)
		--        * une case de la couleur d’une pièce mobilecontientle chiffre correspondant à la
		--          position de cettecouleur dans le type T_Coul}

end p_vuetxt;
