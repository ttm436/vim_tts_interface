use warnings;
use strict;
use JSON;

my ($operation, $temp_d) = @ARGV;
my $scripts_d = $temp_d . '/scripts/';
if ($operation eq 'load')
{
	open my $file, "< $temp_d/__message__";
	my $json_ref;
	{
		local $/ = undef;
		$json_ref = from_json(<$file>);
	}
	close $file;
	if ($json_ref->{messageID} == 1)
	{
		foreach (@{$json_ref->{scriptStates}})
		{
			my $script_n = $_->{name} // $_->{guid};
			my $script_c = $_->{script};
			open my $script_f, "> $scripts_d/$script_n.lua";
			print $script_f $script_c;
			close $script_f;
		}
	}
}
if ($operation eq 'save')
{
	my $json_ref = { messageID => 1,
					 scriptStates => []};

	foreach (glob $scripts_d . '/*.lua')
	{
		$_ =~ /$scripts_d\/(.*)\.lua/;
		my $script_n = $1;
		my $guid = (($script_n eq 'Global') ? "-1" : $script_n);
		open my $script_f, "< $scripts_d/$script_n.lua" or die "$!";
		local $/ = undef;
		my $script_c = <$script_f>;
		close $script_f;
		my $script_state = {name => $script_n,
							guid => $guid,
							script => $script_c,
							ui => ''};
							
		push @{$json_ref->{scriptStates}}, $script_state;
	}
	my $json_string = to_json($json_ref);
	open my $file, "> $temp_d/__message__";
	print $file $json_string;
	close $file;
}
			

	
