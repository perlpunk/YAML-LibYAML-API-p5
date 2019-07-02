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
#include "etc/perl_libyaml.h"
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


SV *
parser_create(SV* obj)
    CODE:
    {
        HV *hash;
        SV* obj_sv;
        SV **sv;
        long id;

        SvGETMAGIC(obj);
        if (!SvROK(obj))
            croak("Not a reference");

        obj_sv = SvRV(obj);
        if (SvTYPE(obj_sv) != SVt_PVHV)
            croak("Not a reference to a hash");
#if PERL_REVISION > 5 || (PERL_REVISION == 5 && PERL_VERSION <= 8)
        hash = (HV *)(obj_sv);
#else
        hash = MUTABLE_HV(obj_sv);
#endif

        sv = hv_fetch(hash, "uid", 3, 0);
        if (!sv) {
//            fprintf(stderr, "No parser, creating new\n");
            id = parser_create();
        }
        else {
            id = (long) SvIV(*sv);
            parser_initialize(id);
        }


        hv_store(
            hash, "uid", 3,
            newSViv( id ), 0
        );
        RETVAL = newSViv(id);
    }
    OUTPUT: RETVAL

SV *
parser_delete(SV* obj)
    CODE:
    {
        HV *hash;
        SV* obj_sv;
        SV **sv;
        long id;
        int deleted = 0;

        SvGETMAGIC(obj);
        if (!SvROK(obj))
            croak("Not a reference");

        obj_sv = SvRV(obj);
        if (SvTYPE(obj_sv) != SVt_PVHV)
            croak("Not a reference to a hash");
#if PERL_REVISION > 5 || (PERL_REVISION == 5 && PERL_VERSION <= 8)
        hash = (HV *)(obj_sv);
#else
        hash = MUTABLE_HV(obj_sv);
#endif

        if (hv_exists(hash, "uid", 3)) {
            sv = hv_fetch(hash, "uid", 3, TRUE);
            if (!sv) {
                croak("%s\n", "Could not get uid");
            }
            if (SvOK(*sv)) {
                id = (long) SvIV(*sv);
                if (id > 0)
                    deleted = parser_delete(id);
            }
            hv_delete(hash, "uid", 3, TRUE);
        }

        RETVAL = newSViv(deleted);
    }
    OUTPUT: RETVAL

SV *
parse_callback(SV* obj)
    CODE:
    {
        HV *hash;
        SV* obj_sv;
        SV **sv;
        long id;
        int ok;
        SV* code;

        SvGETMAGIC(obj);
        if (!SvROK(obj))
            croak("Not a reference");

        obj_sv = SvRV(obj);
        if (SvTYPE(obj_sv) != SVt_PVHV)
            croak("Not a reference to a hash");
#if PERL_REVISION > 5 || (PERL_REVISION == 5 && PERL_VERSION <= 8)
        hash = (HV *)(obj_sv);
#else
        hash = MUTABLE_HV(obj_sv);
#endif

        sv = hv_fetch(hash, "uid", 3, TRUE);
        if (!sv) {
            croak("%s\n", "Could not get uid");
        }
        id = (long) SvIV(*sv);

        sv = hv_fetch(hash, "parse_callback", 14, TRUE);
        code = SvRV(*sv);

        ok = parse_callback(id, code);

        RETVAL = newSViv(ok);
    }
    OUTPUT: RETVAL

SV *
parser_init_string(SV* obj, const char* input)
    CODE:
    {
        HV *hash;
        SV* obj_sv;
        SV **sv;
        long id;
        int ok;

        SvGETMAGIC(obj);
        if (!SvROK(obj))
            croak("Not a reference");

        obj_sv = SvRV(obj);
        if (SvTYPE(obj_sv) != SVt_PVHV)
            croak("Not a reference to a hash");
#if PERL_REVISION > 5 || (PERL_REVISION == 5 && PERL_VERSION <= 8)
        hash = (HV *)(obj_sv);
#else
        hash = MUTABLE_HV(obj_sv);
#endif

        sv = hv_fetch(hash, "uid", 3, TRUE);
        if (!sv) {
            croak("%s\n", "Could not get uid");
        }
        id = (long) SvIV(*sv);
        ok = parser_init_string(id, input);
        RETVAL = newSViv(ok);
    }
    OUTPUT: RETVAL


