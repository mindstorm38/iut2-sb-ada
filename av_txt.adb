with text_io, p_virus, p_vuetxt;
use text_io, p_virus, p_vuetxt;

with ada.io_exceptions;

procedure av_txt is
  --{} => {}

	use p_int_io;
	use p_piece_io;
	use p_coul_io;
	use p_dir_io;

	f: p_piece_io.file_type;

	numconf: integer range 1..20; --Numero de la configuration
	grille: TV_Grille;
	pieces: TV_Pieces;

	coul : T_CoulP;               --Couleur dont l utilisateur demande le deplacement
	dir : T_Direction;            --Direction que va prendre coul

begin -- av_txt

	InitPartie(grille, pieces);
	put("Quel est le numéro de la configuration que vous voulez charger (de 1 à 20) ? ");
	loop
		begin
			get(numconf);
			exit;
		exception
			when CONSTRAINT_ERROR => put("Numéro de configuration invalide. Ressayez : ");
		end;
	end loop;

	new_line;
	put_line("Configuration en cours...");
	open(f, in_file, "Parties");
	Configurer(f, numconf, grille, pieces);
	put_line("Configuration terminée. Début de la partie.");

	new_line;

	put_line("Pour rappel, voici le numéro des couleurs :");
	for coul in T_CoulP'Range loop
		put(coul);
		put(": ");
		put(T_CoulP'Pos(coul), 0);
		new_line;
	end loop;

	new_line;
	while not Guerison(grille) loop

		put_line("Voici le plateau actuel : ");
		new_line;
		AfficheGrille(grille);

		new_line;
		loop
			begin

				put("Quelle est la couleur de la pièce que vous voulez déplacer ? ");
				get(coul);

				if pieces(coul) then
					exit;
				else
					put_line("Cette couleur n'est pas présente !");
				end if;

			exception
				when ADA.IO_EXCEPTIONS.DATA_ERROR =>
					put_line("Erreur : la couleur entrée est inconnue. Veuillez entrer une de ces couleurs : ");
					put_line("rouge / turquoise / orange / rose / marron / bleu / violet / vert / jaune / blanc");
			end;
		end loop;

		loop
			begin
				put("Dans quelle direction déplacer la couleur ? ");
				get(dir);
				exit;
			exception
			  when ADA.IO_EXCEPTIONS.DATA_ERROR =>
					put_line("Erreur : la direction entrée est inconnue. Veuillez entrer une de ces directions : ");
					put_line("bg / hg / bd / hd");
			end;
		end loop;
		if Possible(grille,coul,dir) then
			MajGrille(grille, coul, Dir);
		else
			put("Impossible de deplacer cette couleur dans cette direction.");
		end if;

	end loop;

	new_line;

	put_line("Voici le plateau actuel : ");
	new_line;
	AfficheGrille(grille);

	put_line("FELICITATION VOUS AVEZ GAGNE !");

end av_txt;
