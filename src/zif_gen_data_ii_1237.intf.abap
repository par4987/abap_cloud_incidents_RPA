interface zif_gen_data_ii_1237
  public.

  " Table Types for CATALOG
  types: tt_priority type standard table of zdt_priority1237,
         tt_status   type standard table of zdt_status_1237,
         tt_incident type standard table of zdt_inct_1237.

  " Constants for default values of priorities and statuses (:
  constants c_default_priority type string value 'M'.
  constants c_default_status   type string value 'OP'.

  " Methods to implement in the class
  methods:
    clean_tables importing out type ref to if_oo_adt_classrun_out,

    generate_priorities importing out           type ref to if_oo_adt_classrun_out
                                  it_priorities type tt_priority,

    generate_statuses importing out         type ref to if_oo_adt_classrun_out
                                it_statuses type tt_status,

    generate_incidents importing out          type ref to if_oo_adt_classrun_out
                                 it_incidents type tt_incident.

endinterface.
