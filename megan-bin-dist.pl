#!/usr/bin/perl -w

use strict;
use warnings;

die "Usage:\nperl $0 <megan-bin> <bins>" if( @ARGV != 2 );

my ($megan_bins, $annotation) = @ARGV;

my $version               = '0.0.2';

my %taxon_h               = ();
my %function_subset       = ();
my %function_reads        = ();
my %taxon_type_h          = ();
my @taxon_type_t          = ();
my @catalog_type_t        = ();

load_taxon_bins();
load_catalog_bins();
print_stats();

exit;

sub load_taxon_bins{

    open (DATA,         $megan_bins) ||die "$!";
    while (<DATA>) {
       chomp;
       my @its = split /\t/ , $_;
       $taxon_h{ $its[0] }  = $its[-1];
    }
    close DATA;
}

sub load_catalog_bins{
    
    open (DATA ,       $annotation) || die "$!"; 
    while(<DATA>){
       chomp; 
       next if(/^#/);       
      
       my @its = split /\t/ , $_;
       my $bit = 0;

       foreach my $reads (split /,/, $its[2]) {

          $function_reads{ $reads }  = ();
          next if(! exists  $taxon_h{ $reads } );
          $bit++;

          $function_subset{ $its[0] . "\t". $its[1] }{ $taxon_h{ $reads } }++;

          if(! exists $taxon_type_h{ $taxon_h{ $reads } }){
              push @taxon_type_t, $taxon_h{ $reads };
              $taxon_type_h{ $taxon_h{ $reads } } = ();
          }
       }
       push @catalog_type_t,  qq{$its[0]\t$its[1]} if( $bit > 0);

    }
    close DATA;
}

sub print_stats {
    
    my $total_reads  = scalar keys %function_reads;
    print qq{#$total_reads\n};
    print qq{#catalog\tnumber\t}, join("\t", @taxon_type_t), "\n";
    
    foreach my $catalog ( @catalog_type_t ) {
        
        my @levels = ();
        foreach my $t ( @taxon_type_t ) {
            
            if(exists $function_subset{ $catalog }{ $t }){
                 push @levels, $function_subset{ $catalog }{ $t };
            }else{
                 push @levels, 0;
            }
        }
        print qq{$catalog\t}, join("\t", @levels), "\n";
    }

}