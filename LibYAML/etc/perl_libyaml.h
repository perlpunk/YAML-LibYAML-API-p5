#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#define NO_XSLOCKS
#include "XSUB.h"
#define NEED_newRV_noinc
#include "ppport.h"
#include <yaml.h>

char *
parser_error_msg(yaml_parser_t *parser, char *problem);

HV *
libyaml_to_perl_event(yaml_event_t *event);

int
parse_events(yaml_parser_t *parser, AV *perl_events);

int
perl_to_libyaml_event(yaml_emitter_t *emitter, HV *perl_event);

int
emit_events(yaml_emitter_t *emitter, AV *perl_events);

int
append_output(void *yaml, unsigned char *buffer, size_t size);

long
create_parser();

int
init_string(long id, const char* input);

int
parse_callback(long id, SV* code);

int
delete_parser(long id);
