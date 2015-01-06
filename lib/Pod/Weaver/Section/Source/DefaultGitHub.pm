package Pod::Weaver::Section::Source::DefaultGitHub;

use 5.010001;
use Moose;
#use Text::Wrap ();
with 'Pod::Weaver::Role::Section';

#use Log::Any '$log';

use Moose::Autobox;

has text => (
    is => 'rw',
    isa => 'Str',
    default => 'Source repository is at L<%s>.',
);

# VERSION

sub weave_section {
  my ($self, $document, $input) = @_;

  my $repo_url = $input->{distmeta}{resources}{repository};
  if (ref($repo_url) eq 'HASH') { $repo_url = $repo_url->{web} }
  if (!$repo_url) {
      my $file = ".git/config";
      die "Can't find git config file $file" unless -f $file;
      my $ct = do {
          local $/;
          open my($fh), "<", $file or die "Can't open $file: $!";
          ~~<$fh>;
      };
      $ct =~ m!github\.com:([^/]+)/(.+)\.git!
          or die "Can't parse github address in $file";
      $repo_url = "https://github.com/$1/$2";
  }
  my $text = sprintf $self->text, $repo_url;

  #$text = Text::Wrap::wrap(q{}, q{}, $text);

  $document->children->push(
    Pod::Elemental::Element::Nested->new({
      command  => 'head1',
      content  => 'SOURCE',
      children => [
        Pod::Elemental::Element::Pod5::Ordinary->new({ content => $text }),
      ],
    }),
  );
}

no Moose;
1;
# ABSTRACT: Add a SOURCE section (repository defaults to GitHub)

=for Pod::Coverage weave_section

=head1 SYNOPSIS

In your C<weaver.ini>:

 [Source::DefaultGitHub]

If C<repository> is not specified in dist.ini, will search for github user/repo
name from git config file (C<.git/config>).

To specify a source repository other than C<https://github.com/USER/REPO>, in
dist.ini:

 [MetaResources]
 repository=http://example.com/


=head1 DESCRIPTION

This section plugin adds a SOURCE section, using C<repository> metadata or (if
not specified) GitHub.


=head1 ATTRIBUTES

=head2 text

The text that is added. C<%s> is replaced by the repository url.

Default: C<Source repository is at LE<lt>%sE<gt>.>


=head1 SEE ALSO

L<Pod::Weaver::Section::SourceGitHub>

=cut
