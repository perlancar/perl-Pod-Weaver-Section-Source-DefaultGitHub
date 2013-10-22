package Pod::Weaver::Section::Source::DefaultGitHub;

use 5.010001;
use Moose;
#use Text::Wrap ();
with 'Pod::Weaver::Role::Section';

#use Log::Any '$log';

use Moose::Autobox;

# VERSION

sub weave_section {
  my ($self, $document, $input) = @_;

  my $repo_url = $input->{distmeta}{resources}{repository};
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
  my $text = "Source repository is at L<$repo_url>.";

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
# ABSTRACT: Add a SOURCE section

=for Pod::Coverage weave_section

=head1 SYNOPSIS

In your C<weaver.ini>:

 [Source::DefaultGitHub]

If C<repository> is not specified in dist.ini, will search for github user/repo
name from git config file (C<.git/config>).

To specify a source repository other than C<https://github.com/USER/REPO>, in
dist.ini:

 [MetaResources]
 homepage=http://example.com/


=head1 DESCRIPTION

This section plugin adds a SOURCE section.


=head1 SEE ALSO

L<Pod::Weaver::Section::SourceGitHub>

=cut
