
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "low-level XS-based FASTQ/FASTA parser",
  "dist_author" => [
    "Chris Fields <cjfields\@bioperl.org>"
  ],
  "dist_name" => "Bio-readfq",
  "dist_version" => "0.01",
  "license" => "perl",
  "module_name" => "Bio::readfq",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {},
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
