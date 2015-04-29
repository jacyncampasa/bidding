package WyrlsX::Bidding::Info;
use strict;
use Moose;

has 'DBH'           => ( isa => 'Ref', is => 'rw', required => 1);
has 'campaign_code' => ( isa => 'Str', is => 'rw', required => 1);
has 'item'          => ( isa => 'Ref', is => 'ro', required => 0, writer => '_set_item');

my $sth_get_item = undef;
my $sth_get_lowest_unique_bid = undef;

sub BUILD {
    my $self = shift;

    $sth_get_item               = $self->DBH->prepare("SELECT * FROM auction_item WHERE campaign_code = '" . $self->campaign_code . "' AND auction_date = ?;");
    $sth_get_lowest_unique_bid  = $self->DBH->prepare("SELECT ao.offer_amount as bid_amount, count(ab.id) as bid_count 
                                                        FROM auction_offer AS ao INNER JOIN auction_bid AS ab ON (ao.id=ab.offer_id)
                                                        WHERE ao.item_id = ? 
                                                        GROUP BY ab.offer_id
                                                        HAVING bid_count = 1
                                                        ORDER BY bid_amount ASC;");
}

sub get_item {
    my ($self, $auction_date) = @_;
    
    my $rc = $sth_get_item->execute( $auction_date ) or die "$0: get_item() FATAL: Unable to execute query\n";
    if ($rc eq '0E0') {
        $self->_set_item({});
        return '';
    } else {
        my $href = $sth_get_item->fetchrow_hashref() or die "$0: get_item() FATAL: fetchrow_hashref query failed\n";
        $self->_set_item($href);
        return $self->item->{name};
    }

    return undef;
}

sub get_lowest_unique_bid {
    my ($self, $msisdn) = @_;

    my $rc = $sth_get_lowest_unique_bid->execute( $self->item->{id} ) or die "$0: get_lowest_unique_bid() FATAL: Unable to execute query\n";
    if ($rc eq '0E0') {
        return 0;
    } else {
        my $href = $sth_get_lowest_unique_bid->fetchrow_hashref() or die "$0: get_lowest_unique_bid() FATAL: fetchrow_hashref query failed\n";
        return $href->{bid_amount};
    }

    return undef;
}


1;


__END__ 
