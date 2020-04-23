 # je gaat het bestand opgeven vanop de cmd lijn
@ARGV = "20.svg";
@kopie = @ARGV;

#$bestandsnaam = $ARGV[0];

while(<>){
	if($_ =~ /<title>(\d+) by (\d+) orthogonal maze<\/title>/){
		$aantalKolommen = $1;
		$aantalRijen = $2;
	}
}
$aantalCellen = $aantalKolommen*$aantalRijen;
# eerst een 2D array maken om het doolhof in voor te stellen 
# het celnummer van elke cel eerst op -1 initialiseren
# dan de eigenlijke matrix nog aanpassen
# maar de extra rand laat je onveranderd
for($x=0;$x<=$aantalKolommen+1;$x++){
	for($y=0;$y<=$aantalRijen+1;$y++){
		$array[$x][$y] = -1;
	}
}
$celnummer = 1;
%coordinaten = ();
for($y=1;$y<=$aantalRijen;$y++){
	for($x=1;$x<=$aantalKolommen;$x++){
		$array[$x][$y] = $celnummer;
		$coordinaten{$celnummer} = [$x,$y];
		$celnummer++;
	}
}

# nu elke cel (behalve die van de rand) in een hash steken, verwijzend naar een andere hash met al zijn mogelijke buren
%structuur = ();
for($x=1;$x<=$aantalKolommen;$x++){
	for($y=1;$y<=$aantalRijen;$y++){
		$cel = $array[$x][$y];
		$buurBoven = $array[$x][$y-1];
		$buurOnder = $array[$x][$y+1];
		$buurLinks = $array[$x-1][$y];
		$buurRechts = $array[$x+1][$y];
		$structuur{$cel} = {
							boven => $buurBoven,
							onder => $buurOnder,
							links => $buurLinks,
							rechts => $buurRechts
							};
	}
}

# nu zit elke cel in de hash structuur verwijzend naar een hash met zijn mogelijke buren

# nu opnieuw alle data inlezen en er de informatie over de muren uit halen
# cellen die gescheiden worden door een muur verwijder je uit elkaars burenlijst

#$^I = ".bak";
#@kopie = @ARGV;

while(<>){
	if($_ =~ /<title>(\d+) by (\d+) orthogonal maze<\/title>/){
		$aantalKolommen = $1;
		$aantalRijen = $2;
	}
}
$aantalCellen = $aantalKolommen*$aantalRijen;
# eerst een 2D array maken om het doolhof in voor te stellen 
# het celnummer van elke cel eerst op -1 initialiseren
# dan de eigenlijke matrix nog aanpassen
# maar de extra rand laat je onveranderd
for($x=0;$x<=$aantalKolommen+1;$x++){
	for($y=0;$y<=$aantalRijen+1;$y++){
		$array[$x][$y] = -1;
	}
}
$celnummer = 1;
%coordinaten = ();
for($y=1;$y<=$aantalRijen;$y++){
	for($x=1;$x<=$aantalKolommen;$x++){
		$array[$x][$y] = $celnummer;
		$coordinaten{$celnummer} = [$x,$y];
		$celnummer++;
	}
}

# nu elke cel (behalve die van de rand) in een hash steken, verwijzend naar een andere hash met al zijn mogelijke buren
%structuur = ();
for($x=1;$x<=$aantalKolommen;$x++){
	for($y=1;$y<=$aantalRijen;$y++){
		$cel = $array[$x][$y];
		$buurBoven = $array[$x][$y-1];
		$buurOnder = $array[$x][$y+1];
		$buurLinks = $array[$x-1][$y];
		$buurRechts = $array[$x+1][$y];
		$structuur{$cel} = {
							boven => $buurBoven,
							onder => $buurOnder,
							links => $buurLinks,
							rechts => $buurRechts
							};
	}
}

# nu zit elke cel in de hash structuur verwijzend naar een hash met zijn mogelijke buren

# nu opnieuw alle data inlezen en er de informatie over de muren uit halen
# cellen die gescheiden worden door een muur verwijder je uit elkaars burenlijst
#$^I = ".bak";

@ARGV = @kopie;
while(<>){
	print;
	if($_ =~ /<line x1="(\d+)" y1="(\d+)" x2="(\d+)" y2="(\d+)" \/>/){
		$x1 = $1/16;
		$y1 = $2/16;
		$x2 = $3/16;
		$y2 = $4/16;
		if($y1==$y2){
			# dan zit je met een horizontale muur
			# je krijgt de coordinaten vande onderste cel
			# dit heeft als gevolg dat je nooit te hoog kan zitten maar wel te laag
			# niet vergeten de muur kan over meerdere cellen lopen dus je moet deze allemaal afgaan
			for($i=$x1;$i<$x2;$i++){
				$ondersteCel = $array[$i][$y1]; 
				# checken of de ondersteCel wel binnen de array ligt
				if($ondersteCel == -1){
					# als je hier in komt dan weet je dat de onderste cel onderaan net buiten het doolhof komt
					# dan moet je enkel de onderste buur verwijderen uit de cel die er boven ligt => op undef plaatsen
					$bovensteCel = $array[$i][$y1-1];
					$structuur{$bovensteCel}{onder} = undef;
				}
				else{
					# als je hier in komt zat je niet buiten het doolhof en moet je uit 2 cellen iets uit hun burenlijst verwijderen
					$ondersteCel = $array[$i][$y1];
					$bovensteCel = $array[$i][$y1-1];
					$structuur{$ondersteCel}{boven} = undef;
					$structuur{$bovensteCel}{onder} = undef;
				}
			}
		}
		elsif($x1==$x2){
			for($j=$y1;$j<$y2;$j++){
				$rechterCel = $array[$x1][$j];
				# deze rechterCel kan langs de uiterst rechtse kant buiten het doolhof liggen
				if($rechterCel==-1){
					# als je hier komt dan lag de rechtercel buiten het doolhof en moet er enkel in de cel er links van een buur verwijderd worden
					$linkerCel = $array[$x1-1][$j];
					$structuur{$linkerCel}{rechts} = undef;
				}
				else{
					# dan lag de rechtercel dus in het doolhof en moet je dus 2 cellen undef maken
					$linkerCel = $array[$x1-1][$j];
					$rechterCel = $array[$x1][$j];
					$structuur{$linkerCel}{rechts} = undef;
					$structuur{$rechterCel}{links} = undef;
				}
			}
		}
	}
}

# nu ga je van elke cel al zijn buren uit zijn burenlijst afgaan en elke buur verwijderen die undef iets
foreach $cel (keys %structuur){
	foreach $buur (keys %{$structuur{$cel}}){
		if($structuur{$cel}{$buur} == undef){
			delete $structuur{$cel}{$buur};
		}
	}
}


delete $structuur{-1};
delete $structuur{undef};
# der zit precies een foutje in de hash

%kopie = ();
foreach $key (keys %structuur){
	if($key =~ /\d+/){
		$kopie{$key} = $structuur{$key};
	}
}
%structuur = %kopie;


# tot hier is de code correct, je hebt nu een hash waarbij elke cel gelinkt wordt aan een andere hash waarin al zijn echte buren zitten
# nu wil je alle cellen verwijderen die maar 1 buur hebben, deze cel verwijdere je ook uit de burenlijst van alle andere cellen
# dit doe je iteratief (tot er geen cellen meer kunnen worden verwijderd)

lus:
$aantalAanpassingen = 0;
foreach $cel (keys %structuur){
	$aantalBuren = keys %{$structuur{$cel}};
	if($aantalBuren == 1){
		$aantalAanpassingen++;
		# als je hier komt heeft $cel maar 1 buur
		delete $structuur{$cel}; # dit verwijderd de cel al in de grote structuur
		# dan moet de cel verwijderd worden uit de lijst van buren van elke cel

		foreach $sleutel (keys %structuur){
			foreach $richting (keys %{$structuur{$sleutel}}){
				if($structuur{$sleutel}{$richting} == $cel){
					delete $structuur{$sleutel}{$richting};
				}
			}
		}
	}
}
if($aantalAanpassingen != 0){
	$aantalAanpassingen = 0;
	goto lus;
}

# oke eens je hier bent aangekomen weet je dat het juiste pad volledig in de sturctuur zit

#foreach $key (keys %structuur){
#	print "$key: ";
 #	foreach $buur (keys %{$structuur{$key}}){
#		
 #		print "$buur => $structuur{$key}{$buur} ";
 #	}
#	$count = keys %{$structuur{$key}};
#	print "heeft $count buren";
 #	print "\n";
 #}

 print "\n";

 #@ARGV = @kopie;
 push(@ARGV,@kopie);

$^I = ".bak";
 while(<>){
 	print "$_";
  	if($_ =~ /<title>(\d+) by (\d+) orthogonal maze<\/title>/){
 		print "<g fill=\"red\" stroke=\"none\">\n";
 		foreach $cel (keys %structuur){
 			@coord = @{$coordinaten{$cel}};
 			$xLinker = $coord[0];
 			$yBoven = $coord[1];
 			$xRechter = $xLinker+1;
 			$yOnder = $yBoven+1; 

 			$xLinker=$xLinker*16;
 			$yBoven=$yBoven*16;
 			$xRechter=$xRechter*16;
 			$yOnder=$yOnder*16;

 			$linkerBoven = $xLinker.",".$yBoven;
 			$linkerOnder = $xLinker.",".$yOnder;
 			$rechterBoven = $xRechter.",".$yBoven;
 			$rechterOnder = $xRechter.",".$yOnder;

 			print "<polygon points=\"$linkerBoven $rechterBoven $rechterOnder $linkerOnder\"/>\n";
 		}
 		print "</g>\n";
 	}
 }
 



