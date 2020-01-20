with p_vue_graph, p_fenbase, text_io;
use p_vue_graph, p_fenbase, text_io;

procedure av_graph is

	fenetre_accueil: TR_Fenetre;
	fenetre_jeu: TR_Fenetre;
	etat: T_Etat;

	procedure Quitter is
	begin
		etat := QUITTER;
	end Quitter;

	procedure Jouer is
	begin

		etat := EN_COURS;
		CacherFenetre(fenetre_accueil);
		MontrerFenetre(fenetre_jeu);

	end Jouer;

	procedure Accueil is
	begin

		etat := ACCUEIL;
		MontrerFenetre(fenetre_accueil);
		CacherFenetre(fenetre_jeu);

	end Accueil;

	temp: boolean;

begin

	InitialiserFenetres;

	CreerFenetreAccueil(fenetre_accueil);
	CreerFenetreJeu(fenetre_jeu);

	Accueil;

	while etat /= QUITTER loop

		if etat = ACCUEIL then

			if AccueilEstValide(fenetre_accueil) then
				Jouer;
			else
				Quitter;
			end if;

		elsif etat = EN_COURS then
			temp := true;
		end if;

	end loop;

end av_graph;
