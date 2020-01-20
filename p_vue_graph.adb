with p_fenbase, forms, text_io, p_virus;
use p_fenbase, forms, text_io, p_virus;

package body p_vue_graph is


	---------------------
	-- FENETRE ACCUEIL --
	---------------------

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

		-- Message optionel
		AjouterTexte(fen, "accueil_message", "", 80, 250, 320, 20);
		ChangerAlignementTexte(fen, "accueil_message", FL_ALIGN_CENTER);
		ChangerCouleurTexte(fen, "accueil_message", FL_RED);
		CacherElem(fen, "accueil_message");

		-- Boutons
		AjouterBouton(fen, "accueil_valider", "Valider", 80, 300, 150, 40, FL_RETURN_BUTTON);
		AjouterBouton(fen, "accueil_quitter", "Quitter", 250, 300, 150, 40);

		FinFenetre(fen);

	end CreerFenetreAccueil;

	function AccueilRecupInfos(fen: in TR_Fenetre; niveau_max: in positive) return TR_InfoPartie is
		-- {} => {Retour l'information sur la partie à partir des informations entrées}
		pseudo_brut: String := ConsulterContenu(fen, "accueil_pseudo");
		niveau_brut: String := ConsulterContenu(fen, "accueil_niveau");
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
				return (pseudo, niveau, pseudo_brut'Length);

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

			MontrerElem(fen, "accueil_message");
			ChangerTexte(fen, "accueil_message", message);

		else
			CacherElem(fen, "accueil_message");
		end if;

	end AccueilAfficherMessage;

	function AccueilEstValide(fen: in TR_Fenetre) return boolean is
		-- {} => {True si l'evennement de la fenetre accueil est valide}
		str: String := AttendreBouton(fen);
	begin
		return str = "accueil_valider" or str = "accueil_pseudo" or str = "accueil_niveau";
	end AccueilEstValide;


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




	procedure CreerFenetreJeu(fen: out TR_Fenetre) is
	-- {} => {Création de la fenêtre de jeu}
		x, y : integer;
		larg_b : constant integer := 50;
		haut_b : constant integer := 50;

	begin
		x := 10;
		y := 10;
		fen := DebutFenetre("Jeu", 440, 440);

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
					AjouterBouton(fen, RecupBoutonCaseName(ligne, col), "" & col & T_Lig'image(ligne), x, y, larg_b, haut_b);
				end if;

				x := x + larg_b;

			end loop;

			x := 10;
			y := y + haut_b;

		end loop;

		FinFenetre(fen);

	end CreerFenetreJeu;

	procedure JeuAfficherGrille(fen: in out TR_Fenetre; grille: in TV_Grille) is
		-- {} => {Défini les couleurrs des cases}
		coul: T_coul;
	begin

		for ligne in T_Lig'Range loop
			for col in T_Col'Range loop

				coul := grille(ligne, col);
				ChangerCouleurFond(fen, RecupBoutonCaseName(ligne, col), COULEURS_FENETRES(coul));

			end loop;
		end loop;

	end JeuAfficherGrille;

	function JeuAttendreClicCouleur(fen: in TR_Fenetre; ligne: out T_Lig; col: out T_Col) return boolean is
		-- {} => {Attend que l'utilisateur clic sur une case de couleur}
		str: String := AttendreBouton(fen);
	begin

		if EstBoutonCase(str) then
			RecupBoutonCasePosition(str, ligne, col);
			return true;
		else
			return false;
		end if;

	end JeuAttendreClicCouleur;


end p_vue_graph;
