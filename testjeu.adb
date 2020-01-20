--with p_virus; use p_virus;
with text_io; use text_io;



procedure testjeu is
  --{} => {}
	package p_int_io is new integer_io(integer);
	use p_int_io;
	numconf : integer range 1..20;
	grille : TV_Grille;
	Pieces : TV_Pieces;
begin -- testjeu
	InitPartie(grille,pieces);
	put("Quel est le numéro de la configuration que vous voulez charger ? : ");
	get(numconf);
end testjeu;
