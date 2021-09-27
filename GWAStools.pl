#!/usr/bin/env perl

# Author: Xin Wang

use warnings;
use strict;
use warnings;
#use Getopt::Std;
use Getopt::Long;
use File::Basename;


&main;
exit;

sub main {
  &usage if (@ARGV < 1);
  my $command = shift(@ARGV);
  my %func = (boxcox=>\&boxcox, genotype2hapmap=>\&genotype2hapmap, hapmap2ped=>\&hapmap2ped, hapmap2map=>\&hapmap2map, genotype_filter=>\&genotype_filter,
  			   hapmap2vcf=>\&hapmap2vcf, sub_hapmap=>\&sub_hapmap, hapmap2genotype=>\&hapmap2genotype,SNP_stat=> \&SNP_stat, 
  			   genotype2table=> \&genotype2table, GWAS=> \&gwas,kinship => \&kinship, lambda=> \&lambda, hapmap2stru=> \&hapmap2stru,
  			   vcf2genotype=> \&vcf2genotype,SNP_com => \&SNP_com
			  );
  die("Unknown command \"$command\".\n") if (!defined($func{$command}));
  &{$func{$command}};
}

sub fasta2phy{
	
	
}


sub table2fasta{
	
}




sub SNP_com{
	my ($input,$output,$heter);
	GetOptions(
			"i|input=s" => \$input,
			"h|heter=s" => \$heter,
	        "o|output=s" => \$output,
	);
	$heter = $heter || "N";
die(qq/Usage: GWAStool.pl SNP_com [option] -i input -o output \n
Options: -i|input 		The input table\n
         -o|output      The output prefix. prefix.same.matrix, prefix.diff.matrix, prefix.compared.table\n
         -h|heter       Whether conside the heterozygosis Y or N. Default N.
/) unless ( $input && $output);
	
	open IN,"<",$input;
	
	
	my @head;
	my $length;
	my %ha;
	
	while(<IN>){
		chomp;
		if(/\#/){
			@head = split/\t/,$_;
			$length = @head;
		}
		else{
			my @line = split/\t/,$_;
			for my $i(2..($length -1)){
				$ha{$line[0]}{$line[1]}{$head[$i]} = $line[$i];
			}
		}
	}
	
	close IN;
	my %pair;
	my %matrix;
	for my $y(2..($length -2)){
		for my $yy(($y+1)..($length -1)){
			$pair{$head[$y]}{$head[$yy]}[0] = 0;
			$pair{$head[$y]}{$head[$yy]}[1] = 0;
			$pair{$head[$y]}{$head[$yy]}[2] = 0;
			$matrix{$head[$y]}{$head[$yy]}[0] = 0;
			$matrix{$head[$y]}{$head[$yy]}[1] = 0;
			$matrix{$head[$y]}{$head[$yy]}[2] = 0;
			$matrix{$head[$yy]}{$head[$y]}[0] = 0;
			$matrix{$head[$yy]}{$head[$y]}[1] = 0;
			$matrix{$head[$yy]}{$head[$y]}[2] = 0;
		}
	}
	
	
	for my $m(keys %ha){
		#$pair{$head[$h]}{$head[$h+1]}[0] = 0;
		#$pair{$head[$h]}{$head[$h+1]}[1] = 0;
		for my $n(keys %{$ha{$m}}){
			for my $h(2..($length -2)){
				for my $hh(($h+1)..($length -1)){
				#$pair{$head[$h]}{$head[$h+1]}[1] = 0;
					if($heter eq "N"){
						if((($ha{$m}{$n}{$head[$h]} eq "A") || ($ha{$m}{$n}{$head[$h]} eq "T") || ($ha{$m}{$n}{$head[$h]} eq "C") || ($ha{$m}{$n}{$head[$h]} eq "G")) && (($ha{$m}{$n}{$head[$hh]} eq "A") || ($ha{$m}{$n}{$head[$hh]} eq "T") || ($ha{$m}{$n}{$head[$hh]} eq "C") || ($ha{$m}{$n}{$head[$hh]} eq "G"))){
							#print "$head[$h]\t$head[$h+1]\t$ha{$m}{$n}{$head[$h]}\t$ha{$m}{$n}{$head[$h+1]}\n";
							if($ha{$m}{$n}{$head[$h]} eq $ha{$m}{$n}{$head[$hh]}){
								$pair{$head[$h]}{$head[$hh]}[0]++;
								$matrix{$head[$h]}{$head[$hh]}[0]++;
								$matrix{$head[$hh]}{$head[$h]}[0]++;
							}
							else{
								$pair{$head[$h]}{$head[$hh]}[1]++;
								$matrix{$head[$h]}{$head[$hh]}[1]++;
								$matrix{$head[$hh]}{$head[$h]}[1]++;
							}
							$pair{$head[$h]}{$head[$hh]}[2]++;
							$matrix{$head[$hh]}{$head[$h]}[2]++;
							$matrix{$head[$h]}{$head[$hh]}[2]++;
						}	
					}
					elsif($heter eq "Y"){
						if((($ha{$m}{$n}{$head[$h]} ne "-") && ($ha{$m}{$n}{$head[$h]} eq "N")) && (($ha{$m}{$n}{$head[$hh]} ne "-") && ($ha{$m}{$n}{$head[$hh]} ne "N"))){
							#print "$head[$h]\t$head[$h+1]\t$ha{$m}{$n}{$head[$h]}\t$ha{$m}{$n}{$head[$h+1]}\n";
							if($ha{$m}{$n}{$head[$h]} eq $ha{$m}{$n}{$head[$hh]}){
								$pair{$head[$h]}{$head[$hh]}[0]++;
								$matrix{$head[$h]}{$head[$hh]}[0]++;
								$matrix{$head[$hh]}{$head[$h]}[0]++;
							}
							else{
								$pair{$head[$h]}{$head[$hh]}[1]++;
								$matrix{$head[$h]}{$head[$hh]}[1]++;
								$matrix{$head[$hh]}{$head[$h]}[1]++;
							}
							$pair{$head[$h]}{$head[$hh]}[2]++;
							$matrix{$head[$hh]}{$head[$h]}[2]++;
							$matrix{$head[$h]}{$head[$hh]}[2]++;
						}
					}
				}
			}
		}
	}
	open OUT,">","$output.compared.table";
	print OUT"id1\tid2\tSNV_same\tSNV_diff\tTotal\n";
	for my $t(keys %pair){
		#print OUT"$t\t";
		for my $tt(keys %{$pair{$t}}){
			print OUT"$t\t";
			print OUT"$tt\t";
			print OUT"$pair{$t}{$tt}[0]\t";
			print OUT"$pair{$t}{$tt}[1]\t";
			print OUT"$pair{$t}{$tt}[2]\n";
		}
	}
	close OUT;
	
	open OUT,">","$output.same.matrix";
	print OUT"var\t";
	for my $w(2..($length -1)){
		print OUT"$head[$w]\t";
	}
	
	print OUT"\n";
	
	for my $t(2..($length -1)){
		print OUT"$head[$t]\t";
		for my $tt(2..($length -1)){
			#print "$head[$t]\t$head[$tt]\n";
			if($head[$t] eq $head[$tt]){
				print OUT"1\t";
			}
			else{
				my $temp_compared = $matrix{$head[$t]}{$head[$tt]}[0] + $matrix{$head[$t]}{$head[$tt]}[1];
				if($temp_compared ==0){
					print OUT"NA\t";
				}
				else{
					my $value = $matrix{$head[$t]}{$head[$tt]}[0]/($matrix{$head[$t]}{$head[$tt]}[0] + $matrix{$head[$t]}{$head[$tt]}[1]);
					print OUT"$value\t";
				}
			}
		}
		print OUT"\n";
	}
	close OUT;
	
	open OUT,">","$output.diff.matrix";
	print OUT"var\t";
	for my $w(2..($length -1)){
		print OUT"$head[$w]\t";
	}
	
	print OUT"\n";
	
	for my $t(2..($length -1)){
		print OUT"$head[$t]\t";
		for my $tt(2..($length -1)){
			#print "$head[$t]\t$head[$tt]\n";
			if($head[$t] eq $head[$tt]){
				print OUT"0\t";
			}
			else{
				my $temp_compared = $matrix{$head[$t]}{$head[$tt]}[0] + $matrix{$head[$t]}{$head[$tt]}[1];
				if($temp_compared ==0){
					print OUT"NA\t";
				}
				else{
					my $value = $matrix{$head[$t]}{$head[$tt]}[1]/($matrix{$head[$t]}{$head[$tt]}[0] + $matrix{$head[$t]}{$head[$tt]}[1]);
					print OUT"$value\t";
				}
			}
		}
		print OUT"\n";
	}
	close OUT;
	
}




sub vcf2genotype{
	my($raw_snp,$genotype,%gen,$list);
	%gen=('-' => '-', AA => 'A', TT => 'T', CC => 'C', GG => 'G', 'AG' => 'R', 'GA' => 'R', 'CT' => 'Y', 'TC' => 'Y', 'AC' => 'M', 'CA' => 'M',
	'GT' => 'K', 'TG' => 'K', 'GC' => 'S', 'CG' => 'S', 'AT' => 'W', 'TA' => 'W', 'ATC' => 'H', 'ACT' => 'H', 'TAC' => 'H', 'TCA' => 'H', 
	'CAT' => 'H', 'CTA' => 'H', 'GTC' => 'B', 'GCT' => 'B', CGT => 'B', CTG => 'B', TCG => 'B', TGC => 'B', GAC => 'V', GCA => 'V', CGA => 'V', 
	CAG => 'V', AGC => 'V', ACG => 'V', GAT => 'D', GTA => 'D', AGT => 'D', ATG => 'D', TGA => 'D', TAG => 'D', ATCG => 'N', ATGC => 'N', ACTG => 'N',
	ACGT => 'N', AGTC => 'N', AGCT => 'N', TACG => 'N', TAGC => 'N', TCAG => 'N', TCGA => 'N', TGAC => 'N', TGCA => 'N', CATG => 'N', CAGT => 'N',
	CTAG => 'N', CTGA => 'N', CGAT => 'N', CGTA => 'N', GATC => 'N', GACT => 'N', GTAC => 'N', GTCA => 'N', GCAT => 'N', GCTA => 'N');#this hash was use for converting the genotype to a single letter according to th IUPAC.
	GetOptions(
	        "input|i:s"=>\$raw_snp,#the vcf file that generated by GATK.
	        "output|o:s"=>\$genotype,
	        "list|l:s"=> \$list,
	);
		
die(qq/Usage: GWAStool.pl vcf2genotype [option] -i input -o output \n
Options: -i|input 		The input vcf file\n
         -o|output      The output genotype\n
         -l|list        The accession list\n
/) unless ( $raw_snp && $genotype);
	
	$list = $list || "$genotype.list";
	#open IN,"gzip -dc $raw_snp |";
	open IN,"<",$raw_snp;
	open OUT,'>',$genotype;
	open LIST,">",$list;
	print LIST"Ref\n";
	while(<IN>){
		chomp;
		my $line=$_;
		if(/\#CHROM/){
			my @head = split /\t/, $line;
			for my $h (9..$#head){
				print LIST"$head[$h]\n";
			}
		}
		next if($line=~/^#/);
	#	next if($line =~/\*/);
		my (@alt,%genotype,@temp,$number);
		next if ( $line =~ /^#/ );
		@temp = split /\t/, $line;
		$temp[0] =~ /\w+(\d+)/;
		if ($temp[4] =~ /,/){
			@alt = split /,/, $temp[4];
		}
		else{
			push @alt, $temp[4];
		}
		unshift @alt, $temp[3];
		my $rm_indel =0;
		for my $a(@alt){
			my $temp_length = length($a);
			if($temp_length > 1){
				$rm_indel =1;
			}
		}
		if($rm_indel ==0){
			print OUT "$temp[0]\t$temp[1]\t$temp[3]\t";#output the chromosome number, positions and the allele of reference.
			foreach my $num (9..$#temp){
				my $geno;
				if(($temp[$num] =~ /\.\/\./) || ($temp[$num] eq "\.") || ($temp[$num] =~ /\.\:\.\:\.\:\.\:/)){  #if the allele was lost in one individual, then the genotypoe will be assigned "-".
				$geno = "-";
				}
				else{
					$temp[$num] =~ /(\d)\|(\d).*/;
					$temp[$num] =~ /(\d)\/(\d).*/;
					my $allele1=$alt[$1];
					my $allele2=$alt[$2];
					$geno = "$allele1$allele2";
				}
				if($geno =~/\*/){
					print OUT"-\t";
				}
				else{
					print OUT "$gen{$geno}\t";
				}
			}
			print OUT"\n";
		}
	}
		
	close IN;
	close OUT;
	close LIST;
}


sub hapmap2stru{
	my ($input,$output);
	GetOptions(
			"i|input=s" => \$input,
	        "o|output=s" => \$output,
	);
	
die(qq/Usage: GWAStool.pl hapmap2stru [option] -i input -o output \n
Options: -i|input 		The input hapmap\n
         -o|output      The structure format output\n
/) unless ( $input && $output);
	
	
	open IN,"<",$input;
	### A -> 1, T -> 2,  C -> 3, G -> 4

	my @head;
	my %ha;
	my $snp_count = 0;
	my $line_count = 1;
	my %snp;
	my $id_count;
	while(<IN>){
		chomp;
		if($line_count ==1){
			@head= split/\t/,$_;
		}
		else{
			$snp_count++;
			$snp{$snp_count} =0;
			my @line = split/\t/,$_;
			my $length = @line;
			$id_count = $length -10 -1;
			for my $i(11..($length -1)){
				if($line[$i] eq "A"){
					$ha{$head[$i]}{$snp_count}{1} = 1;
					$ha{$head[$i]}{$snp_count}{2} = 1;
				}
				elsif($line[$i] eq "T"){
					$ha{$head[$i]}{$snp_count}{1} = 2;
					$ha{$head[$i]}{$snp_count}{2} = 2;
				}
				elsif($line[$i] eq "C"){
					$ha{$head[$i]}{$snp_count}{1} = 3;
					$ha{$head[$i]}{$snp_count}{2} = 3;
				}
				elsif($line[$i] eq "G"){
					$ha{$head[$i]}{$snp_count}{1} = 4;
					$ha{$head[$i]}{$snp_count}{2} = 4;
				}
				
				
				elsif($line[$i] eq "R"){
					$ha{$head[$i]}{$snp_count}{1} = 1;
					$ha{$head[$i]}{$snp_count}{2} = 4;
				}
				elsif($line[$i] eq "Y"){
					$ha{$head[$i]}{$snp_count}{1} = 2;
					$ha{$head[$i]}{$snp_count}{2} = 3;
				}
				elsif($line[$i] eq "M"){
					$ha{$head[$i]}{$snp_count}{1} = 1;
					$ha{$head[$i]}{$snp_count}{2} = 3;
				}
				elsif($line[$i] eq "K"){
					$ha{$head[$i]}{$snp_count}{1} = 2;
					$ha{$head[$i]}{$snp_count}{2} = 4;
				}
				elsif($line[$i] eq "S"){
					$ha{$head[$i]}{$snp_count}{1} = 3;
					$ha{$head[$i]}{$snp_count}{2} = 4;
				}
				elsif($line[$i] eq "W"){
					$ha{$head[$i]}{$snp_count}{1} = 1;
					$ha{$head[$i]}{$snp_count}{2} = 2;
				}
				elsif($line[$i] eq "N"){
					$ha{$head[$i]}{$snp_count}{1} = -9;
					$ha{$head[$i]}{$snp_count}{2} = -9;
				}
			}
		}
		$line_count++;
	}
	close IN;
	
	
	open OUT,">",$output;
	print OUT"\t";
	for my $i(sort {$a <=> $b} keys %snp){
		print OUT"SNP_$i ";
	}
	print OUT"\n";
	
	for my $m(sort {$a cmp $b} keys %ha){
		print OUT"$m\t";
		#my @array1;
		for my $n(sort {$a <=> $b} keys %snp){
			print OUT"$ha{$m}{$n}{1} ";
			#push @array1,$ha{$m}{$n}{1};
		}
		print OUT"\n";
		print OUT"$m\t";
		for my $t(sort {$a <=> $b} keys %snp){
			print OUT"$ha{$m}{$t}{2} ";
		}
		print OUT"\n";
	}
	close OUT;
	
	print "SNP\: $snp_count\n";
	print "ID\: $id_count\n";
		
}






sub lambda{
	my ($filter, $method, $output);
	GetOptions(
	        "o|output=s" => \$output,
	        "m|method=s" => \$method,
	        "f|filter=s" => \$filter,
	);
	
die(qq/Usage: GWAStool.pl lambda -o output input1 input2 input3.....inputN\n

Options:-m|method      algorithm (median or regression, default median)
		-f|filter	   filter the p-value (default no filter (-1))
		-o|output      The output kinship\n
/) unless ($output);
	$method = $method || "median";  ### regression or median
	$filter = $filter || -1;     ####default no filter.
	my $cmd;
###generate the R script
	if($method eq "median"){
		$cmd =<<EOF;	
		Args <- commandArgs()
		df=1
		data <- read.table(Args[6], header = T)
		data <- data[,4]
		data <- data[which(!is.na(data))]
		ntp <- round( 1 * length(data) )
		if ( max(data)<=1 ) {
			data <- qchisq(data, 1, lower.tail=FALSE)
		}
		data[which(abs(data)< $filter)] <- NA
		data <- sort(data)
		ppoi <- ppoints(data)
		ppoi <- sort(qchisq(ppoi, df=df, lower.tail=FALSE))
		data <- data[1:ntp]
		ppoi <- ppoi[1:ntp]
		
		out <- list()
		out\$estimate <- median(data, na.rm=TRUE)/qchisq(0.5, df)
		out\$se <- NA
		
		write.table(out\$estimate, file = Args[7], row.names = FALSE, col.names = FALSE)

EOF
	}
	elsif($method eq "regression"){
		$cmd =<<EOF;	
		Args <- commandArgs()
		df=1
		data <- read.table(Args[6], header = T)
		data <- data[,4]
		data <- data[which(!is.na(data))]
		ntp <- round( 1 * length(data) )
		if ( max(data)<=1 ) {
			data <- qchisq(data, 1, lower.tail=FALSE)
		}
		data[which(abs(data)< $filter)] <- NA
		data <- sort(data)
		ppoi <- ppoints(data)
		ppoi <- sort(qchisq(ppoi, df=df, lower.tail=FALSE))
		data <- data[1:ntp]
		ppoi <- ppoi[1:ntp]
		
		out <- list()
		s <- summary( lm(data~0+ppoi) )\$coeff
		out\$estimate <- s[1,1]
		out\$se <- s[1,2]
		write.table(out\$estimate, file = Args[7], row.names = FALSE, col.names = FALSE)

EOF
	}
	else{
		die "unknown method\!\!\!";
	}
	open OUT,">lambda.r";
	print OUT"$cmd";
	close OUT;
	my %lambda;
	foreach my $f (@ARGV){
		my $label = basename($f);
		my $path = fileparse($f);
		my $dirname = dirname($f);
		#print "$f\n";
		#print "$path\n";
		#print "$label\n";
		#print "$dirname\n";
		system "Rscript lambda.r $f $dirname/$label.lambda";
		open TEMP,"<","$dirname/$label.lambda";
		while(<TEMP>){
			chomp;
			my @line = split;
			$lambda{$label} = $line[0];
		}
		close TEMP;
	}
	open OUT,">",$output;
	print OUT"\#Trait\tlambda\n";
	for my $r(keys %lambda){
		print OUT"$r\t$lambda{$r}\n";
	}
	close OUT;
}






sub kinship{
	my ($input,$output);
	GetOptions(
			"i|input=s" => \$input,
	        "o|output=s" => \$output,
	);
	
die(qq/Usage: GWAStool.pl kinship [option] -i input -o output \n
Options: -i|input 		The input genotype(table format)\n
         -o|output      The output kinship\n
/) unless ( $input && $output);

	open IN,"<",$input;
	my @head;
	my $length;
	my %ha;
	
	while(<IN>){
		chomp;
		if(/\#/){
			@head = split/\t/,$_;
			$length = @head;
		}
		else{
			my @line = split/\t/,$_;
			for my $i(2..($length -1)){
				$ha{$line[0]}{$line[1]}{$head[$i]} = $line[$i];
			}
		}
	}
	
	close IN;
	
	open OUT,">",$output;
	my %pair;
	for my $y(2..($length -2)){
		for my $yy(($y+1)..($length -1)){
			$pair{$head[$y]}{$head[$yy]}[0] = 0;
			$pair{$head[$y]}{$head[$yy]}[1] = 0;	
			$pair{$head[$yy]}{$head[$y]}[0] = 0;
			$pair{$head[$yy]}{$head[$y]}[1] = 0;
		}
	}
	
	for my $m(keys %ha){
		#$pair{$head[$h]}{$head[$h+1]}[0] = 0;
		#$pair{$head[$h]}{$head[$h+1]}[1] = 0;
		for my $n(keys %{$ha{$m}}){
			for my $h(2..($length -2)){
				for my $hh(($h+1)..($length -1)){
				#$pair{$head[$h]}{$head[$h+1]}[1] = 0;
					if((($ha{$m}{$n}{$head[$h]} eq "A") || ($ha{$m}{$n}{$head[$h]} eq "T") || ($ha{$m}{$n}{$head[$h]} eq "C") || ($ha{$m}{$n}{$head[$h]} eq "G")) && (($ha{$m}{$n}{$head[$hh]} eq "A") || ($ha{$m}{$n}{$head[$hh]} eq "T") || ($ha{$m}{$n}{$head[$hh]} eq "C") || ($ha{$m}{$n}{$head[$hh]} eq "G"))){
						#print "$head[$h]\t$head[$h+1]\t$ha{$m}{$n}{$head[$h]}\t$ha{$m}{$n}{$head[$h+1]}\n";
						if($ha{$m}{$n}{$head[$h]} eq $ha{$m}{$n}{$head[$hh]}){
							$pair{$head[$h]}{$head[$hh]}[0]++;
							$pair{$head[$hh]}{$head[$h]}[0]++;
							
						}
						else{
							$pair{$head[$h]}{$head[$hh]}[1]++;
							$pair{$head[$hh]}{$head[$h]}[1]++;
						}
					}
				}
			}
		}
	}
	
	open OUT,">",$output;
	print OUT"var\t";
	for my $w(2..($length -1)){
		print OUT"$head[$w] $head[$w]\t";
	}
	
	print OUT"\n";
	
	for my $t(2..($length -1)){
		print OUT"$head[$t] $head[$t]\t";
		for my $tt(2..($length -1)){
			print "$head[$t]\t$head[$tt]\n";
			if($head[$t] eq $head[$tt]){
				print OUT"1\t";
			}
			else{
				my $value = $pair{$head[$t]}{$head[$tt]}[0]/($pair{$head[$t]}{$head[$tt]}[0] + $pair{$head[$t]}{$head[$tt]}[1]);
				print OUT"$value\t";
			}
		}
		print OUT"\n";
	}
	close OUT;

}




sub boxcox{
	my $figure;

GetOptions(
        "f|figure!" => \$figure
);
	die(qq/Usage: GWAStool.pl boxcox phenotype.txt\n
	Note: This tools need two R library: MASS and car. please install them in your R\n
	Options: -f|figure 		histogram for each phenotype (raw and boxcox)\n\n\n\n
/) if (@ARGV == 0);
	my $cmd;
	foreach my $f (@ARGV){
		my ($key)=$f=~ /^(\S+)\.txt$/;
		if($figure){
			$cmd =<<EOF;
			library(MASS)
			library(car)
			data <- read.table("$f",header=T,row.names=1)
			for (n in colnames(data)){
				filename = paste(n,"png",sep=".")
				png(file=filename,width=800,height=800)
				a =data[n]
				hist(a[,1])
				dev.off()
			}
			
			get.boxcox <- function (a){
				name = colnames(a)
				lamda = boxcox(a ~ 1,seq(-5,5,0.001),plotit=F)
				mylamda <- lamda\$x[which.max(lamda\$y)]
				tr <- bcPower(a,mylamda)
				names(tr) = name
				return(tr)
			}
			
			results <- lapply(data,get.boxcox)
			results <- as.data.frame(results)
			results <- data.frame(ts=rownames(data),results)
			write.table(results,file="$key\_boxcox.txt",quote=F,sep="\\t",row.names = F)
			
			data <- read.table("$key\_boxcox.txt",header=T,row.names=1)
			
			#data <- results
			#rownames(data) <- data[,1]
			#data <- data[,-1]
			for (n in colnames(data)){
				filename = paste(paste(n,"boxcox",sep="_"),"png",sep=".")
				png(file=filename,width=800,height=800)
				a =data[n]
				hist(a[,1])
				dev.off()
			}
			q()
EOF
		}
		else{
			$cmd =<<EOF;
			library(MASS)
			library(car)
			data <- read.table("$f",header=T,row.names=1)			
			get.boxcox <- function (a){
				name = colnames(a)
				lamda = boxcox(a ~ 1,seq(-5,5,0.001),plotit=F)
				mylamda <- lamda\$x[which.max(lamda\$y)]
				tr <- bcPower(a,mylamda)
				names(tr) = name
				return(tr)
			}
			
			results <- lapply(data,get.boxcox)
			results <- as.data.frame(results)
			results <- data.frame(ts=rownames(data),results)
			write.table(results,file="$key\_boxcox.txt",quote=F,sep="\\t",row.names = F)
			
			data <- read.table("$key\_boxcox.txt",header=T,row.names=1)
			
			#data <- results
			#rownames(data) <- data[,1]
			#data <- data[,-1]
			q()
EOF
		}
		
		open OUT,">boxcox.r";
		print OUT"$cmd";
		system "R CMD BATCH --no-save --no-restore boxcox.r";	
	}

}


sub genotype2hapmap{
	my ($input,$list,$output,$prefix);
	
	GetOptions(
			"i|input=s" => \$input,
	        "o|output=s" => \$output,
	        "l|list=s" => \$list,
	        "p|prefix=s"=>\$prefix,
	);
	die(qq/Usage: GWAStool.pl genotype2hapmap [option] -o output -l list -i input.genotype\n
	Options: -i|input 		The input genotype\n
	         -l|list 		The list of individual name (must same order with the genotype)\n
	         -o|output      The output hapmap\n
	         -p|prefix      The prefix of chromosome(defaut: ch)\n
/) unless ( $input && $output && $list);

	$prefix = $prefix || "chr";
	
	my %chrom;
	for my $c(1..50){
		if($c<=9){
			my $chr_name_1 = "chr$c";
			my $chr_name_2 = "chr0$c";
			$chrom{$chr_name_1} = $c;
			$chrom{$chr_name_2} = $c;
			
		}
		else{
			my $chr_name_1 = "chr$c";
			my $chr_name_2 = "chr$c";
			$chrom{$chr_name_1} = $c;
			$chrom{$chr_name_2} = $c;
		}
	}
#	my %chrom= (
#	  ch00 => 0, ch01 => 1, ch02 => 2, ch03 => 3, ch04 => 4,
#	  ch05 => 5, ch06 => 6, ch07 => 7, ch08 => 8,
#	  ch09 => 9, ch10 => 10, ch11 => 11, ch12 => 12,
#	  ch13 => 13, ch14 => 14, ch15 => 15, ch16 => 16,
#	  ch0 => 0, ch1 => 1, ch2 => 2, ch3 => 3, ch4 => 4,
#	  ch5 => 5, ch6 => 6, ch7 => 7, ch8 => 8,
#	  ch9 => 9, ch10 => 10, ch11 => 11, ch12 => 12,
#	  );
	  
	my %list;
	
	#construct the hash of individual the number
	
	open IN,"<",$list;
	my $l=1;
	while(<IN>){
		chomp;
		my @line=split;
		$list{$l}=$line[0];
		$l++;
	}
	close IN;
	
	#input the genotype and change it to hapmap format 
	
	open IN,"<",$input;
	open OUT,">",$output;
	
	print OUT"rs\talleles\tchrom\tpos\tstrand\tassembly\tcenter\tprotLSID\tassayLSID\tpanel\tQCcode\t";
	for my $i ( sort {$a <=> $b} keys %list){
		print OUT"$list{$i}\t";
	}
	print OUT"\n";
	while(<IN>){
		chomp;
		next if(/\#/);
		my @line =split;
		my %snp;
		my %allele;
		my $ch=$line[0];
		my $new_prefix = $prefix."0";
		$ch =~ s/$new_prefix//;
		$ch =~ s/$prefix//;
		my $pos=$line[1];
		my $long=@line;
		my @allele;
			print OUT"$line[0]\_$pos\tNA\t$ch\t$line[1]\t+\tNA\tNA\tNA\tNA\tNA\tNA\t";
			for my $l (2..($long-1)){
				if($line[$l] eq "-"){
					print OUT"N\t";
				}
				else{
					print OUT"$line[$l]\t";	
				}
			}
			print OUT"\n";
	}
	close IN;
	close OUT;
}





sub hapmap2ped{
	my ($input,$output,$miss_type);
	GetOptions(
			"i|input=s" => \$input,
	        "o|output=s" => \$output,
	        "m|miss_type=s" => \$miss_type,
	);
die(qq/Usage: GWAStool.pl hapmap2ped [option] -o output -i input.genotype\n
Options: -i|input 		The input genotype\n
         -o|output      The output hapmap\n
         -m|miss_type   The miss data type in ped file (defaut: 0)\n
/) unless ( $input && $output);
	
	$miss_type = $miss_type || 0;
	my %ha= (    
	  A => 'A A', G => 'G G', C => 'C C', T => 'T T',
	  M => 'A C', R => 'A G', W => 'A T', S => 'C G',
	  Y => 'C T', K => 'G T', N =>"0 0",AA => 'A A',
	  AC => 'A C', AG => 'A G', AT => 'A T', CA => 'C A',
	  CT => 'C T',CG => 'C G', CC => 'C C', TT => 'T T',
	  TC => 'T C', TA => 'T A', TG =>'T G',GG =>'G G',
	  GC =>'G C', GA => 'G A', GT => 'G T',NN => '0 0'
	  );
	$ha{"NN"} = "$miss_type $miss_type";
	$ha{"N"} = "$miss_type $miss_type";    
	
	open IN,"<",$input;
	open OUT,">",$output;
	
	my @head; 
	my %snp;
	my $l=1;
	while(<IN>){
		chomp;
		if($l==1){
			@head = split/\t/,$_;
			#print "@head\n";
			#my $length = @head;
			#print "12345\t$length\n"
		}
		else{
			my @line=split/\t/,$_;
			my $length = @line;
			#print "$length\n";
			for my $i(11..($length-1)){
				$snp{$i}{$head[$i]}{$l}=$line[$i];
			} 
		}
		$l++;
	}
	close IN;
	
	for my $i(sort{$a<=>$b} keys %snp){
		for my $m(sort{$a cmp $b}keys %{$snp{$i}}){
			print OUT"$m $m 0 0 1  0  ";
			for my $n(sort{$a<=>$b}keys %{$snp{$i}{$m}}){
				print OUT"$ha{$snp{$i}{$m}{$n}}  ";
			}
		}
		print OUT"\n";
	}
	close OUT;


}

sub hapmap2map{
	my ($input,$output);
	GetOptions(
			"i|input=s" => \$input,
	        "o|output=s" => \$output,
	);
	
die(qq/Usage: GWAStool.pl hapmap2ped [option] -o output -i input.genotype\n
Options: -i|input 		The input genotype\n
         -o|output      The output hapmap\n
         -m|miss_type   The miss data type in ped file (defaut: 0)\n
/) unless ( $input && $output);
	
	open IN,"<",$input;
	
	open OUT,">",$output;
	my $l=1;
	while(<IN>){
		chomp;
		my @line=split;
		if($l==1){
			
		}
		else{
			print OUT"$line[2] $line[0] 0 $line[3]\n";	
		}
		$l++;
	}
}



sub genotype_filter{
	my ($input,$output,$miss_rate_cutoff,$maf_cutoff,$no,$het);
	GetOptions(
			"i|input=s" => \$input,
	        "o|output=s" => \$output,
	        "m|miss_rate=s" => \$miss_rate_cutoff,
	        "f|maf=s" => \$maf_cutoff,
	        "n|no!" => \$no,
	        "h|het=s" => \$het,
	);
die(qq/Usage: GWAStool.pl genotype_filter [option] -o output -i input.genotype\n


Options: -i|input 		The input genotype\n
         -o|output      The output hapmap\n
         -m|miss_rate   The miss rate for filter, only less than this value site is kept (defaut: 0.6)\n
         -f|maf         The maf for filter, only more than this value site is kept (defaut: 0.05)\n
         -n|no          Wheather keep no bi-allele site, no means keep non-biallele site\n\
         -h|het         The heterozygosis for filter, only less than this rate value is kept (defaut: 1 or 100%)
         
/) unless ( $input && $output);

	$miss_rate_cutoff = $miss_rate_cutoff || 0.6;
	$maf_cutoff = $maf_cutoff || 0.05;
	$het = $het || 10;
	my $bi_allele;
	my $long;	
	open IN,"<",$input;
	open OUT,">",$output;
	
	my $label = basename($output);
	my $path = fileparse($output);
	my $dirname = dirname($output);
	
	#generate a information file named **.info
	open INFO,">","$dirname/$label.info";
	
	#calculate each postion frequence and missing data
	while(<IN>){
		chomp;
		my @line =split;
		if(/\#/){
			print OUT"$_\n";
			next;
		}
		my %snp;
		my %allele;
		my $ch=$line[0];
		my $pos=$line[1];
		#print"$seq\n";
		$long=@line;
		$allele{$ch}{$pos}{"het"} = 0;
		$allele{$ch}{$pos}{"-"}=0;
		$allele{$ch}{$pos}{"A"} =0;
		$allele{$ch}{$pos}{"T"} =0;
		$allele{$ch}{$pos}{"C"} =0;
		$allele{$ch}{$pos}{"G"} =0;
		for my $k(2..($long-1)){
			if($line[$k] eq "M"){
				$allele{$ch}{$pos}{"A"}++;
				$allele{$ch}{$pos}{"C"}++;	
				$allele{$ch}{$pos}{"het"}++;
			}
			elsif($line[$k] eq "R"){
				$allele{$ch}{$pos}{"A"}++;
				$allele{$ch}{$pos}{"G"}++;	
				$allele{$ch}{$pos}{"het"}++;
			}
			elsif($line[$k] eq "W"){
				$allele{$ch}{$pos}{"A"}++;
				$allele{$ch}{$pos}{"T"}++;
				$allele{$ch}{$pos}{"het"}++;
			}
			elsif($line[$k] eq "S"){
				$allele{$ch}{$pos}{"C"}++;
				$allele{$ch}{$pos}{"G"}++;	
				$allele{$ch}{$pos}{"het"}++;					
			}
			elsif($line[$k] eq "Y"){	
				$allele{$ch}{$pos}{"T"}++;
				$allele{$ch}{$pos}{"C"}++;
				$allele{$ch}{$pos}{"het"}++;
			}
			elsif($line[$k] eq "K"){
				$allele{$ch}{$pos}{"T"}++;
				$allele{$ch}{$pos}{"G"}++;	
				$allele{$ch}{$pos}{"het"}++;
			}
			elsif($line[$k] eq "-"){
				$allele{$ch}{$pos}{"-"}=$allele{$ch}{$pos}{"-"}+2;
			}	
			else{
				$allele{$ch}{$pos}{$line[$k]}=$allele{$ch}{$pos}{$line[$k]}+2;			
			}
		}	
	#output the information of the postion	
		print INFO"$ch\t$pos\t";
		for my $m (sort {$a cmp $b} keys %{$allele{$ch}{$pos}}){
			my $frequ;
			if($m eq "-"){
				$frequ= $allele{$ch}{$pos}{$m}/(($long-2)*2);
			}
			elsif($m eq "het"){
				if($long-2-$allele{$ch}{$pos}{"-"}/2 == 0){
					$frequ =0;
				}
				else{
					$frequ= $allele{$ch}{$pos}{$m}/($long-2-$allele{$ch}{$pos}{"-"}/2)
				}
				
			}
			else{
				if($long-2-$allele{$ch}{$pos}{"-"}/2 == 0){
					$frequ =0;
				}
				else{
					$frequ= $allele{$ch}{$pos}{$m}/(($long-2)*2-$allele{$ch}{$pos}{"-"});
				}
				
			}
			print INFO"$m\t$frequ\t";
			if((($m eq "A") || ($m eq "T") || ($m eq "C") || ($m eq "G"))){
				$snp{$ch}{$pos}{$m}=$frequ;	
			}
		}
		print INFO"\n";		
		
	#sort the frenqu in this postion	
	#remove missing data > 80% ,remove maf of allele < 0.05 ,only two allele in one postion is left
		my @count;
		for my $n (keys %{$snp{$ch}{$pos}}){
			if(($n ne "-") || ($n ne "het")){
				#print "$ch\t$pos\t$n\t$snp{$ch}{$pos}{$n}\t";
				if($snp{$ch}{$pos}{$n} !=0){
					push (@count,$snp{$ch}{$pos}{$n});	
				}	
			}
		}
		#print "\n";
		#print "$ch\t$pos\t@count\n";
		@count=sort{$a <=> $b} @count;
		my $allele_length = @count;
		my $maf=shift @count;
		#print TE"@count\t$maf\t$allele_length\n";
		if($no){								####if not only keep the bi-allele,set the the site allele number to 2
			$allele_length =2;
		}
		my $het_rate;
		if($long-2 -$allele{$ch}{$pos}{"-"}/2 ==0){
			$het_rate =0;
		}
		else{
			$het_rate = ($allele{$ch}{$pos}{"het"}/($long-2 -$allele{$ch}{$pos}{"-"}/2));
		}
		#print "$allele{$ch}{$pos}{\"-\"}\n";
		#print "$ch\t$pos\t$het_rate\n";
		if(($allele{$ch}{$pos}{"-"} <= (($long-2)*2*$miss_rate_cutoff)) && ($het_rate <= $het) && ($allele_length ==2) && ($maf >= $maf_cutoff)){
			@line=join"\t",@line;
			print OUT"@line\n";	
		}		
	}	
	print"$label filter is finished\n";
	close IN;	
	close OUT;
	close INFO;	
}

sub hapmap2vcf{
	my ($hapmap,$vcf);
	GetOptions(
			"i|input=s" => \$hapmap,
	        "o|output=s" => \$vcf,
	);
die(qq/Usage: GWAStool.pl hapmap2vcf [option] -o output -i input.hapmap\n
Options: -i|input 		The input hapmap\n
         -o|output      The output vcf\n
/) unless ( $hapmap && $vcf);
	open IN,"<",$hapmap;
	open OUT,">",$vcf;
	my $l = 1;
	my @head;
	while(<IN>){
		chomp;
		if($l ==1){
			@head = split/\t/,$_;
			print OUT"\#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t";
			my $length = @head;
			for my $i(11..($length -1)){
				print OUT"$head[$i]\t";
			}
			print OUT"\n";
		}
		else{
			my @line = split/\t/,$_;
			my $length = @line;
			my %allele;
			my %type;
			my %allele_count;
			my $miss =0;
			$allele{"A"} =0;
			$allele{"T"} =0;
			$allele{"C"} =0;
			$allele{"G"} =0;
			for my $k(11..($length -1)){
				if($line[$k] eq "M"){
					$allele{"A"}++;
					$allele{"C"}++;	
				}
				elsif($line[$k] eq "R"){
					$allele{"A"}++;
					$allele{"G"}++;	
				}
				elsif($line[$k] eq "W"){
					$allele{"A"}++;
					$allele{"T"}++;
				}
				elsif($line[$k] eq "S"){
					$allele{"C"}++;
					$allele{"G"}++;						
				}
				elsif($line[$k] eq "Y"){	
					$allele{"T"}++;
					$allele{"C"}++;
				}
				elsif($line[$k] eq "K"){
					$allele{"T"}++;
					$allele{"G"}++;	
				}
				elsif($line[$k] eq "N"){
					$miss++;
				}
				else{
					$allele{$line[$k]}++;
				}
			}
			for my $m(keys %allele){
				if($allele{$m} != 0){
					$type{$allele{$m}}{$m} = $m;	
				}	
			}
			my $cc =0;
			my @allele;
			for my $n(sort {$b <=> $a} keys %type){
				for my $nn(keys %{$type{$n}}){
					push @allele,$nn;
					$allele_count{$nn} = $cc;
					$cc++;
				}
			}
			my @chr_infor = split/\_/,$line[0];
			pop @chr_infor;
			my $chr_output = join"_",@chr_infor;
			
			print OUT"$chr_output\t$line[3]\t$line[0]\t";
			my $ll = @allele;
			if($ll >=2){
				print OUT "$allele[0]\t";
				for my $a(1..($ll -2)){
					print OUT"$allele[$a],";
				}
				print OUT"$allele[$ll -1]\t";	
			}
			elsif($ll ==1){
				print OUT "$allele[0]\t";
				print OUT "N\t";	
			}
			else{
				print OUT "N\t";
				print OUT "N\t";
				
			}
			print OUT"\.\t\.\tPR\tGT\t";
			for my $kk(11..($length -1)){
				if($line[$kk] eq "M"){
					print OUT"$allele_count{A}\/$allele_count{C}\t";
					#$allele{"C"}++;	
				}
				elsif($line[$kk] eq "R"){
					print OUT"$allele_count{A}\/$allele_count{G}\t";
					#$allele{"A"}++;
					#$allele{"G"}++;	
				}
				elsif($line[$kk] eq "W"){
					print OUT"$allele_count{A}\/$allele_count{T}\t";
					#$allele{"A"}++;
					#$allele{"T"}++;
				}
				elsif($line[$kk] eq "S"){
					print OUT"$allele_count{G}\/$allele_count{C}\t";
					
					#$allele{"C"}++;
					#$allele{"G"}++;						
				}
				elsif($line[$kk] eq "Y"){	
					print OUT"$allele_count{T}\/$allele_count{C}\t";
					$allele{"T"}++;
					$allele{"C"}++;
				}
				elsif($line[$kk] eq "K"){
					print OUT"$allele_count{T}\/$allele_count{G}\t";
					#$allele{"T"}++;
					#$allele{"G"}++;	
				}
				elsif($line[$kk] eq "N"){
					#$miss++;
					print OUT".\/.\t";
				}
				else{
					#print "$line[2]\t$line[3]\t$allele[0]\t$line[$kk]\t";
					print OUT"$allele_count{$line[$kk]}\/$allele_count{$line[$kk]}\t";
				}
			}
			print OUT"\n";
		}
		$l++;
	}
	
	close IN;
	close OUT;
}

sub sub_hapmap{
	my ($list,$hapmap,$out_hapmap);
	GetOptions(
			"l|list=s" => \$list,
	        "i|input=s" => \$hapmap,
	        "o|output=s" => \$out_hapmap,
	        
	);
die(qq/Usage: GWAStool.pl sub_hapmap [option] -l list -o sub_hapmap -i input.hapmap\n
Options: -i|input 		The input hapmap\n
         -o|output      The output hapmap\n
         -l|list        The list for sub hapmap\n
         
/) unless ( $hapmap && $out_hapmap && $list);	
	my %ha;
	open IN,"<",$list;
	while(<IN>){
		chomp;
		my @line = split;
		$ha{$line[0]} = 0;
	}
	close IN;
	open IN,"<",$hapmap;
	open OUT,">",$out_hapmap;
	my @head;
	while(<IN>){
		chomp;
		if(/alleles/){
			@head = split/\t/,$_;
			for my $m(0..10){
				print OUT"$head[$m]\t";
			}
			for my $i(11..$#head){
				if(exists $ha{$head[$i]}){
					print OUT"$head[$i]\t";
				}
			}
			print OUT"\n";
		}
		else{
			my @line = split/\t/,$_;
			my $length = @line;
			for my $m(0..10){
				print OUT"$line[$m]\t";
			}
			for my $i(11..($length -1)){
				if(exists $ha{$head[$i]}){
					print OUT"$line[$i]\t";
				}
			}
			print OUT"\n";
		}
	}
	close IN;
	close OUT;
}


sub hapmap2genotype{
		my ($hapmap,$list,$genotype,$prefix);
		GetOptions(
				"i|input=s" => \$hapmap,
		        "o|output=s" => \$genotype,
		        "l|list=s" => \$list,
		);
die(qq/Usage: GWAStool.pl hapmap2genotype [option] -l list -o output -i input.genotype\n
Options: -i|input 		The input hapmap\n
         -o|output      The output genotype\n
         -l|list 		The output list\n	
/) unless ( $hapmap && $genotype && $list);
	$prefix = $prefix || "chr";
	open IN,"<",$hapmap;
	open LIST,">",$list;
	
	open OUT,">",$genotype;
	my $l = 1;
	while(<IN>){
		chomp;
		my @line=split/\t/,$_;
		if($l==1){
			for my $i(11..$#line){
				print LIST"$line[$i]\n";
			}
			close LIST;
			$l++;
		}
		else{
			my @chrom = split/\_/,$line[0];
			my $pos = pop @chrom;
			my $chr = join"_",@chrom;
			#print OUT"ch$line[2]\t$line[3]\t";
			print OUT"$chr\t$pos\t";
			for my $k(11..$#line){
				if(($line[$k] eq "AA") || ($line[$k] eq "A")){
					print OUT"A\t";
				}
				elsif(($line[$k] eq "TT") || ($line[$k] eq "T")){
					print OUT"T\t";
				}
				elsif(($line[$k] eq "CC") || ($line[$k] eq "C")){
					print OUT"C\t";
				}
				elsif(($line[$k] eq "GG") || ($line[$k] eq "G")){
					print OUT"G\t";
				}
				elsif(($line[$k] eq "NN") || ($line[$k] eq "N")){
					print OUT"-\t";
				}
				elsif(($line[$k] eq "AC") || ($line[$k] eq "CA") || ($line[$k] eq "M")){
					print OUT"M\t";
				}
				elsif(($line[$k] eq "AG") || ($line[$k] eq "GA") || ($line[$k] eq "R")){
					print OUT"R\t";
				}
				elsif(($line[$k] eq "AT") || ($line[$k] eq "TA") || ($line[$k] eq "W")){
					print OUT"W\t";
				}
				elsif(($line[$k] eq "CG") || ($line[$k] eq "GC") || ($line[$k] eq "S")){
					print OUT"S\t";
				}
				elsif(($line[$k] eq "CT") || ($line[$k] eq "TC") || ($line[$k] eq "Y")){
					print OUT"Y\t";
				}
				elsif(($line[$k] eq "GT") || ($line[$k] eq "TG") || ($line[$k] eq "K")){
					print OUT"K\t";
				}		
			}
			print OUT"\n";
		}
	}
		
}

sub genotype2table{
	my ($in_genotype,$list,$table);
	GetOptions(
			"i|input=s" => \$in_genotype,
	        "o|output=s" => \$table,
	        "l|list=s" => \$list,
	);
die(qq/Usage: GWAStool.pl genotype2table [option] -l list -o output -i input.genotype\n
Options: -i|input 		The input genotype\n
         -o|output      The output table\n
         -l|list 		The output list\n	
/) unless ( $in_genotype && $table && $list);
	my %list;
	#construct the hash of individual the number
	open IN,"<",$list;
	my $l=1;
	while(<IN>){
		chomp;
		my @line=split;
		$list{$l}=$line[0];
		$l++;
	}
	close IN;
	#input the genotype and change it to hapmap format 
	
	open OUT,">",$table;
	
	print OUT"\#Chr\tpos\t";
	for my $i ( sort {$a <=> $b} keys %list){
		print OUT"$list{$i}\t";
	}
	print OUT"\n";
	open IN,"<",$in_genotype;
	while(<IN>){
		chomp;
		my @line =split;
		my $line = join"\t",@line;
		print OUT"$line\n";

	}
	close IN;
	close OUT;
}



sub SNP_stat{
	my ($genotype,$prefix);
	GetOptions(
		"i|input=s" => \$genotype,
	    "o|output=s" => \$prefix,
	   );
die(qq/Usage: GWAStool.pl snp_stat [option] -i input.genotype -o result \n
Options: -i|input 		The input genotype\n
         -o|output      The output prefix (default SNP_stat)\n
/) unless ($genotype);
	
	$prefix = $prefix || "SNP_stat";
	
	my $out = $prefix."ID.stat";
	my $info = $prefix."Site.stat";
	open IN,"<",$genotype;
	open INFO,">",$info;
	my @type= ("-","heter","A","T","C","G");
	my $head = join"\t",@type;
	print INFO"\#chr\tpos\t$head\tMAF\n";
	my @head;
	my $length;
	my %ha;
	my $total = 0;
	while(<IN>){
		chomp;
		if(/\#/){
			@head = split/\t/,$_;
			$length = @head;
			for my $i(2..($length-1)){
				$ha{$head[$i]}{"miss"} =0 ;
				$ha{$head[$i]}{"heter"} =0;
			}
		}
		else{
			my @line = split/\t/,$_;
			my $ch=$line[0];
			my $pos=$line[1];
			my %snp;
			my %allele;
			#print"$seq\n";
			
			$allele{$ch}{$pos}{"-"}=0;
			$allele{$ch}{$pos}{"heter"}=0;
			$allele{$ch}{$pos}{"A"} =0;
			$allele{$ch}{$pos}{"T"} =0;
			$allele{$ch}{$pos}{"C"} =0;
			$allele{$ch}{$pos}{"G"} =0;
			for my $k(2..($length -1)){
				if($line[$k] eq "M"){
					$allele{$ch}{$pos}{"A"}++;
					$allele{$ch}{$pos}{"C"}++;
					$allele{$ch}{$pos}{"heter"}++;	
				}
				elsif($line[$k] eq "R"){
					$allele{$ch}{$pos}{"A"}++;
					$allele{$ch}{$pos}{"G"}++;	
					$allele{$ch}{$pos}{"heter"}++;
				}
				elsif($line[$k] eq "W"){
					$allele{$ch}{$pos}{"A"}++;
					$allele{$ch}{$pos}{"T"}++;
					$allele{$ch}{$pos}{"heter"}++;
				}
				elsif($line[$k] eq "S"){
					$allele{$ch}{$pos}{"C"}++;
					$allele{$ch}{$pos}{"G"}++;		
					$allele{$ch}{$pos}{"heter"}++;				
				}
				elsif($line[$k] eq "Y"){	
					$allele{$ch}{$pos}{"T"}++;
					$allele{$ch}{$pos}{"C"}++;
					$allele{$ch}{$pos}{"heter"}++;
				}
				elsif($line[$k] eq "K"){
					$allele{$ch}{$pos}{"T"}++;
					$allele{$ch}{$pos}{"G"}++;	
					$allele{$ch}{$pos}{"heter"}++;
				}
				elsif($line[$k] eq "-"){
					$allele{$ch}{$pos}{"-"}=$allele{$ch}{$pos}{"-"}+2;
				}	
				else{
					$allele{$ch}{$pos}{$line[$k]}=$allele{$ch}{$pos}{$line[$k]}+2;			
				}
			}
			
			#print INFO"\#chr\tpos\t$head\n";
			print INFO"$ch\t$pos\t";
			for my $m (@type){
				my $frequ;
				if($m eq "-"){
					$frequ= $allele{$ch}{$pos}{$m}/(($length-2)*2);
				}
				elsif($m eq "heter"){
					if((($length-2)*2-$allele{$ch}{$pos}{"-"}) ==0){
						$frequ = $allele{$ch}{$pos}{$m}/(-1);
					}
					else{
						$frequ= $allele{$ch}{$pos}{$m}/(($length-2)*2-$allele{$ch}{$pos}{"-"});
					}
				}
				else{
					if((($length-2)*2-$allele{$ch}{$pos}{"-"}) ==0){
						$frequ = $allele{$ch}{$pos}{$m}/(-1);
					}
					else{
						$frequ= $allele{$ch}{$pos}{$m}/(($length-2)*2-$allele{$ch}{$pos}{"-"});	
					}
				}
				print INFO"$frequ\t";
				if($frequ !=0){
					$snp{$ch}{$pos}{$m}=$frequ;	
				}
			}
			#print INFO"\t";		
			
		#sort the frenqu in this postion	
		#remove missing data > 80% ,remove maf of allele < 0.05 ,only two allele in one postion is left
			my @count;
			for my $n (keys %{$snp{$ch}{$pos}}){
				if($n ne "-"){
					push (@count,$snp{$ch}{$pos}{$n});	
				}
			}
			my $maf =0;
			@count=sort{$a <=> $b} @count;
			my $allele_length = @count;
			if($allele_length !=0){
				$maf =shift @count;
			}
			print INFO"$maf\n";	
				
			for my $i(2..($length -1)){
				if($line[$i] eq "-"){
					$ha{$head[$i]}{"miss"}++;
				}
				elsif($line[$i] eq "R" || $line[$i] eq "Y" || $line[$i] eq "M" || $line[$i] eq "K" || $line[$i] eq "S" || $line[$i] eq "W"){
					$ha{$head[$i]}{"heter"}++;
				}
			}
			$total++;
		}
	}
	
	close IN;
	close INFO;
	
	
	open OUT,">",$out;
	print OUT"\#id\tmiss\theterozygosis\ttotal\n";
	
	for my $i(keys %ha){
		print OUT"$i\t$ha{$i}{miss}\t$ha{$i}{heter}\t$total\n";
	}
	close OUT;	
	
	
}










=p
sub gwas{
	my ($phentype,$genotype,$output);
	GetOptions(
			"t|traits=s" => \$traits,
	        "g|genotype=s" => \$genotype,
	        "o|output=s" => \$output,
	        "p|program=s" => \$program,
	        
	);
	
die(qq/Usage: GWAStool.pl GWAS [option] -t phenotype -g genotype -o output_fold \n
Options: -t|traits 		The input phenotype\n
		 -g|genotype 	The genotype files(genotype.ped genotype.map)\n	
         -o|output      The result fold\n
/) unless ( $traits && $genotype);
	
	system "mkdir $output";
	
	open IN,"<",$traits;
	open OUT,">","$output/input_traits.txt";
	
	my $l=1;
	my $length;
	
	my %ha;
	while(<IN>){
		chomp;
		if($l==1){
			my @head = split/\t/,$_;
			print OUT"FID\t";
			print OUT"$_\n";
			$length = @head;
		}
		else{
			my @line=split/\t/,$_;
			$ha{$line[0]}=[@line];	
		}
		$l++;
	}
	close IN;
	#open IN,"<","D:\\test\\individual_new.txt";
	
	open IN,"<","list.txt";
	while(<IN>){
		chomp;
		my @line1=split;
		if(exists $ha{$line1[0]}){
			my @line2=join"\t",@{$ha{$line1[0]}};
			print OUT"$line1[0]\t";
			print OUT"@line2\n";
		}
		else{
			print OUT"$line1[0]\t";
			print OUT"$line1[0]\t";
			for my $i(1..($length-1)){
				print OUT"NA\t"; 
			}
			print OUT"\n";
		}
	}
	close IN;
	close OUT;
	
	###split the phenotype
	
	open IN,"<","$in/input_traits.txt";
	
	my @head;
	my $ll=1;
	#print "123\n";
	while(<IN>){
		chomp;
		if($ll==1){
			#print"$_\n";
			@head=split/\t/,$_;
		}
		$ll++;
	}
	close IN;
	
	print"@head\n";
	
	
	my $head_length=@head;
	for my $h(2..($head_length-1)){
		open IN,"<","$in/input_traits.txt";
		open OUT,">","$in/$head[$h]";
		my $lll=1;
		while(<IN>){
			chomp;
			if($lll==1){
		
			}
			else{
				my @line=split/\t/,$_;
				if($line[$h] eq "NA"){
					print OUT"$line[0]\t$line[0]\t-9\n";	
				}
				else{
					print OUT"$line[0]\t$line[0]\t$line[$h]\n"
				}
			}
			$lll++;
		}
		close IN;
		close OUT;		
	}
	
	system"mkdir $in/result_lmm";
	
	for my $m(2..($head_length-1)){
		system"mkdir $in/result_lmm/$head[$m]";
		
		system"fastlmmc -file genotype/all_for_fastlmm -fileSim genotype/all_for_fastlmm -pheno $in/$head[$m] -simOut $in/result_lmm/$head[$m]/$head[$m].kinship -maxThreads 20 -out $in/result_lmm/$head[$m]/$head[$m].lmm.result";
		##plot
		system"perl plot.pl $in/result_lmm/$head[$m]/$head[$m].lmm.result $in/$head[$m] $in/result_lmm/$head[$m]/$head[$m]";
	}
		
}

=cut






sub usage {
  die(qq/
Usage:   GWAStools.pl <command> [<arguments>]\n
Command: boxcox               boxcox transformation for phenotype
         genotype2hapmap      convert the genotype format to hapmap;
         
         vcf2genotype         convert the vcf format to genotype file;
         hapmap2ped           convert the hapmap format to ped file;
         hapmap2map           convert the hapmap format to map file;
         
         hapmap2vcf           convert the hapmap format to map file
         sub_hapmap           extract the list individuals from hapmap

         hapmap2genotype      convert the hapmap format to genotype
         genotype2table       convert the genotype format to table
         
         genotype_filter      genotype filter
         SNP_stat             stat the SNP (table format)
         
         kinship              calculate the kinship
         lambda               calculate the lambda for the GWAS result
         
         hapmap2stru		  convert the hapmap format to structure formate
         
         SNP_com		      compare the pairwise SNP

Notes: Commands with description endting with (*) may need bcftools
       specific annotations.
\n/);
}


