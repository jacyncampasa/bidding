use Test::More;

BEGIN {
  use_ok('WyrlsX::Bidding::Info');
  use_ok('DBI');
}

my $DBI   = "DBI";

my ($DBH, $DB, $DS, $USER, $PASS ) = (undef, 'database=ppp;host=localhost;port=3306', "DBI:mysql:database=ppp;host=localhost;port=3306", "ppp", "pppppp");
$DBH = $DBI->connect( $DS, $USER, $PASS, { RaiseError => 1 } )
      or die "Can't connect to $DS: $DBH->errstr\n" ;

my $TEST_CASES = [
  # raw_input, expected_item_name, expected_lowest_unique_bid
  ["2015-03-02", "Iphone", "2.00"],
  ["2015-03-01", "", 0],
];


my $CLASS = "WyrlsX::Bidding::Info";
{
  my $o = $CLASS->new( DBH => $DBH, campaign_code => "BIDLOWQ12015" );

  foreach my $tc (@$TEST_CASES) {
    is $o->get_item($tc->[0]), $tc->[1];
    is $o->get_lowest_unique_bid(), $tc->[2], "auction_date => " . $tc->[0];
  }
}


done_testing()


# Check
