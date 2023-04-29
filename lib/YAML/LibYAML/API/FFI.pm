package YAML::LibYAML::API::FFI;
use strict;
use warnings;

use 5.020;
use FFI::Platypus 1.00;
use FFI::CheckLib 0.27 ();
use FFI::C;
use Data::Dumper;

our $VERSION = '0.04'; # VERSION

sub _lib {
    my @args = (lib => '*', verify => sub { $_[0] =~ /yaml/ }); #, symbol => "yaml_get_version_string");
    my($first) = FFI::CheckLib::find_lib @args, alien => 'Alien::LibYAML';
    die "unable to find libs" unless $first;
    $first;
}

my $ffi = FFI::Platypus->new(
    api => 1,
    lib => _lib(),
);
FFI::C->ffi($ffi);

$ffi->attach(['yaml_get_version_string'=>'libyaml_version'] => [] => 'string', sub {
    my ($xsub) = @_;
    return $xsub->();
});

package YAML::LibYAML::API::FFI::version_dir {
    use overload
        '""' => sub { shift->as_string };
    FFI::C->struct([
        major => 'int',
        minor => 'int',
    ]);
    sub as_string {
        my ($self) = @_;
        sprintf "[major:%d minor:%d]", $self->major, $self->minor;
    }
}

package YAML::LibYAML::API::FFI::event_type {
    $ffi->load_custom_type('::Enum', 'yaml_event_type_t',
        { rev => 'int', package => 'YAML::LibYAML::API::FFI::event_type', prefix => 'YAML_' },
        'NO_EVENT',
        'STREAM_START_EVENT',
        'STREAM_END_EVENT',
        'DOCUMENT_START_EVENT',
        'DOCUMENT_END_EVENT',
        'ALIAS_EVENT',
        'SCALAR_EVENT',
        'SEQUENCE_START_EVENT',
        'SEQUENCE_END_EVENT',
        'MAPPING_START_EVENT',
        'MAPPING_END_EVENT',
    );
}


package YAML::LibYAML::API::FFI::YamlMark {
    FFI::C->struct([
        index => 'int',
        line =>'int',
        column => 'int',
    ]);
}

package YAML::LibYAML::API::FFI::event {
    FFI::C->struct([
        type => 'enum',
        start_mark => 'yaml_mark_t',
        end_mark => 'yaml_mark_t',
    ]);
}
# /** The event structure. */
# typedef struct yaml_event_s {
# 
#     /** The event data. */
#     union {
# 
#         /** The stream parameters (for @c YAML_STREAM_START_EVENT). */
#         struct {
#             /** The document encoding. */
#             yaml_encoding_t encoding;
#         } stream_start;
# 
#         /** The document parameters (for @c YAML_DOCUMENT_START_EVENT). */
#         struct {
#             /** The version directive. */
#             yaml_version_directive_t *version_directive;
# 
#             /** The list of tag directives. */
#             struct {
#                 /** The beginning of the tag directives list. */
#                 yaml_tag_directive_t *start;
#                 /** The end of the tag directives list. */
#                 yaml_tag_directive_t *end;
#             } tag_directives;
# 
#             /** Is the document indicator implicit? */
#             int implicit;
#         } document_start;
# 
#         /** The document end parameters (for @c YAML_DOCUMENT_END_EVENT). */
#         struct {
#             /** Is the document end indicator implicit? */
#             int implicit;
#         } document_end;
# 
#         /** The alias parameters (for @c YAML_ALIAS_EVENT). */
#         struct {
#             /** The anchor. */
#             yaml_char_t *anchor;
#         } alias;
# 
#         /** The scalar parameters (for @c YAML_SCALAR_EVENT). */
#         struct {
#             /** The anchor. */
#             yaml_char_t *anchor;
#             /** The tag. */
#             yaml_char_t *tag;
#             /** The scalar value. */
#             yaml_char_t *value;
#             /** The length of the scalar value. */
#             size_t length;
#             /** Is the tag optional for the plain style? */
#             int plain_implicit;
#             /** Is the tag optional for any non-plain style? */
#             int quoted_implicit;
#             /** The scalar style. */
#             yaml_scalar_style_t style;
#         } scalar;
# 
#         /** The sequence parameters (for @c YAML_SEQUENCE_START_EVENT). */
#         struct {
#             /** The anchor. */
#             yaml_char_t *anchor;
#             /** The tag. */
#             yaml_char_t *tag;
#             /** Is the tag optional? */
#             int implicit;
#             /** The sequence style. */
#             yaml_sequence_style_t style;
#         } sequence_start;
# 
#         /** The mapping parameters (for @c YAML_MAPPING_START_EVENT). */
#         struct {
#             /** The anchor. */
#             yaml_char_t *anchor;
#             /** The tag. */
#             yaml_char_t *tag;
#             /** Is the tag optional? */
#             int implicit;
#             /** The mapping style. */
#             yaml_mapping_style_t style;
#         } mapping_start;
# 
#     } data;
# 
# 
# } yaml_event_t;

#    $ffi->type('record(YAML::LibYAML::API::FFI::event)' => 'yaml_event_t');
#    $ffi->attach( yaml_stream_start_event_initialize => [qw/ yaml_event_t* yaml_encoding_t /] => ['int'] );


#$ffi->type( 'opaque' => 'yaml_event_t' );
1;

