with p_virus, text_io;
use p_virus, text_io;

procedure testjeu is


	use p_int_io;
	use p_piece_io;
	use p_coul_io;
	use p_dir_io;

	f: p_piece_io.file_type;

	numconf: integer range 1..20;
	grille: TV_Grille;
	pieces: TV_Pieces;

	coul : T_CoulP;
	dir : T_Direction;

begin

	InitPartie(grille, pieces);
	put("Quel est le numéro de la configuration que vous voulez charger (de 1 à 20) ? : ");
	loop
		begin
			get(numconf);
			exit;
		exception
		  when CONSTRAINT_ERROR => put("Numéro de configuration invalide. Ressayez : ");
		end;
	end loop;

	new_line;
	put_line("Configuration ...");
	open(f, in_file, "Parties");
	Configurer(f, numconf, grille, pieces);

	new_line;
	put_line("Position des pièces :");
	for coul in pieces'Range loop
		if pieces(coul) then
			PosPiece(grille, coul);
		end if;
	end loop;

	new_line;
	put("Quelle est la couleur de la pièce que vous voulez déplacer ? : ");
	get(coul);
	put("Dans quelle direction la deplacer ? (bg / hg / bd / hd) : ");
	get(dir);
	if Possible(grille,coul,dir) then

		MajGrille(grille, coul, Dir);

		new_line;
		put("Nouvelle position de la pièce ");
		put(coul);
		put_line(" :");
		PosPiece(grille, coul);

		Configurer(f, numconf, grille, pieces);

	else
		put_line("Impossible :(");
	end if;

end testjeu;
