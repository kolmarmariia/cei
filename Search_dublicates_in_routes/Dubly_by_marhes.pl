use CGI;
use strict;
use WWW::Mechanize;
use Try::Tiny;


my %number_marsh;
my %route_long_name;
my %pares;
my %pares_marsh;
my %count;
my %posl_id;
my %posl_name;
my %pares_name;
my %massiv_koeff;
my %para_marsh;
my %count_marsh;
my %count_pares;
my %count_pares_dubl;

open FT,"<Marshes.csv" or die $!;
#вывод результатов в файл по связям
open FS,">res.csv" or die $!;

#записываем номера маршрутов в привязке к line_id
foreach (<FT>){ 
		$_=~s/\n//;
		$_=~s/"//g;
		my @r=split(/,/,$_);
		for(my $l=0;$l<@r;$l++){
			if($r[$l]=~m/A/){
				print FS $r[$l];
				print FS "\n";
			}
		}
	}
 close FT;

close (FS);