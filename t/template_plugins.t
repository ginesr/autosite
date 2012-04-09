#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Autosite::Config;
use Test::More tests => 2;
use Test::Exception;

my $template = Autosite::Template->new;
my $config = Autosite::Config->new;

$config->plugins_compile(1);
$config->plugins_list('test_plugin.pl,invisible.pl');
$config->plugins_folder('templates/plugins');
$config->templates_cache(1);

$template->file('templates/test6.htm');
$template->config($config);

$template->cache->{'templates/plugins/invisible.pl'} = <<TEMPLATE;
#!perl

use strict;
use Autosite::Template::Plugin;

my \$bar = 'bar';

my \$plugin = Autosite::Template::Plugin->new;
\$plugin->active(1);
\$plugin->variable('FOO');
\$plugin->content(\$bar);

return \$plugin;
TEMPLATE


my $output = $template->render( {} );

like( $output, qr/2000-01-01/, 'Read plugin' );
like( $output, qr/then bar/, 'Read plugin from cache' );
