with X.Strings;
with X.Args;
with X.Xlib;
with System;
with Ada.Unchecked_Conversion;

package  body p_fenbase is
  ------------------------------------------------------------------------------
  -- primitives internes au paquetage
  ------------------------------------------------------------------------------
  procedure AjoutElement (
        Pliste      : in out TA_Element;
        TypeElement :        T_TypeElement;
        NomElement  :        String;
        Texte       :        String;
        Contenu     :        String;
        PElement    :        FL_OBJECT_Access ) is
  begin
    if Pliste=null or else Pliste.NomElement.all>NomElement then
      Pliste:=new TR_Element'(TypeElement, new String'(NomElement),
        new String'(Texte), new String'(Contenu), PElement, Pliste);
    elsif Pliste.NomElement.all<NomElement then
      AjoutElement(Pliste.Suivant, TypeElement, NomElement, Texte, Contenu,
        PElement);
    end if;
  end AjoutElement;
  -----------------------------------------------------------------------------
  function GetElement (
        Pliste     : TA_Element;
        NomElement : String      )
    return TA_Element is
  begin
    if Pliste=null or else Pliste.NomElement.all>NomElement then
      return null;
    elsif Pliste.NomElement.all=NomElement then
      return Pliste;
    else
      return GetElement(Pliste.Suivant,NomElement);
    end if;
  end GetElement;
  -----------------------------------------------------------------------------
  function GetElement (
        Pliste : TA_Element;
        Pobj   : FL_OBJECT_Access )
    return TA_Element is
  begin
    if Pliste=null or else Pliste.Pelement=Pobj then
      return Pliste;
    else
      return GetElement(Pliste.Suivant,Pobj);
    end if;
  end GetElement;
  ------------------------------------------------------------------------------
  -- primitives publiques
  ------------------------------------------------------------------------------
  
  ------------------------------------------------------------------------------
  -- Initialisation du mode graphique, définition fenêtres et groupes d'éléments
	------------------------------------------------------------------------------

	-- initialiser le mode graphique ---------------------------------------------
  procedure InitialiserFenetres is
  begin
    Fl_Initialize( X.Args.Argc'access, X.Args.Argv, null, null, 0 );
  end InitialiserFenetres;

  -- définir une nouvelle fenêtre ----------------------------------------------
  function DebutFenetre (											
        Titre			: in  String;									--	son nom
        Largeur,                                --	sa largeur en pixels
        Hauteur 	: in	Positive)           		--	sa hauteur en pixels
    return TR_Fenetre is                        --  résultat : la fenêtre créée
    F   : TR_Fenetre;
    Obj : FL_OBJECT_Access;
  begin
    F.Pfenetre := Fl_Bgn_Form(FL_NO_BOX, FL_Coord(Largeur), FL_Coord(Hauteur));
    Obj := Fl_Add_Box(FL_UP_BOX,0,0,FL_Coord(Largeur),FL_Coord(Hauteur),null);
    F.Titre   := new String'(Titre);
    F.Pelements:= null;
    AjoutElement(F.PElements, Fond, "fond", "", "",Obj);
    return F;
  end DebutFenetre;

	-- terminer la définition d'une nouvelle fenêtre -----------------------------
  procedure FinFenetre (												-- 	Procédure à appeler quand on a
        F : in     TR_Fenetre ) is							--  fini d'ajouter des éléments
  begin
    Fl_End_Form;
  end;

  -- définir un groupe d'éléments graphiques -----------------------------------
  procedure DebutGroupe (                       
        F          : in out TR_Fenetre;         --  la fenêtre du groupe
        NomGroupe  : in     String ) is					--	le nom du groupe
  begin
    AjoutElement(F.PElements, Groupe, NomGroupe, "", "", Fl_Bgn_Group);
  end DebutGroupe;

   -- terminer un groupe d'éléments --------------------------------------------
  procedure FinGroupe is                         --  clôt le groupe précédemment défini
  begin
    Fl_End_Group;
  end FinGroupe;

  ------------------------------------------------------------------------------
  -- primitives d'ajout d'éléments graphiques dans une fenêtre déjà définie
	------------------------------------------------------------------------------

  -- ajouter un bouton de forme rectangulaire ----------------------------------
  procedure AjouterBouton (                     
        F          : in out TR_Fenetre;         --  la fenêtre où on ajoute
        NomElement : in     String;             --  le nom du bouton (unique)
        Texte      : in     String;             --  le texte affiché dans le bouton
        X,                                      --  abscisse coin HG en pixels
        Y          : in     Natural;            --  ordonnée coin HG en pixels
        Largeur,                                --  largeur du bouton en pixels
        Hauteur    : in     Positive;						-- 	hauteur du bouton en pixels
        TypeBouton : in     FL_Button_Type := FL_NORMAL_BUTTON) is  --  type du bouton (optionnel)
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then
      Obj := Fl_Add_Button(TypeBouton,FL_Coord(X),FL_Coord(Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
      AjoutElement(F.PElements, Bouton, NomElement, Texte, "",Obj);
    end if;
  end AjouterBouton;

  -- ajouter un bouton de forme circulaire -------------------------------------
  procedure AjouterBoutonRond (                 
        F          : in out TR_Fenetre;         --  la fenêtre où on ajoute
        NomElement : in     String;             --  le nom du bouton (unique)
        Texte      : in     String;             --  le texte affiché dans le bouton
        X,                                      --  abscisse coin HG du carré englobant en pixels
        Y          : in     Natural;            --  ordonnée coin HG du carré englobant en pixels
        Diam       : in     Positive    ) is    --  diamètre du bouton en pixels
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then
    Obj :=	Fl_Add_roundButton(FL_NORMAL_BUTTON,FL_Coord(X)-1,FL_Coord(Y-diam/3),
    			FL_Coord(diam*16/10),FL_Coord(diam*16/10),X11.Strings.New_String(Texte));
		AjoutElement(F.PElements, BoutonRond, NomElement, Texte, "",Obj);
    end if;
  end AjouterBoutonRond;

  -- ajouter une boîte à cocher ------------------------------------------------
  procedure AjouterBoiteCocher (                
        F          : in out TR_Fenetre;         --	la fenêtre où on ajoute
        NomElement : in     String;							--	le nom de la boîte à cocher (unique)
        Texte      : in     String;             --  le texte affiché en légende
        X,																			--  abscisse coin HG rectangle englobant en pixels
        Y          : in     Natural;    	      --  ordonnée coin HG rectangle englobant en pixels
        Largeur,																-- 	sa largeur en pixels
        Hauteur    : in     Positive    ) is		--	sa hauteur en pixels
    Obj : FL_OBJECT_Access;
  begin
     if GetElement(F.PElements,NomElement)=null then
      Obj := Fl_Add_Checkbutton(FL_PUSH_BUTTON,FL_Coord(X),FL_Coord(Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
      AjoutElement(F.PElements,CheckBox, NomElement, Texte, "",Obj);
    end if;
  end AjouterBoiteCocher;

	-- ajouter un bouton radio ---------------------------------------------------
  procedure AjouterBoutonRadio (                
        F          : in out TR_Fenetre;         --	la fenêtre où on ajoute
        NomElement : in     String;							--	le nom du bouton radio (unique)
        Texte      : in     String;             --  le texte affiché en légende
        X,																			--  abscisse coin HG du carré englobant en pixels
        Y          : in     Natural;    	      --  ordonnée coin HG du carré englobant en pixels
        Diam			 : in 		Positive;					  -- 	son diamètre en pixels
        Actif      : in     Boolean := false) is-- 	inactivé par défaut
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then
      Obj := Fl_Add_Roundbutton(FL_RADIO_BUTTON,FL_Coord(X),FL_Coord(Y-diam*10/34),
        FL_Coord(diam*16/10),FL_Coord(diam*16/10),X11.Strings.New_String(Texte));
      AjoutElement(F.PElements, BoutonRadio, NomElement, Texte, "",Obj);
      if Actif then
        Fl_Set_Button(Obj, true);
      end if;
    end if;
  end AjouterBoutonRadio;
    
	-- ajouter un bouton décoré d'une image (format XPM) ------------------------
  procedure AjouterBoutonImage (                
        F          : in out TR_Fenetre;        	--	la fenêtre où on ajoute
        NomElement : in     String;							--	le nom du bouton (unique)
        Texte      : in     String;            	--  le texte affiché en légende
				NomImage	 : in 		String;							--	le nom de l'image décor
        X,																			-- 	abscisse du bouton en pixels
        Y          : in     Natural;    			  --  ordonnée du bouton en pixels
        Largeur,																--	largeur du bouton en pixels
        Hauteur    : in     Positive    ) is		--	hauteur du bouton en pixels
 		Obj : FL_OBJECT_Access;
  begin
     if GetElement(F.PElements,NomElement)=null then
			Obj := Fl_Add_Pixmapbutton(FL_NORMAL_BUTTON,FL_Coord(X),FL_Coord(Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
			AjoutElement(F.PElements,PictBouton, NomElement, Texte, "",Obj);
      Fl_Set_Pixmapbutton_File(Obj, X11.Strings.New_String(NomImage));
    end if;
  end AjouterBoutonImage;

 -- ajouter une zone de texte non modifiable ----------------------------------  
  procedure AjouterTexte (                      
        F          : in out TR_Fenetre;         --	la fenêtre où on ajoute
        NomElement : in     String;							--	le nom de la zone de texte
        Texte      : in     String;             --  son contenu
        X,																			-- 	abscisse du coin HG de la zone de texte
        Y          : in     Natural;						-- 	ordonnée du coin HG de la zone de texte
        Largeur,																--	largeur de la zone de texte
        Hauteur    : in     Positive    ) is		--	hauteur de la zone de texte
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then
      Obj := Forms.Fl_Add_Text(Forms.FL_NORMAL_TEXT,FL_Coord(X),FL_Coord(
          Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
      Forms.Fl_Set_Object_Lalign(Obj,Forms.FL_ALIGN_LEFT or Forms.
        FL_ALIGN_INSIDE);
      AjoutElement(F.PElements, TexteFixe, NomElement, Texte, "",Obj);
    end if;
  end AjouterTexte;

 -- ajouter un champ de saisie  -----------------------------------------------  
  procedure AjouterChamp (                      
        F          : in out TR_Fenetre;					-- 	la fenêtre où on ajoute
        NomElement : in     String;							-- 	le nom du champ
        Texte      : in     String;             -- 	le texte affiché en légende
        Contenu    : in     String;             -- 	le contenu initial du champ
        X,																			-- 	abscisse du coin HG du champ
        Y          : in     Natural;						-- 	ordonnée du coin HG du champ
        Largeur,																-- 	largeur du champ
        Hauteur    : in     Positive    ) is		-- 	hauteur du champ
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then
      Obj := Forms.Fl_Add_Input(Forms.FL_NORMAL_INPUT,FL_Coord(X),
        FL_Coord(Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
      Fl_Set_Input(Obj,X11.Strings.New_String(Contenu));
      AjoutElement(F.PElements, ChampDeSaisie, NomElement, Texte, Contenu, Obj);
    end if;
  end AjouterChamp;

 -- ajouter une zone de texte avec ascenseur  --------------------------------- 
  procedure AjouterTexteAscenseur (             
        F          : in out TR_Fenetre;         -- 	la fenêtre où on ajoute
        NomElement : in     String;							--	le nom de la zone de texte
        Texte      : in     String;             --  le texte affiché en légende
        Contenu    : in     String;             --  le contenu de la zone
        X,																			-- 	abscisse du coin HG de la zone
        Y          : in     Natural;						-- 	abscisse du coin HG de la zone
        Largeur,																--	largeur de la zone de texte
        Hauteur    : in     Positive    ) is		--	hauteur de la zone de texte
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then
      Obj := Forms.Fl_Add_Browser(Forms.FL_NORMAL_BROWSER,FL_Coord(X),
        FL_Coord(Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
      AjoutElement(F.PElements, TexteAscenseur, NomElement, Texte, Contenu,
        Obj);
        ChangerContenu(F, NomElement, Contenu);
    end if;
  end AjouterTexteAscenseur;

 -- ajouter une horloge analogique  -------------------------------------------
  procedure AjouterHorlogeAna (                    
        F          : in out TR_Fenetre;         --  la fenêtre où on joute
        NomElement : in     String;							--	le nom de l'horloge
        Texte      : in     String;             --  le texte affiché en légende
        X,																			-- 	abscisse du coin HG 
        Y          : in     Natural;						-- 	ordonnée du coin HG 
        Largeur,																-- 	largeur
        Hauteur    : in     Positive    ) is		--	hauteur
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then

      Obj := Forms.Fl_Add_Clock(Forms.FL_ANALOG_CLOCK,FL_Coord(X),
        FL_Coord(Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
      AjoutElement(F.PElements, Horloge, NomElement, Texte, "", Obj);
    end if;
  end AjouterHorlogeAna;

 -- ajouter une horloge digitale  _-------------------------------------------
  procedure AjouterHorlogeDigi (                    
        F          : in out TR_Fenetre;         --  la fenêtre où on joute
        NomElement : in     String;							--	le nom de l'horloge
        Texte      : in     String;             --  le texte affiché en légende
        X,																			-- 	abscisse du coin HG 
        Y          : in     Natural;						-- 	ordonnée du coin HG 
        Largeur,																-- 	largeur
        Hauteur    : in     Positive ) is				--	hauteur
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then

      Obj := Forms.Fl_Add_Clock(Forms.FL_DIGITAL_CLOCK,FL_Coord(X),
        FL_Coord(Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
      AjoutElement(F.PElements, Horloge, NomElement, Texte, "", Obj);
    end if;
  end AjouterHorlogeDigi;

 -- ajouter un minuteur  ----------------------------------------------------
  procedure AjouterMinuteur(                      
        F          : in out TR_Fenetre;					--	la fenêtre où on ajoute
        NomElement : in     String;							-- 	le nom du minuteur
        Texte      : in     String;             --  le texte affiché en légende
        X,																			-- 	abscisse du coin HG 
        Y          : in     Natural;						-- 	ordonnée du coin HG 
        Largeur,																-- 	largeur
        Hauteur    : in     Positive 		) is		--	hauteur
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then
      Obj := Forms.Fl_Add_Timer(FL_VALUE_TIMER,FL_Coord(X),FL_Coord(Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
      AjoutElement(F.PElements, Timer, NomElement, Texte, "", Obj);
      Fl_Set_Timer_Countup(Obj, X11.Int(0));
    end if;
  end AjouterMinuteur;
 
	-- ajouter un chronomètre  ----------------------------------------------------
  procedure AjouterChrono (                      
        F          : in out TR_Fenetre;					--	la fenêtre où on ajoute
        NomElement : in     String;							-- 	le nom du chronomètre
        Texte      : in     String;             --  le texte affiché en légende
        X,																			-- 	abscisse du coin HG 
        Y          : in     Natural;						-- 	ordonnée du coin HG 
        Largeur,																-- 	largeur
        Hauteur    : in     Positive 		) is		--	hauteur
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then
      Obj := Forms.Fl_Add_Timer(FL_VALUE_TIMER,FL_Coord(X),FL_Coord(Y),
        FL_Coord(Largeur),FL_Coord(Hauteur),X11.Strings.New_String(Texte));
      AjoutElement(F.PElements, Timer, NomElement, Texte, "", Obj);
      Fl_Set_Timer_Countup(Obj, X11.Int(1));
    end if;
  end AjouterChrono;

  -- ajouter une image  --------------------------------------------------------
  procedure AjouterImage (                      
        F          : in out TR_Fenetre;         -- 	la fenêtre où on ajoute
        NomElement : in     String;							-- 	le nom de l'élément
				NomImage	 : in 		String;							--	le nom de l'image
        Texte      : in     String;             -- 	le texte affiché en légende, en bas de l'image
        X	,																			-- 	son abscisse en pixels
        Y          : in     Natural;            -- 	son ordonnée en pixels
        Largeur,																-- 	largeur 
        Hauteur    : in     Positive    ) is    -- 	hauteur
    Obj : FL_OBJECT_Access;
  begin
    if GetElement(F.PElements,NomElement)=null then
      Obj := Fl_Add_Pixmap(FL_NORMAL_PIXMAP, FL_Coord(X), FL_Coord(Y),
        FL_Coord(Largeur), FL_Coord(Hauteur), X11.Strings.New_String(Texte));
      AjoutElement(F.PElements, Image, NomElement, Texte, "", Obj);
      Fl_Set_Pixmap_file(Obj, X11.Strings.New_String(NomImage));
    end if;
  end AjouterImage;

  ------------------------------------------------------------------------------
  -- primitives d'accès à un élément graphique existant
	------------------------------------------------------------------------------

 	-- récupérer le nom du bouton cliqué  ----------------------------------------
  function AttendreBouton (                     
        F : in     TR_Fenetre )                 -- 	nom de la fenêtre
    return String is                            -- 	Résultat = nom du bouton pressé
    Pelement : TA_Element;
  begin
    loop
      PElement:=GetElement(F.Pelements, Fl_Do_Forms);
      exit when PElement/=null;
    end loop;
    return Pelement.NomElement.all;
  end AttendreBouton;
      
	-- récupérer le contenu d'un champ de saisie  --------------------------------
  function ConsulterContenu (                   
        F          : in     TR_Fenetre;         -- 	nom de la fenêtre
        NomElement : in     String      )       -- 	nom du champ de saisie
    return String is                             -- 	Résultat : la chaîne saisie !
    P : TA_Element;  
    S : X11.Strings.Const_Charp;  
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=ChampDeSaisie then
      S:=Fl_Get_Input(P.Pelement);
      return X11.Strings.Value(S);
    else
      return "";
    end if;
  end;

	-- récupérer le temps résiduel d'un minuteur  --------------------------------
  function ConsulterTimer (                     
        F          : in     TR_Fenetre;         --	nom de la fenêtre
        NomElement : in     String      )       -- 	nom du minuteur
    return Float is                             -- 	Résultat : le temps restant !
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=Timer then
      return Float(Fl_Get_Timer(P.Pelement));
    else
      return 0.0;
    end if;
  end ConsulterTimer;

	-- récupérer l'état d'une boîte à cocher ou d'un bouton radio  ---------------
  function ConsulterEtatBCRB (                   	
        F          : in     TR_Fenetre;         -- 	nom de la fenêtre
        NomElement : in     String      )				-- 	nom de l'élément
    return boolean is                           -- 	Résultat :true si coché, false sinon
    P : TA_Element;
    enfonce : boolean;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=CheckBox then
      enfonce:=Fl_Get_button(P.Pelement);
      return enfonce;
    else
      return false;
    end if;
	end ConsulterEtatBCRB;

  ------------------------------------------------------------------------------
  -- primitives de modification du comportement d'éléments graphiques existants
	------------------------------------------------------------------------------

	-- rendre visible une fenêtre  ------------------------------------------------
	procedure MontrerFenetre (                    
        F : in     TR_Fenetre ) is							--	nom de la fenêtre
  begin
    Fl_Show_Form(F.Pfenetre,FL_PLACE_CENTER,FL_FULLBORDER,X11.Strings.
      New_String(F.Titre.all));

    -- Cette ligne permet de dessiner directement une forme.
    -- Sans celle-ci, la forme s'affiche et disparaît presque immédiatement.
    -- FL_Check_Forms renvoie null immédiatement si aucun bouton n'a été
    -- appuyé. Cette instruction ne bloque donc pas l'exécution du programme.
    if Fl_Check_Forms /= null then null; end if;
  end MontrerFenetre;

	-- masquer une fenêtre  -------------------------------------------------------
  procedure CacherFenetre (                     
        F : in     TR_Fenetre ) is							--	nom de la fenêtre
  begin
    Fl_Hide_Form(F.Pfenetre);
  end CacherFenetre;

	-- rendre visible un élément graphique caché jusque là  ----------------------
  procedure MontrerElem (                     	
        F          : in out TR_Fenetre;         -- 	nom de la fenêtre
        NomElement : in     String ) is					-- 	nom de l'élément
	P : TA_Element;
	begin
		P:=GetElement(F.PElements,NomElement);
    if P/=null then
		FL_Show_Object(P.PElement);
	 end if;
	end MontrerElem;

	-- rendre invisible un élément graphique jusque-là visible  ------------------
  procedure CacherElem (                      	
        F          : in out TR_Fenetre;         -- 	nom de la fenêtre
        NomElement : in     String ) is					-- 	nom de l'élément
	P : TA_Element;
	begin
		P:=GetElement(F.PElements,NomElement);
    if P/=null then
		FL_Hide_Object(P.PElement);
	 end if;
	end CacherElem;

	-- activer ou désactiver un bouton  -----------------------------------------
  procedure ChangerEtatBouton (                 
        F          : in out TR_Fenetre;         -- 	nom de la fenêtre
        NomElement : in     String;             -- 	nom du bouton
        Etat       : in     T_EtatBouton ) is   -- 	valeur : marche (cliquable) ou arret (désactivé)
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null then
      if Etat=Marche then
        Fl_Activate_Object(P.Pelement);
      else
        Fl_Deactivate_Object(P.Pelement);
      end if;
    end if;
  end ChangerEtatBouton;

	-- forcer l'état d'un bouton radio  -----------------------------------------
  procedure ChangerEtatBoutonRadio (            
        F          : in out TR_Fenetre;         -- 	nom de la fenêtre
        NomElement : in     String;							-- 	nom du bouton
        Etat       : in     Boolean      ) is   -- 	valeur : true (coché) ou false (non coché)
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=BoutonRadio then
      Fl_Set_Button(P.Pelement, Etat);
    end if;
  end ChangerEtatBoutonRadio;

	-- forcer l'état d'une boîte à cocher ----------------------------------------
  procedure ChangerEtatBoiteCocher (            
        F          : in out TR_Fenetre;         -- 	nom de la fenêtre
        NomElement : in     String;							-- 	nom de la boîte à cocher
        Etat       : in     Boolean      ) is   -- 	valeur : true (coché) ou false (non coché)
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=CheckBox then
      Fl_Set_Button(P.Pelement, Etat);
    end if;
  end ChangerEtatBoiteCocher;

 	-- passer d'un mode minuteur à un mode chronomètre ---------------------------
	-- le temps s'incrémente au lieu de se décrémenter
 	procedure ChangerMinuteurEnChrono (              
        F               : in out TR_Fenetre;    	--  nom de la fenêtre
        NomElement      : in     String    ) is   --  nom de l'élément
    P : TA_Element;
  begin
    P := GetElement(F.PElements, NomElement);
    if P/=null and then P.TypeElement=Timer then
      Fl_Set_Timer_Countup(P.Pelement, X11.Int(1));
    end if;
	end ChangerMinuteurEnChrono;

 	-- passer d'un mode chronomètre à un mode minuteur ---------------------------
	-- le temps se décrémente au lieu de s'incrémenter
  procedure ChangerChronoEnMinuteur(              
        F               : in out TR_Fenetre;    	--  nom de la fenêtre
        NomElement      : in     String    ) is		-- 	nom de l'élément
    P : TA_Element;
  begin
    P := GetElement(F.PElements, NomElement);
    if P/=null and then P.TypeElement=Timer then
      Fl_Set_Timer_Countup(P.Pelement, X11.Int(0));
    end if;
	end ChangerChronoEnMinuteur;

 	-- mettre en pause en timer en marche ----------------------------------------
  procedure PauseTimer (                        
        F               : in out TR_Fenetre;    	--  nom de la fenêtre
        NomElement      : in     String    ) is		-- 	nom de l'élément
    P : TA_Element;
  begin
    P := GetElement(F.PElements, NomElement);
    if P/=null and then P.TypeElement=Timer then
      Fl_Suspend_Timer(P.PElement);
    end if;
  end PauseTimer;

 	-- mettre en marche en timer en pause ----------------------------------------
  procedure RepriseTimer (                      
        F               : in out TR_Fenetre;    	--  nom de la fenêtre
        NomElement      : in     String    ) is		-- 	nom de l'élément
    P : TA_Element;
  begin
    P := GetElement(F.PElements, NomElement);
    if P/=null and then P.TypeElement=Timer then
      Fl_Resume_Timer(P.PElement);
    end if;
  end RepriseTimer;

 	------------------------------------------------------------------------------
  -- primitives de modification de l'apparence ou du contenu d'un élément
	------------------------------------------------------------------------------

  -- modifier la couleur du fond d'un élément grapique -------------------------
  procedure ChangerCouleurFond (                
        F               : in out TR_Fenetre;    --  nom de la fenêtre
        NomElement      : in     String;        --  nom de l'élément
        NouvelleCouleur : in     T_Couleur   )is--  La nouvelle couleur !
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null then
      Fl_Set_Object_Color(P.Pelement,NouvelleCouleur,FL_COL1);
    end if;
  end ChangerCouleurFond;

  -- modifier la couleur du label d'un élément ou d'un texte fixe  -------------
  procedure ChangerCouleurTexte (             
        F               : in out TR_Fenetre;    -- 	nom de la fenêtre
        NomElement      : in     String;        -- 	nom de l'élément
        NouvelleCouleur : in     T_Couleur   )is-- 	La nouvelle couleur !
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null then
      Fl_Set_Object_Lcolor(P.Pelement,NouvelleCouleur);
    end if;
  end ChangerCouleurTexte;

  -- modifier le style du label d'un élément ou d'un texte fixe  ---------------
  procedure ChangerStyleTexte (                	
        F               : in out TR_Fenetre;    		--	nom de la fenêtre
        NomElement      : in     String;        		--	nom de l'élément
        NouveauStyle 		: in    FL_TEXT_STYLE   )is	--  Le nouveau style !
  P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null then
      Fl_Set_Object_Lstyle(P.Pelement,Nouveaustyle);
    end if;
  end ChangerStyleTexte;

  -- modifier la taille du label d'un élément ou d'un texte fixe  --------------
  procedure ChangerTailleTexte (                
        F               : in out TR_Fenetre;    --  nom de la fenêtre
        NomElement      : in     String;        --  nom de l'élément
        Taille 					: in     X11.Int   ) is --  La nouvelle taille !
  P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null then
      Fl_Set_Object_Lsize(P.Pelement,taille);
    end if;
  end ChangerTailleTexte;

  -- modifier l'alignement du label d'un élément ou d'un texte fixe ------------
  procedure ChangerAlignementTexte (            
        F               : in out TR_Fenetre;    --  nom de la fenêtre
        NomElement      : in     String;        --  nom de l'élément
        Alignement      : in     FL_ALIGN    )is--  Le nouvel alignement !
    P : TA_Element;
  begin
    P := GetElement(F.PElements, NomElement);
    if P/=null then
      Fl_Set_Object_Align(P.Pelement, Alignement);
    end if;
  end ChangerAlignementTexte;

	-- modifier le label d'un élément graphique ou la valeur d'un texte fixe------
  procedure ChangerTexte (                      
        F            : in out TR_Fenetre;       --  nom de la fenêtre
        NomElement   : in     String;           --  Le nom de l'élément à modifier
        NouveauTexte : in     String      ) is  --  La nouvelle valeur de légende 
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null then
      Fl_Set_Object_Label(P.Pelement,X11.Strings.New_String(NouveauTexte));
    end if;
  end ChangerTexte;

  -- modifier le style du contenu d'une zone de texte ascenseur ----------------
  procedure ChangerStyleContenu (               
        F               : in out TR_Fenetre;    	--  nom de la fenêtre
        NomElement      : in     String;        	--  nom de la zone de texte
        NouveauStyle : in     FL_TEXT_STYLE   ) is--  Le nouveau style !
  function ValeurStyle is new Ada.Unchecked_Conversion(FL_TEXT_STYLE, X11.Int);
  	P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=TexteAscenseur then
      Fl_Set_Browser_Fontstyle(P.Pelement,ValeurStyle(Nouveaustyle));
    end if;
  end ChangerStyleContenu;

  -- modifier la taille du contenu d'une zone de texte ascenseur ---------------
  procedure ChangerTailleContenu (              
        F               : in out TR_Fenetre;    --  nom de la fenêtre
        NomElement      : in     String;        --  nom de l'élément
        Taille : in     X11.Int   ) is 					--  La nouvelle taille !
  	P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=TexteAscenseur then
      Fl_Set_Browser_Fontsize(P.Pelement,taille);
    end if;
  end ChangerTailleContenu;

 	-- modifier le contenu d'un champ de saisie ou d'une zone de texte ascenseur---
  procedure ChangerContenu (                    
        F              : in out TR_Fenetre;     --  nom de la fenêtre
        NomElement     : in     String;         --  nom de l'élément
        NouveauContenu : in     String      ) is--  La nouvelle valeur de contenu
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null then
      if P.TypeElement=ChampDeSaisie then
        Fl_Set_Input(P.Pelement,X11.Strings.New_String(NouveauContenu));
      elsif P.TypeElement=TexteAscenseur then
        Fl_Clear_Browser(P.Pelement);
        Fl_Addto_Browser_Chars(P.Pelement,X11.Strings.New_String(
            NouveauContenu));
      end if;
    end if;
  end ChangerContenu;

 -- effacer le contenu d'un champ de saisie ou d'une zone de texte ascenseur---
  procedure EffacerContenu (                   
        F               : in out TR_Fenetre;    --  nom de la fenêtre
        NomElement      : in     String      )is--  nom de l'élément
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null then
      if P.TypeElement=ChampDeSaisie then
    		ChangerContenu(F, NomElement, "");
    	elsif P.TypeElement=TexteAscenseur then
      	Fl_Clear_Browser(P.Pelement);
      end if;
    end if;
  end EffacerContenu;

	-- ajouter une nouvelle ligne dans une zone de texte avec ascenseur------------
  procedure AjouterNouvelleLigne (              
        F               : in out TR_Fenetre;    --  nom de la fenêtre
        NomElement      : in     String;        --  nom de l'élément
        NouvelleLigne   : in     String      )is--  Le contenu de la nouvelle ligne
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=TexteAscenseur then
      Fl_Add_Browser_Line(P.Pelement,X11.Strings.New_String(NouvelleLigne));
    end if;
  end AjouterNouvelleLigne;

	-- modifier une ligne dans une zone de texte avec ascenseur-------------------
  procedure ChangerLigne (                      
        F               : in out TR_Fenetre;    --  nom de la fenêtre
        NomElement      : in     String;        --  nom de l'élément
        NumeroLigne     : in     Natural;       --  numéro de ligne à modifier
        NouveauTexte    : in     String      )is--  Le nouveau contenu de la ligne
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=TexteAscenseur then
      Fl_Replace_Browser_Line(P.Pelement,X11.Int(NumeroLigne),
        X11.Strings.New_String(NouveauTexte));
    end if;
  end ChangerLigne;

	-- supprimer une ligne dans une zone de texte avec ascenseur------------------
  procedure SupprimerLigne (                    
        F               : in out TR_Fenetre;    --  nom de la fenêtre
        NomElement      : in     String;        --  nom de l'élément
        NumeroLigne     : in     Natural     )is--  Le numéro de ligne à supprimer
    P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement=TexteAscenseur then
      Fl_Delete_Browser_Line(P.Pelement,X11.Int(NumeroLigne));
    end if;
  end SupprimerLigne;

	-- changer la durée du temps résiduel d'un minuteur --------------------------
  procedure ChangerTempsMinuteur (                 
        F               : in out TR_Fenetre;    --  nom de la fenêtre
        NomElement      : in     String;				-- 	nom du minuteur
        NouveauTemps    : in     Float  		) is--  La durée du décompte !
    P : TA_Element;
  begin
    P := GetElement(F.PElements, NomElement);
    if P/=null and then P.TypeElement=Timer then
      Fl_Set_Timer(P.Pelement, Interfaces.C.Double(NouveauTemps));
    end if;
  end ChangerTempsMinuteur;

	-- changer l'image d'un bouton image -----------------------------------------
  procedure ChangerImageBouton (              	
        F								: in out TR_Fenetre;		-- nom de la fenêtre
        NomElement 			: in     String;				-- nom de l'élément
        NomImage				: in     String      )is-- nom de la nouvelle image décor
     P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement = PictBouton then
      Fl_Set_Pixmapbutton_File(P.Pelement, X11.Strings.New_String(NomImage));
    end if;
  end ChangerImageBouton;

	-- changer l'image d'un bouton image -----------------------------------------
  procedure ChangerImage (              	      -- Change l'image d'un champ image
        F								: in out TR_Fenetre;		-- nom de la fenêtre
        NomElement 			: in     String;				-- nom de l'élément
        NomImage				: in     String      )is-- nom de la nouvelle image 
     P : TA_Element;
  begin
    P:=GetElement(F.PElements,NomElement);
    if P/=null and then P.TypeElement = Image then
      Fl_Set_Pixmap_file(P.Pelement, X11.Strings.New_String(NomImage));
    end if;
  end ChangerImage;

 	------------------------------------------------------------------------------
  -- Autres primitibes
	------------------------------------------------------------------------------

	-- tester si l'utilisateur a utilisé le bouton droit de la souris pour
	-- sélectionner un objet graphique 
  function ClickDroit return boolean 	is			-- vrai si on a pressé le bouton droit de la souris
  begin
    return fl_mousebutton = FL_RIGHTMOUSE;
  end ClickDroit;

	------------------------------------------------------------------------------

end p_fenbase;
