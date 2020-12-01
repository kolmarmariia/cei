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

open FT,"<STN.csv" or die $!;
#записываем номера маршрутов в привязке к line_id
foreach (<FT>){ 
		$_=~s/\n//;
		$_=~s/"//g;
		my @r=split(/;/,$_);
		my $key=$r[0]."_".$r[1];
			$number_marsh{$key}=$r[3]." ".$r[2];
			$number_marsh{$key}=~s/tramway/Tm/g;
			$number_marsh{$key}=~s/trolleybus/Tb/g;
			$number_marsh{$key}=~s/minibus/a/g;
			$number_marsh{$key}=~s/bus/A/g;
			$route_long_name{$key}=$r[4];
	}
 close FT;


open FT1,"<stop_seq.csv" or die $!;
   foreach (<FT1>){ 
		$_=~s/\n//;
		my @r=split(/;/,$_);
		my $key=$r[0]."_".$r[1];
		#записываем кол-во остановок на М-В-Н е
		if(($count{$key})&&($r[2]>$count{$key})){
			$count{$key}=$r[2]; 	#где номер последовательный
		}else{
			$count{$key}=1; 	#где номер последовательный
		}
		#записываем stop_id и название последовательно считанной остановки на М-В-Н е
		$posl_id{$key."_".$r[2]}= $r[3]; #stop_id
		$posl_name{$r[3]}= $r[4];
	}
 close FT1;

my $t=0;
#идем по всем записанным М-В-Н ам и записваем на связи маршруты, проходяшие по связи:
foreach my $key (keys %count)
{ 	my $id1="";
	my $id2="";
	#обрабатываем все связи (от 1-й до 2-й, от 1-й до 3-й, 1-4, 2-3,2-4,3-4 и т.д.)
	for (my $k=1; $k<$count{$key};$k++){
			$id1=$posl_id{$key."_".$k};
			for (my $i=2; $i<$count{$key}+1;$i++){
				$id2=$posl_id{$key."_".$i};
				my $para=$id1."_".$id2;
				if($id1!=$id2){
					if($pares{$para}){
						$pares{$para}=$pares{$para}.",".$key;
						$pares_marsh{$para}=$pares_marsh{$para}.",".$number_marsh{$key};
						$count_marsh{$para}++;
					}else{
						$pares{$para}=$key;
						$pares_marsh{$para}=$number_marsh{$key};
						$pares_name{$para}=$posl_name{$id1}."-".$posl_name{$id2};
					}
					$para_marsh{$key."_".$para}=$para;
				}
			}
		}
}

#идем по всем записанным М-В-Н ам и считаем количество связей, на которых нах-ся больше, чем 2 маршрута (смотрим по вхождению символа ",":

foreach my $key (keys %count)
{   my $num_marsh=$number_marsh{$key}.";".$route_long_name{$key}; 
	my $id1="";
	my $id2="";
	#обрабатываем все связи (от 1-й до 2-й, от 1-й до 3-й, 1-4, 2-3,2-4,3-4 и т.д.)
	for (my $k=1; $k<$count{$key};$k++){
			$id1=$posl_id{$key."_".$k};
			for (my $i=2; $i<$count{$key}+1;$i++){
				$id2=$posl_id{$key."_".$i};
				my $para=$id1."_".$id2;
				if($id1!=$id2){
					if($pares{$para}=~m/,/){
						$count_pares_dubl{$num_marsh}++;
					}
						$count_pares{$num_marsh}++;
				}
			}
		}

}
foreach my $num_marsh (keys %count_pares){
		if($count_pares{$num_marsh}==0){$massiv_koeff{$num_marsh}=0;}else{
		$massiv_koeff{$num_marsh}=$count_pares_dubl{$num_marsh}/$count_pares{$num_marsh};}
}

#вывод результатов в файл помаршрутно
open FS1,">res_koeff.csv" or die $!;
print FS1 "number_marsh;name_marsh;koeff\n";
foreach my $id (keys %massiv_koeff){
		print FS1 $id,";",$massiv_koeff{$id},"\n";

}
close (FS1);

#вывод результатов в файл по связям
open FS,">res_DUBLY.csv" or die $!;
print FS "pares;pares_name;id_marshes;marshes\n";
foreach my $id (keys %pares){
	if($pares_marsh{$id}=~m/,/){
		print FS $id,";",$pares_name{$id},";",$pares{$id},";",$pares_marsh{$id},"\n";
		}
}
close (FS);