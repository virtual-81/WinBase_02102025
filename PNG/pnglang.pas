{Portable Network Graphics Delphi Language Info (24 July 2002)}

{Feel free to change the text bellow to adapt to your language}
{Also if you have a translation to other languages and want to}
{share it, send me: gubadaud@terra.com.br                     }
unit pnglang;

interface

{$DEFINE English}
{.$DEFINE Polish}
{.$DEFINE Portuguese}
{.$DEFINE German}
{.$DEFINE French}
{.$DEFINE Slovenian}

{Language strings for english}
resourcestring
  {$IFDEF Polish}
  EPngInvalidCRCText = 'Ten obraz "Portable Network Graphics" jest nieprawid�owy ' +
      'poniewa� zawiera on nieprawid�owe cz�ci danych (b��d crc)';
  EPNGInvalidIHDRText = 'Obraz "Portable Network Graphics" nie mo�e zosta� ' +
      'wgrany poniewa� jedna z cz�ci danych (ihdr) mo�e by� uszkodzona';
  EPNGMissingMultipleIDATText = 'Obraz "Portable Network Graphics" jest ' +
    'nieprawid�owy poniewa� brakuje w nim cz�ci obrazu.';
  EPNGZLIBErrorText = 'Nie mo�na zdekompresowa� obrazu poniewa� zawiera ' +
    'b��dnie zkompresowane dane.'#13#10 + ' Opis b��du: ';
  EPNGInvalidPaletteText = 'Obraz "Portable Network Graphics" zawiera ' +
    'niew�a�ciw� palet�.';
  EPNGInvalidFileHeaderText = 'Plik kt�ry jest odczytywany jest nieprawid�owym '+
    'obrazem "Portable Network Graphics" poniewa� zawiera nieprawid�owy nag��wek.' +
    ' Plik mo�� by� uszkodzony, spr�buj pobra� go ponownie.';
  EPNGIHDRNotFirstText = 'Obraz "Portable Network Graphics" nie jest ' +
    'obs�ugiwany lub mo�e by� niew�a�ciwy.'#13#10 + '(stopka IHDR nie jest pierwsza)';
  EPNGNotExistsText = 'Plik png nie mo�e zosta� wgrany poniewa� nie ' +
    'istnieje.';
  EPNGSizeExceedsText = 'Obraz "Portable Network Graphics" nie jest ' +
    'obs�ugiwany poniewa� jego szeroko�� lub wysoko�� przekracza maksimum ' +
    'rozmiaru, kt�ry wynosi 65535 pikseli d�ugo�ci.';
  EPNGUnknownPalEntryText = 'Nie znaleziono wpis�w palety.';
  EPNGMissingPaletteText = 'Obraz "Portable Network Graphics" nie mo�e zosta� ' +
    'wgrany poniewa� u�ywa tabeli kolor�w kt�rej brakuje.';
  EPNGUnknownCriticalChunkText = 'Obraz "Portable Network Graphics" ' +
    'zawiera nieznan� krytyczn� cz�� kt�ra nie mo�e zosta� odkodowana.';
  EPNGUnknownCompressionText = 'Obraz "Portable Network Graphics" jest ' +
    'skompresowany nieznanym schemat kt�ry nie mo�e zosta� odszyfrowany.';
  EPNGUnknownInterlaceText = 'Obraz "Portable Network Graphics" u�ywa ' +
    'nie znany schamat przeplatania kt�ry nie mo�e zosta� odszyfrowany.';
  EPNGCannotAssignChunkText = 'Stopka mysi by� kompatybilna aby zosta�a wyznaczona.';
  EPNGUnexpectedEndText = 'Obraz "Portable Network Graphics" jest nieprawid�owy ' +
    'poniewa� dekoder znalaz� niespodziewanie koniec pliku.';
  EPNGNoImageDataText = 'Obraz "Portable Network Graphics" nie zawiera' +
    'danych.';
  EPNGCannotAddChunkText = 'Program pr�buje doda� krytyczn� ' +
    'stopk� do aktualnego obrazu co jest niedozwolone.';
  EPNGCannotAddInvalidImageText = 'Nie mo�na doda� nowej stopki ' +
    'poniewa� aktualny obraz jest nieprawid�owy.';
  EPNGCouldNotLoadResourceText = 'Obraz png nie mo�e zosta� za�adowany z' +
    'zasob�w o podanym ID.';
  EPNGOutMemoryText = 'Niekt�re operacje nie mog� zosta� zrealizowane poniewa� ' +
    'systemowi brakuje zasob�w. Zamknij kilka okien i spr�buj ponownie.';
  EPNGCannotChangeTransparentText = 'Ustawienie bitu przezroczystego koloru jest ' +
    'zabronione dla obraz�w png zawieraj�cych warto�� alpha dla ka�dego piksela ' +
    '(COLOR_RGBALPHA i COLOR_GRAYSCALEALPHA)';
  EPNGHeaderNotPresentText = 'Ta operacja jest niedozwolona poniewa� ' +
    'aktualny obraz zawiera niew�a�ciwy nag��wek.';
  EInvalidNewSize = 'The new size provided for image resizing is invalid.';
  EInvalidSpec = 'The "Portable Network Graphics" could not be created ' +
    'because invalid image type parameters have being provided.';
  {$ENDIF}

  {$IFDEF English}
  EPngInvalidCRCText = 'This "Portable Network Graphics" image is not valid ' +
      'because it contains invalid pieces of data (crc error)';
  EPNGInvalidIHDRText = 'The "Portable Network Graphics" image could not be ' +
      'loaded because one of its main piece of data (ihdr) might be corrupted';
  EPNGMissingMultipleIDATText = 'This "Portable Network Graphics" image is ' +
    'invalid because it has missing image parts.';
  EPNGZLIBErrorText = 'Could not decompress the image because it contains ' +
    'invalid compressed data.'#13#10 + ' Description: ';
  EPNGInvalidPaletteText = 'The "Portable Network Graphics" image contains ' +
    'an invalid palette.';
  EPNGInvalidFileHeaderText = 'The file being readed is not a valid '+
    '"Portable Network Graphics" image because it contains an invalid header.' +
    ' This file may be corruped, try obtaining it again.';
  EPNGIHDRNotFirstText = 'This "Portable Network Graphics" image is not ' +
    'supported or it might be invalid.'#13#10 + '(IHDR chunk is not the first)';
  EPNGNotExistsText = 'The png file could not be loaded because it does not ' +
    'exists.';
  EPNGSizeExceedsText = 'This "Portable Network Graphics" image is not ' +
    'supported because either it''s width or height exceeds the maximum ' +
    'size, which is 65535 pixels length.';
  EPNGUnknownPalEntryText = 'There is no such palette entry.';
  EPNGMissingPaletteText = 'This "Portable Network Graphics" could not be ' +
    'loaded because it uses System.SysUtils, a color table which is missing.';
  EPNGUnknownCriticalChunkText = 'This "Portable Network Graphics" image ' +
    'contains an unknown critical part which could not be decoded.';
  EPNGUnknownCompressionText = 'This "Portable Network Graphics" image is ' +
    'encoded with an unknown compression scheme which could not be decoded.';
  EPNGUnknownInterlaceText = 'This "Portable Network Graphics" image uses System.SysUtils, ' +
    'an unknown interlace scheme which could not be decoded.';
  EPNGCannotAssignChunkText = 'The chunks must be compatible to be assigned.';
  EPNGUnexpectedEndText = 'This "Portable Network Graphics" image is invalid ' +
    'because the decoder found an unexpected end of the file.';
  EPNGNoImageDataText = 'This "Portable Network Graphics" image contains no ' +
    'data.';
  EPNGCannotAddChunkText = 'The program tried to add a existent critical ' +
    'chunk to the current image which is not allowed.';
  EPNGCannotAddInvalidImageText = 'It''s not allowed to add a new chunk ' +
    'because the current image is invalid.';
  EPNGCouldNotLoadResourceText = 'The png image could not be loaded from the ' +
    'resource ID.';
  EPNGOutMemoryText = 'Some operation could not be performed because the ' +
    'system is out of resources. Close some windows and try again.';
  EPNGCannotChangeTransparentText = 'Setting bit transparency color is not ' +
    'allowed for png images containing alpha value for each pixel ' +
    '(COLOR_RGBALPHA and COLOR_GRAYSCALEALPHA)';
  EPNGHeaderNotPresentText = 'This operation is not valid because the ' +
    'current image contains no valid header.';
  EInvalidNewSize = 'The new size provided for image resizing is invalid.';
  EInvalidSpec = 'The "Portable Network Graphics" could not be created ' +
    'because invalid image type parameters have being provided.';
  {$ENDIF}
  {$IFDEF Portuguese}
  EPngInvalidCRCText = 'Essa imagem "Portable Network Graphics" n�o � v�lida ' +
      'porque cont�m chunks inv�lidos de dados (erro crc)';
  EPNGInvalidIHDRText = 'A imagem "Portable Network Graphics" n�o pode ser ' +
      'carregada porque um dos seus chunks importantes (ihdr) pode estar '+
      'inv�lido';
  EPNGMissingMultipleIDATText = 'Essa imagem "Portable Network Graphics" � ' +
    'inv�lida porque tem chunks de dados faltando.';
  EPNGZLIBErrorText = 'N�o foi poss�vel descomprimir os dados da imagem ' +
    'porque ela cont�m dados inv�lidos.'#13#10 + ' Descri��o: ';
  EPNGInvalidPaletteText = 'A imagem "Portable Network Graphics" cont�m ' +
    'uma paleta inv�lida.';
  EPNGInvalidFileHeaderText = 'O arquivo sendo lido n�o � uma imagem '+
    '"Portable Network Graphics" v�lida porque cont�m um cabe�alho inv�lido.' +
    ' O arquivo pode estar corrompida, tente obter ela novamente.';
  EPNGIHDRNotFirstText = 'Essa imagem "Portable Network Graphics" n�o � ' +
    'suportada ou pode ser inv�lida.'#13#10 + '(O chunk IHDR n�o � o ' +
    'primeiro)';
  EPNGNotExistsText = 'A imagem png n�o pode ser carregada porque ela n�o ' +
    'existe.';
  EPNGSizeExceedsText = 'Essa imagem "Portable Network Graphics" n�o � ' +
    'suportada porque a largura ou a altura ultrapassam o tamanho m�ximo, ' +
    'que � de 65535 pixels de di�metro.';
  EPNGUnknownPalEntryText = 'N�o existe essa entrada de paleta.';
  EPNGMissingPaletteText = 'Essa imagem "Portable Network Graphics" n�o pode ' +
    'ser carregada porque usa uma paleta que est� faltando.';
  EPNGUnknownCriticalChunkText = 'Essa imagem "Portable Network Graphics" ' +
    'cont�m um chunk cr�tico desconhe�ido que n�o pode ser decodificado.';
  EPNGUnknownCompressionText = 'Essa imagem "Portable Network Graphics" est� ' +
    'codificada com um esquema de compress�o desconhe�ido e n�o pode ser ' +
    'decodificada.';
  EPNGUnknownInterlaceText = 'Essa imagem "Portable Network Graphics" usa um ' +
    'um esquema de interlace que n�o pode ser decodificado.';
  EPNGCannotAssignChunkText = 'Os chunk devem ser compat�veis para serem ' +
    'copiados.';
  EPNGUnexpectedEndText = 'Essa imagem "Portable Network Graphics" � ' +
    'inv�lida porque o decodificador encontrou um fim inesperado.';
  EPNGNoImageDataText = 'Essa imagem "Portable Network Graphics" n�o cont�m ' +
    'dados.';
  EPNGCannotAddChunkText = 'O programa tentou adicionar um chunk cr�tico ' +
    'j� existente para a imagem atual, oque n�o � permitido.';
  EPNGCannotAddInvalidImageText = 'N�o � permitido adicionar um chunk novo ' +
    'porque a imagem atual � inv�lida.';
  EPNGCouldNotLoadResourceText = 'A imagem png n�o pode ser carregada apartir' +
    ' do resource.';
  EPNGOutMemoryText = 'Uma opera��o n�o pode ser completada porque o sistema ' +
    'est� sem recursos. Fecha algumas janelas e tente novamente.';
  EPNGCannotChangeTransparentText = 'Definir transpar�ncia booleana n�o � ' +
    'permitido para imagens png contendo informa��o alpha para cada pixel ' +
    '(COLOR_RGBALPHA e COLOR_GRAYSCALEALPHA)';
  EPNGHeaderNotPresentText = 'Essa opera��o n�o � v�lida porque a ' +
    'imagem atual n�o cont�m um cabe�alho v�lido.';
  EInvalidNewSize = 'O novo tamanho fornecido para o redimensionamento de ' +
    'imagem � inv�lido.';
  EInvalidSpec = 'A imagem "Portable Network Graphics" n�o pode ser criada ' +
    'porque par�metros de tipo de imagem inv�lidos foram usados.';
  {$ENDIF}
  {Language strings for German}
  {$IFDEF German}
  EPngInvalidCRCText = 'Dieses "Portable Network Graphics" Bild ist ' +
      'ung�ltig, weil Teile der Daten fehlerhaft sind (CRC-Fehler)';
  EPNGInvalidIHDRText = 'Dieses "Portable Network Graphics" Bild konnte ' +
      'nicht geladen werden, weil wahrscheinlich einer der Hauptdatenbreiche ' +
	  '(IHDR) besch�digt ist';
  EPNGMissingMultipleIDATText = 'Dieses "Portable Network Graphics" Bild ' +
    'ist ung�ltig, weil Grafikdaten fehlen.';
  EPNGZLIBErrorText = 'Die Grafik konnte nicht entpackt werden, weil Teile der ' +
    'komprimierten Daten fehlerhaft sind.'#13#10 + ' Beschreibung: ';
  EPNGInvalidPaletteText = 'Das "Portable Network Graphics" Bild enth�lt ' +
    'eine ung�ltige Palette.';
  EPNGInvalidFileHeaderText = 'Die Datei, die gelesen wird, ist kein ' +
    'g�ltiges "Portable Network Graphics" Bild, da es keinen g�ltigen ' +
    'Header enth�lt. Die Datei k�nnte besch�digt sein, versuchen Sie, ' +
    'eine neue Kopie zu bekommen.';
  EPNGIHDRNotFirstText = 'Dieses "Portable Network Graphics" Bild wird ' +
    'nicht unterst�tzt oder ist ung�ltig.'#13#10 +
    '(Der IHDR-Abschnitt ist nicht der erste Abschnitt in der Datei).';
  EPNGNotExistsText = 'Die PNG Datei konnte nicht geladen werden, da sie ' +
    'nicht existiert.';
  EPNGSizeExceedsText = 'Dieses "Portable Network Graphics" Bild wird nicht ' +
    'unterst�tzt, weil entweder seine Breite oder seine H�he das Maximum von ' +
    '65535 Pixeln �berschreitet.';
  EPNGUnknownPalEntryText = 'Es gibt keinen solchen Palettenwert.';
  EPNGMissingPaletteText = 'Dieses "Portable Network Graphics" Bild konnte ' +
    'nicht geladen werden, weil die ben�tigte Farbtabelle fehlt.';
  EPNGUnknownCriticalChunkText = 'Dieses "Portable Network Graphics" Bild ' +
    'enh�lt einen unbekannten aber notwendigen Teil, welcher nicht entschl�sselt ' +
    'werden kann.';
  EPNGUnknownCompressionText = 'Dieses "Portable Network Graphics" Bild ' +
    'wurde mit einem unbekannten Komprimierungsalgorithmus kodiert, welcher ' +
    'nicht entschl�sselt werden kann.';
  EPNGUnknownInterlaceText = 'Dieses "Portable Network Graphics" Bild ' +
    'benutzt ein unbekanntes Interlace-Schema, welches nicht entschl�sselt ' +
    'werden kann.';
  EPNGCannotAssignChunkText = 'Die Abschnitte m�ssen kompatibel sein, damit ' +
    'sie zugewiesen werden k�nnen.';
  EPNGUnexpectedEndText = 'Dieses "Portable Network Graphics" Bild ist ' +
    'ung�ltig: Der Dekoder ist unerwartete auf das Ende der Datei gesto�en.';
  EPNGNoImageDataText = 'Dieses "Portable Network Graphics" Bild enth�lt ' +
    'keine Daten.';
  EPNGCannotAddChunkText = 'Das Programm versucht einen existierenden und ' +
    'notwendigen Abschnitt zum aktuellen Bild hinzuzuf�gen. Dies ist nicht ' +
    'zul�ssig.';
  EPNGCannotAddInvalidImageText = 'Es ist nicht zul�ssig, einem ung�ltigen ' +
    'Bild einen neuen Abschnitt hinzuzuf�gen.';
  EPNGCouldNotLoadResourceText = 'Das PNG Bild konnte nicht aus den ' +
    'Resourcendaten geladen werden.';
  EPNGOutMemoryText = 'Es stehen nicht gen�gend Resourcen im System zur ' +
    'Verf�gung, um die Operation auszuf�hren. Schlie�en Sie einige Fenster '+
    'und versuchen Sie es erneut.';
  EPNGCannotChangeTransparentText = 'Das Setzen der Bit-' +
    'Transparent-Farbe ist f�r PNG-Images die Alpha-Werte f�r jedes ' +
    'Pixel enthalten (COLOR_RGBALPHA und COLOR_GRAYSCALEALPHA) nicht ' +
    'zul�ssig';
  EPNGHeaderNotPresentText = 'Die Datei, die gelesen wird, ist kein ' +
    'g�ltiges "Portable Network Graphics" Bild, da es keinen g�ltigen ' +
    'Header enth�lt.';
  EInvalidNewSize = 'The new size provided for image resizing is invalid.';
  EInvalidSpec = 'The "Portable Network Graphics" could not be created ' +
    'because invalid image type parameters have being provided.';
  {$ENDIF}
  {Language strings for French}
  {$IFDEF French}
  EPngInvalidCRCText = 'Cette image "Portable Network Graphics" n''est pas valide ' +
      'car elle contient des donn�es invalides (erreur crc)';
  EPNGInvalidIHDRText = 'Cette image "Portable Network Graphics" n''a pu �tre ' +
      'charg�e car l''une de ses principale donn�e (ihdr) doit �tre corrompue';
  EPNGMissingMultipleIDATText = 'Cette image "Portable Network Graphics" est ' +
    'invalide car elle contient des parties d''image manquantes.';
  EPNGZLIBErrorText = 'Impossible de d�compresser l''image car elle contient ' +
    'des donn�es compress�es invalides.'#13#10 + ' Description: ';
  EPNGInvalidPaletteText = 'L''image "Portable Network Graphics" contient ' +
    'une palette invalide.';
  EPNGInvalidFileHeaderText = 'Le fichier actuellement lu est une image '+
    '"Portable Network Graphics" invalide car elle contient un en-t�te invalide.' +
    ' Ce fichier doit �tre corrompu, essayer de l''obtenir � nouveau.';
  EPNGIHDRNotFirstText = 'Cette image "Portable Network Graphics" n''est pas ' +
    'support�e ou doit �tre invalide.'#13#10 + '(la partie IHDR n''est pas la premi�re)';
  EPNGNotExistsText = 'Le fichier png n''a pu �tre charg� car il n''�xiste pas.';
  EPNGSizeExceedsText = 'Cette image "Portable Network Graphics" n''est pas support�e ' +
    'car sa longueur ou sa largeur exc�de la taille maximale, qui est de 65535 pixels.';
  EPNGUnknownPalEntryText = 'Il n''y a aucune entr�e pour cette palette.';
  EPNGMissingPaletteText = 'Cette image "Portable Network Graphics" n''a pu �tre ' +
    'charg�e car elle utilise une table de couleur manquante.';
  EPNGUnknownCriticalChunkText = 'Cette image "Portable Network Graphics" ' +
    'contient une partie critique inconnue qui n'' pu �tre d�cod�e.';
  EPNGUnknownCompressionText = 'Cette image "Portable Network Graphics" est ' +
    'encod�e � l''aide d''un sch�mas de compression inconnu qui ne peut �tre d�cod�.';
  EPNGUnknownInterlaceText = 'Cette image "Portable Network Graphics" utilise ' +
    'un sch�mas d''entrelacement inconnu qui ne peut �tre d�cod�.';
  EPNGCannotAssignChunkText = 'Ce morceau doit �tre compatible pour �tre assign�.';
  EPNGUnexpectedEndText = 'Cette image "Portable Network Graphics" est invalide ' +
    'car le decodeur est arriv� � une fin de fichier non attendue.';
  EPNGNoImageDataText = 'Cette image "Portable Network Graphics" ne contient pas de ' +
    'donn�es.';
  EPNGCannotAddChunkText = 'Le programme a essay� d''ajouter un morceau critique existant ' +
    '� l''image actuelle, ce qui n''est pas autoris�.';
  EPNGCannotAddInvalidImageText = 'Il n''est pas permis d''ajouter un nouveau morceau ' +
    'car l''image actuelle est invalide.';
  EPNGCouldNotLoadResourceText = 'L''image png n''a pu �tre charg�e depuis  ' +
    'l''ID ressource.';
  EPNGOutMemoryText = 'Certaines op�rations n''ont pu �tre effectu�e car le ' +
    'syst�me n''a plus de ressources. Fermez quelques fen�tres et essayez � nouveau.';
  EPNGCannotChangeTransparentText = 'D�finir le bit de transparence n''est pas ' +
    'permis pour des images png qui contiennent une valeur alpha pour chaque pixel ' +
    '(COLOR_RGBALPHA et COLOR_GRAYSCALEALPHA)';
  EPNGHeaderNotPresentText = 'Cette op�ration n''est pas valide car l''image ' +
    'actuelle ne contient pas de header valide.';
  EPNGAlphaNotSupportedText = 'Le type de couleur de l''image "Portable Network Graphics" actuelle ' +
    'contient d�j� des informations alpha ou il ne peut �tre converti.';
  EInvalidNewSize = 'The new size provided for image resizing is invalid.';
  EInvalidSpec = 'The "Portable Network Graphics" could not be created ' +
    'because invalid image type parameters have being provided.';
  {$ENDIF}
  {Language strings for slovenian}
  {$IFDEF Slovenian}
  EPngInvalidCRCText = 'Ta "Portable Network Graphics" slika je neveljavna, ' +
      'ker vsebuje neveljavne dele podatkov (CRC napaka).';
  EPNGInvalidIHDRText = 'Slike "Portable Network Graphics" ni bilo mo�no ' +
      'nalo�iti, ker je eden od glavnih delov podatkov (IHDR) verjetno pokvarjen.';
  EPNGMissingMultipleIDATText = 'Ta "Portable Network Graphics" slika je ' +
    'naveljavna, ker manjkajo deli slike.';
  EPNGZLIBErrorText = 'Ne morem raztegniti slike, ker vsebuje ' +
    'neveljavne stisnjene podatke.'#13#10 + ' Opis: ';
  EPNGInvalidPaletteText = 'Slika "Portable Network Graphics" vsebuje ' +
    'neveljavno barvno paleto.';
  EPNGInvalidFileHeaderText = 'Datoteka za branje ni veljavna '+
    '"Portable Network Graphics" slika, ker vsebuje neveljavno glavo.' +
    ' Datoteka je verjetno pokvarjena, poskusite jo ponovno nalo�iti.';
  EPNGIHDRNotFirstText = 'Ta "Portable Network Graphics" slika ni ' +
    'podprta ali pa je neveljavna.'#13#10 + '(IHDR del datoteke ni prvi).';
  EPNGNotExistsText = 'Ne morem nalo�iti png datoteke, ker ta ne ' +
    'obstaja.';
  EPNGSizeExceedsText = 'Ta "Portable Network Graphics" slika ni ' +
    'podprta, ker ali njena �irina ali vi�ina presega najvecjo mo�no vrednost ' +
    '65535 pik.';
  EPNGUnknownPalEntryText = 'Slika nima vne�ene take barvne palete.';
  EPNGMissingPaletteText = 'Te "Portable Network Graphics" ne morem ' +
    'nalo�iti, ker uporablja manjkajoco barvno paleto.';
  EPNGUnknownCriticalChunkText = 'Ta "Portable Network Graphics" slika ' +
    'vsebuje neznan kriticni del podatkov, ki ga ne morem prebrati.';
  EPNGUnknownCompressionText = 'Ta "Portable Network Graphics" slika je ' +
    'kodirana z neznano kompresijsko shemo, ki je ne morem prebrati.';
  EPNGUnknownInterlaceText = 'Ta "Portable Network Graphics" slika uporablja ' +
    'neznano shemo za preliv, ki je ne morem prebrati.';
  EPNGCannotAssignChunkText = Ko�cki morajo biti med seboj kompatibilni za prireditev vrednosti.';
  EPNGUnexpectedEndText = 'Ta "Portable Network Graphics" slika je neveljavna, ' +
    'ker je bralnik pri�el do nepricakovanega konca datoteke.';
  EPNGNoImageDataText = 'Ta "Portable Network Graphics" ne vsebuje nobenih ' +
    'podatkov.';
  EPNGCannotAddChunkText = 'Program je poskusil dodati obstojeci kriticni ' +
    'kos podatkov k trenutni sliki, kar ni dovoljeno.';
  EPNGCannotAddInvalidImageText = 'Ni dovoljeno dodati nov kos podatkov, ' +
    'ker trenutna slika ni veljavna.';
  EPNGCouldNotLoadResourceText = 'Ne morem nalo�iti png slike iz ' +
    'skladi�ca.';
  EPNGOutMemoryText = 'Ne morem izvesti operacije, ker je  ' +
    'sistem ostal brez resorjev. Zaprite nekaj oken in poskusite znova.';
  EPNGCannotChangeTransparentText = 'Ni dovoljeno nastaviti prosojnosti posamezne barve ' +
    'za png slike, ki vsebujejo alfa prosojno vrednost za vsako piko ' +
    '(COLOR_RGBALPHA and COLOR_GRAYSCALEALPHA)';
  EPNGHeaderNotPresentText = 'Ta operacija ni veljavna, ker ' +
    'izbrana slika ne vsebuje veljavne glave.';
  EInvalidNewSize = 'The new size provided for image resizing is invalid.';
  EInvalidSpec = 'The "Portable Network Graphics" could not be created ' +
    'because invalid image type parameters have being provided.';
  {$ENDIF}


implementation

end.

