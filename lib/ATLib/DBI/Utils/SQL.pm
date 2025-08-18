package ATLib::DBI::Utils::SQL;
use Mouse;

use ATLib::Utils qw{ as_type_of };
use ATLib::Std;

# Class Methods
sub parse_bind_variable
{
    shift;
    my $prefix = shift;
    my $suffix = shift;
    my $sql = shift;

    if (as_type_of('ATLib::Std::String', $prefix))
    {
        $prefix = $prefix->as_string();
    }
    if (as_type_of('ATLib::Std::String', $suffix))
    {
        $suffix = $suffix->as_string();
    }
    if (!as_type_of('ATLib::Std::String', $sql))
    {
        $sql = ATLib::Std::String->from($sql);
    }

    my @tokens = $sql->split(' ');
    my $bind_variable_list = ATLib::Std::Collections::List->of('ATLib::Std::String');
    for my $token (@tokens)
    {
        my $bind_variable = '';
        my $regex = qr/^ [\s,]* @{[quotemeta($prefix)]} (\w+[\w\d]*) @{[quotemeta($suffix)]} [\s,]*$/xms;
        if ($token =~ $regex)
        {
            $bind_variable = ATLib::Std::String->from($1);
            $bind_variable_list->add($bind_variable);
        }
    }

    return $bind_variable_list;
}

__PACKAGE__->meta->make_immutable();
no Mouse;
1;