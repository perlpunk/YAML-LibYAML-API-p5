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

            fclose(input);
            input = NULL;
            yaml_parser_delete(&parser);

        } XCPT_TRY_END

        XCPT_CATCH
        {
            if (input)
                fclose(input);
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
emit_string_events(AV *perl_events, HV *options)
    CODE:
    {
        dXCPT;
        yaml_emitter_t emitter;
        SV **val;
        SV *yaml = newSVpvn("", 0);

        XCPT_TRY_START
        {
            if (!yaml_emitter_initialize(&emitter)) {
                croak("%s\n", "Could not initialize the emitter object");
            }
            val = hv_fetch(options, "indent", 6, TRUE);
            if (val && SvOK(*val) && SvIOK( *val )) {
                yaml_emitter_set_indent(&emitter, SvIV(*val));
            }
            val = hv_fetch(options, "width", 5, TRUE);
            if (val && SvOK(*val) && SvIOK( *val )) {
                yaml_emitter_set_width(&emitter, SvIV(*val));
            }
            yaml_emitter_set_output(&emitter, &append_output, (void *) yaml);
            yaml_emitter_set_canonical(&emitter, 0);
            yaml_emitter_set_unicode(&emitter, 0);

            emit_events(&emitter, perl_events);

            yaml_emitter_delete(&emitter);

        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_emitter_delete(&emitter);
            XCPT_RETHROW;
        }

        if (yaml) {
            SvUTF8_off(yaml);
        }
        RETVAL = yaml;

    }
    OUTPUT: RETVAL

SV *
emit_file_events(const char *filename, AV *perl_events, HV *options)
    CODE:
    {
        dXCPT;
        yaml_emitter_t emitter;
        SV **val;
        SV *yaml = newSVpvn("", 0);
        FILE *output;

        XCPT_TRY_START
        {
            if (!yaml_emitter_initialize(&emitter)) {
                croak("%s\n", "Could not initialize the emitter object");
            }
            val = hv_fetch(options, "indent", 6, TRUE);
            if (val && SvOK(*val) && SvIOK( *val )) {
                yaml_emitter_set_indent(&emitter, SvIV(*val));
            }
            val = hv_fetch(options, "width", 5, TRUE);
            if (val && SvOK(*val) && SvIOK( *val )) {
                yaml_emitter_set_width(&emitter, SvIV(*val));
            }
            output = fopen(filename, "wb");
            yaml_emitter_set_output_file(&emitter, output);
            yaml_emitter_set_canonical(&emitter, 0);
            yaml_emitter_set_unicode(&emitter, 0);

            emit_events(&emitter, perl_events);

            yaml_emitter_delete(&emitter);
            fclose(output);
            output = NULL;

        } XCPT_TRY_END

        XCPT_CATCH
        {
            if (output)
                fclose(output);
            yaml_emitter_delete(&emitter);
            XCPT_RETHROW;
        }

        if (yaml) {
            SvUTF8_off(yaml);
        }
        RETVAL = yaml;

    }
    OUTPUT: RETVAL

SV *
emit_filehandle_events(FILE *output, AV *perl_events, HV *options)
    CODE:
    {
        dXCPT;
        yaml_emitter_t emitter;
        SV **val;
        SV *yaml = newSVpvn("", 0);

        XCPT_TRY_START
        {
            if (!yaml_emitter_initialize(&emitter)) {
                croak("%s\n", "Could not initialize the emitter object");
            }

            val = hv_fetch(options, "indent", 6, TRUE);
            if (val && SvOK(*val) && SvIOK( *val )) {
                yaml_emitter_set_indent(&emitter, SvIV(*val));
            }
            val = hv_fetch(options, "width", 5, TRUE);
            if (val && SvOK(*val) && SvIOK( *val )) {
                yaml_emitter_set_width(&emitter, SvIV(*val));
            }

            yaml_emitter_set_output_file(&emitter, output);
            yaml_emitter_set_canonical(&emitter, 0);
            yaml_emitter_set_unicode(&emitter, 0);

            emit_events(&emitter, perl_events);

            yaml_emitter_delete(&emitter);

        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_emitter_delete(&emitter);
            XCPT_RETHROW;
        }

        if (yaml) {
            SvUTF8_off(yaml);
        }
        RETVAL = yaml;

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


MODULE = YAML::LibYAML::API::XS      PACKAGE = YAML::LibYAML::API::Parser

PROTOTYPES: DISABLE

# XS code

SV *
new(...)
    PPCODE:
    {
        dXCPT;
        yaml_parser_t *parser;
        SV *point_sv;
        SV *point_svrv;
        SV *pparser;
        char *class_name;

        XCPT_TRY_START
        {
            class_name = SvPV_nolen(ST(0));
            parser = (yaml_parser_t*) malloc(sizeof(yaml_parser_t));
            if (!yaml_parser_initialize(parser)) {
                croak("%s\n", "Could not initialize the parser object");
            }

        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_parser_delete(parser);
            XCPT_RETHROW;
        }
        point_sv = sv_2mortal(newSViv(PTR2IV(parser)));
        point_svrv = sv_2mortal(newRV_inc(point_sv));
        pparser = sv_bless(point_svrv, gv_stashpv(class_name, 1));
        XPUSHs(pparser);
        XSRETURN(1);
    }

SV *
set_input_string(SV *pparser, const char *input)
    PPCODE:
    {
        dXCPT;
        yaml_parser_t *parser;
        SV *ret_sv;
        SV *point_sv;

        XCPT_TRY_START
        {
            point_sv = SvROK(pparser)? SvRV(pparser): pparser;
            parser = INT2PTR(yaml_parser_t*, SvIV(point_sv));
            yaml_parser_delete(parser);
            if (!yaml_parser_initialize(parser)) {
                croak("%s\n", "Could not initialize the parser object");
            }
            yaml_parser_set_input_string(parser, input, strlen(input));
            ret_sv = sv_2mortal(newSVnv(1));

        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_parser_delete(parser);
            XCPT_RETHROW;
        }
        XPUSHs(ret_sv);
        XSRETURN(1);
    }

SV *
set_input_file(SV *pparser, const char *filename)
    PPCODE:
    {
        dXCPT;
        yaml_parser_t *parser;
        SV *ret_sv;
        SV *point_sv;
        FILE *fh;

        XCPT_TRY_START
        {
            point_sv = SvROK(pparser)? SvRV(pparser): pparser;
            parser = INT2PTR(yaml_parser_t*, SvIV(point_sv));
            yaml_parser_delete(parser);
            if (!yaml_parser_initialize(parser)) {
                croak("%s\n", "Could not initialize the parser object");
            }
            fh = fopen(filename, "rb");
            yaml_parser_set_input_file(parser, fh);
            ret_sv = sv_2mortal(newSVnv(1));

        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_parser_delete(parser);
            XCPT_RETHROW;
        }
        XPUSHs(ret_sv);
        XSRETURN(1);
    }

SV *
set_input_filehandle(SV *pparser, FILE *fh)
    PPCODE:
    {
        dXCPT;
        yaml_parser_t *parser;
        SV *ret_sv;
        SV *point_sv;

        XCPT_TRY_START
        {
            point_sv = SvROK(pparser)? SvRV(pparser): pparser;
            parser = INT2PTR(yaml_parser_t*, SvIV(point_sv));
            yaml_parser_delete(parser);
            if (!yaml_parser_initialize(parser)) {
                croak("%s\n", "Could not initialize the parser object");
            }
            yaml_parser_set_input_file(parser, fh);
            ret_sv = sv_2mortal(newSVnv(1));

        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_parser_delete(parser);
            XCPT_RETHROW;
        }
        XPUSHs(ret_sv);
        XSRETURN(1);
    }

void
DESTROY(SV *pparser)
    PPCODE:
    {
        dXCPT;
        yaml_parser_t *parser;
        SV *point_sv;

        point_sv = SvROK(pparser)? SvRV(pparser): pparser;
        parser = INT2PTR(yaml_parser_t*, SvIV(point_sv));
        yaml_parser_delete(parser);
        free(parser);

        XSRETURN(0);
    }

SV *
parse(SV *pparser)
    PPCODE:
        yaml_parser_t *parser;
        yaml_event_t event;
        HV *perl_event;
        SV *point_sv;
        SV *eref;
        dXCPT;

        XCPT_TRY_START
        {
            point_sv = SvROK(pparser)? SvRV(pparser): pparser;
            parser = INT2PTR(yaml_parser_t*, SvIV(point_sv));
            if (parser->state != YAML_PARSE_END_STATE) {
                if (!yaml_parser_parse(parser, &event)) {
                    croak("%s", parser_error_msg(parser, NULL));
                }
                perl_event = libyaml_to_perl_event(&event);
                yaml_event_delete(&event);
                XPUSHs(sv_2mortal((SV*)newRV_noinc((SV*)perl_event)));
            }
            else {
                XPUSHs(&PL_sv_undef);
            }
        } XCPT_TRY_END

        XCPT_CATCH
        {
            yaml_event_delete(&event);
            yaml_parser_delete(parser);
            XCPT_RETHROW;
        }
        XSRETURN(1);

