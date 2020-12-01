#определили всякие библиотеки
use strict;
use warnings;
use FileHandle;
use File::Copy;
use feature ':5.12';
use autodie;
use Time::HiRes qw(gettimeofday tv_interval);

my @mr_id;
my @rl_id;
my @rc_orderby;
my @ssId;
my @tr_id;
my @timenav;
my @mark;
my @geometry;
my @ss_lat;
my @ss_long;
my @len;
my @number_circle;
my %count_stops;
my @tabelnum;
my @graph;

 my $start_time = [ gettimeofday ];


 my $path = "./done_test/";
 open my $outfh, ">>", "for_perl_test.csv";
 my $seenheader = 0;


 opendir my $par_dir, "$path";
 while (my $file = readdir($par_dir)) {
        #print($path.$file);
		next unless $file =~ /.csv$/;
		open my $infh, '<', "$path$file";
		while (<$infh>) {
			print $outfh $_ if $. > 1 || ! $seenheader++;
			}
       }
 closedir($par_dir);


#1. Записали сколько в каждом маршруте остановок

open FS,"<stops_by_mr_id.csv" or die $!;

#считываем файлик, который сгенерили в пункте 4 "Part1.Cartesian distance.ipynb"
my $p=0;
foreach (<FS>){ 
	$_=~s/\n//;
	$_=~s/"//g;
	if($p>0){
	my @r=split(/,/,$_);
	#здесь идет запись в хэш-массив
	$count_stops{$r[0]}=$r[1]-1; #на всякий случай
	print $count_stops{$r[0]},"\n";}
	$p++;
}		
close FS;

 open FT,"<for_perl_test.csv" or die $!;
 my $k=0;

#2. Считываю данные из файла for_perl.csv для дальнейше обработки

print 'read_file for_perl',"\n";
foreach (<FT>){ 
		$_=~s/\n//;
		$_=~s/"//g;
		my @r=split(/;/,$_);	
		$mr_id[$k]=$r[0];
		$rl_id[$k]=$r[1];
		if($k==0){$rc_orderby[$k]=$r[2];}else{$rc_orderby[$k]=int($r[2]);
		}
		$ssId[$k]=$r[3];
		$tr_id[$k]=$r[4];
		$timenav[$k]=$r[5];
		if($k==0){$len[$k]=$r[6];}else{$len[$k]=int($r[6]);};
		$geometry[$k]=$r[7];
		$ss_lat[$k]=$r[8];
		$ss_long[$k]=$r[9];
		$tabelnum[$k]=$r[10];
		$number_circle[$k]=$r[11];
	$k++;           	
}	
close FT;

print 'end of read_file for_perl',"\n";
#3. Фиксирую начальные значения для направления, посл-ого номера остановки, транспортного средства и номера поездки от одной конечки до другой.
my $stop_now=0;
my $rc_orderby_now=1;
my $l=0;
my $len_max=$len[1];
my $rl_id_now=0;
my $num_now=0;
my $tabelnum_now=$tabelnum[1];
my $number_circle_now=1;
my $count_stops_now=0;
#определяю переменную, куда буду записывать остановки , встретившиеся на в прошедших строчках.
my $line;
my $a;
$number_circle_now=1;
open FS2,">Res2_test.csv" or die $!;


#4. Записала заголовки в файл окончательной выгрузки

print FS2 $mr_id[0],";",$rc_orderby[0],";",$ssId[0],";",$tr_id[0],";",$timenav[0],";",$len[0],";",$geometry[0],";",$ss_lat[0],";",$ss_long[0],";",$tabelnum[0],";",$rl_id[0],"\n";
	
#5. Пошла новым циклом по всем записямs
	print "второй цикл \n";
for(my $i=1;$i<@rl_id;$i++){
	if($tabelnum[$i]=~m/$tabelnum_now/){
		if (($len[$i]<=$len_max)&($rc_orderby[$i]==1)){
            $rl_id_now=$rl_id[$i];
            $rc_orderby_now=$rc_orderby[$i];
#			$number_circle[$i]=$number_circle_now;
print FS2 $mr_id[$i],";",$rc_orderby[$i],";",$ssId[$i],";",$tr_id[$i],";",$timenav[$i],";",$len[$i],";",$geometry[$i],";",$ss_lat[$i],";",$ss_long[$i],";",$tabelnum[$i],";",$rl_id[$i],"\n";
            if($len[$i]>$len_max){
				$len_max=$len[$i]; 
			} 
	}elsif(($rl_id[$i]==$rl_id_now)&($rc_orderby[$i]>$rc_orderby_now)&($len[$i]<$len_max)){
            $rc_orderby_now=$rc_orderby[$i];
#            $number_circle[$i]=$number_circle_now;
            print FS2 $mr_id[$i],";",$rc_orderby[$i],";",$ssId[$i],";",$tr_id[$i],";",$timenav[$i],";",$len[$i],";",$geometry[$i],";",$ss_lat[$i],";",$ss_long[$i],";",$tabelnum[$i],";",$rl_id[$i],"\n";
        }elsif(($rl_id[$i]==$rl_id_now)&($rc_orderby[$i]>$rc_orderby_now)){
			$len_max=$len[$i];}
	}else{
	#print $mr_id[$i],"\n";
		$number_circle_now=1;
		$tabelnum_now=$tabelnum[$i];
		if($rc_orderby[$i]==1){
			print FS2 $mr_id[$i],";",$rc_orderby[$i],";",$ssId[$i],";",$tr_id[$i],";",$timenav[$i],";",$len[$i],";",$geometry[$i],";",$ss_lat[$i],";",$ss_long[$i],";",$tabelnum[$i],";",$rl_id[$i],"\n";
		}
	}
}
	

close(FS2);

my $end_time = [ gettimeofday ];

my $elapsed = tv_interval($start_time,$end_time);
print $elapsed;
