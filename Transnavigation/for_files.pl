use strict;
use warnings;
use FileHandle;
use File::Copy;


my $parent = "C:/Users/makol/Documents/Python_Scripts/Git/user_scripts/masha_k/Transnavigation/data/data";

my ($par_dir, $sub_dir);
opendir($par_dir, $parent);
while (my $sub_folders = readdir($par_dir)) {
       next if ($sub_folders =~ /^..?$/);  # skip . and ..
       my $path = $parent . '/' . $sub_folders;
       next unless (-d $path);   # skip anything that isn't a directory

       opendir($sub_dir, $path);
       while (my $file = readdir($sub_dir)) {
           #next unless $file =~ /\.html?$/i;
           #my $full_path = $path . '/' . $file;
           print($file);
		   if($file=~m/_4/){
			move($path.'/'.$file,$parent.'/'.$file);
		}			
       }
       closedir($sub_dir);
}
closedir($par_dir);

