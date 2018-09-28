#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#define NO_XSLOCKS
#include "XSUB.h"
#define NEED_newRV_noinc
#include "ppport.h"
#include <yaml.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "etc/perl_libyaml.c"

/* C functions */

MODULE = YAML::LibYAML::API::XS      PACKAGE = YAML::LibYAML::API::XS

PROTOTYPES: DISABLE

# XS code

SV *
parse_string_events(const char *input, AV *perl_events)
    CODE:
    {
        dXCPT;
        yaml_parser_t parser;

        XCPT_TRY_START
        {
            if (!yaml_parser_initialize(&parser)) {
                croak("%s\n", "Could not initialize the parser object");
            }
            yaml_parser_set_input_string(&parser, input, strlen(input));

            parse_events(&parser, perl_events);

            yaml_parser_delete(&parser);

        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_parser_delete(&parser);
            XCPT_RETHROW;
        }

        RETVAL = newSViv(1);
    }
    OUTPUT: RETVAL

SV *
parse_file_events(const char *filename, AV *perl_events)
    CODE:
    {
        dXCPT;
        yaml_parser_t parser;
        FILE *input;

        XCPT_TRY_START
        {
            if (!yaml_parser_initialize(&parser)) {
                croak("%s\n", "Could not initialize the parser object");
            }
            input = fopen(filename, "rb");
            yaml_parser_set_input_file(&parser, input);

            parse_events(&parser, perl_events);

            yaml_parser_delete(&parser);

        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_parser_delete(&parser);
            XCPT_RETHROW;
        }

        RETVAL = newSViv(1);
    }
    OUTPUT: RETVAL

SV *
parse_filehandle_events(FILE *fh, AV *perl_events)
    CODE:
    {
        dXCPT;
        yaml_parser_t parser;

        XCPT_TRY_START
        {
            if (!yaml_parser_initialize(&parser)) {
                croak("%s\n", "Could not initialize the parser object");
            }
            yaml_parser_set_input_file(&parser, fh);

            parse_events(&parser, perl_events);

            yaml_parser_delete(&parser);

        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_parser_delete(&parser);
            XCPT_RETHROW;
        }

        RETVAL = newSViv(1);
    }
    OUTPUT: RETVAL


SV *
libyaml_version()
    CODE:
    {
        const char *v = yaml_get_version_string();
        RETVAL = newSVpv(v, strlen(v));

    }
    OUTPUT: RETVAL
