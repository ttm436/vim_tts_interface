use warnings;
use strict;
use JSON; 
use File::Basename;

my $dir;
BEGIN {$dir = dirname(__FILE__);}
use constant FILE => { 
				CACHE_DIR   => $dir . '/cache/',
				SCRIPTS_DIR => $dir . '/cache/script/',
				GUI_DIR     => $dir . '/cache/gui/',
				MESSAGE     => $dir . '/__message__',
};
					
my ($operation) = @ARGV;
if ($operation eq 'load')
{
	system('nc -ld 127.0.0.1 39998 > ' . FILE->{MESSAGE} . ' &');
	system('echo \'{"messageID":0}\' | nc -w3 127.0.0.1 39999');

	open my $file, '< ' . FILE->{MESSAGE};
	my $json_ref = eval{local $/ = undef; from_json(<$file>)};
	close $file;

	my @scripts;
	my @guis;
	if ($json_ref->{messageID} == 1)
	{
		foreach (@{$json_ref->{scriptStates}})
		{
			my $script_name = $_->{name} // $_->{guid};

			my $script_data = $_->{script};
			push @scripts, (my $script = FILE->{SCRIPTS_DIR} . "/$script_name.lua");
			open my $script_f, '> ' . $script;
			print $script_f $script_data;
			close $script_f;
			
			my $gui_data = $_->{gui} // '';
			push @guis, (my $gui = FILE->{GUI_DIR}. "/$script_name.xml");
			open my $gui_f, '> ' . $gui;
			print $gui_f $gui_data;
			close $gui_f;
		}
	}
	print join(' ', @scripts);
}
if ($operation eq 'save')
{
	my $json_ref = { 
					messageID    => 1,
					scriptStates => []
	};

	foreach (glob FILE->{SCRIPTS_DIR}. '/*.lua')
	{
		open my $script_f, "< $_";
		my $script_data = eval{local $/ = undef;  <$script_f> };
		close $script_f;
		my $script_name = eval{$_ =~ /^.*\/(.*)\.lua$/; $1};
		my $guid = (($script_name eq 'Global') ? '-1' : $script_name);

		my $script_state = {name => $script_name,
							guid => $guid,
							script => $script_data,
							ui => ''}; 
							
		push @{$json_ref->{scriptStates}}, $script_state;
	}
	my $json_string = to_json($json_ref);
	open my $file, '> ' . FILE->{MESSAGE};
	print $file $json_string;
	close $file;
	
	system("nc -w3 127.0.0.1 39999 < " . FILE->{MESSAGE})
}
			

	
