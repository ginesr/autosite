#!perl

use strict;
use Autosite::Template::Plugin;

my $plugin = Autosite::Template::Plugin->new;
$plugin->active(1);
$plugin->variable('DATE');
$plugin->content('2000-01-01');

return $plugin;