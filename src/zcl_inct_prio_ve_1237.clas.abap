class zcl_inct_prio_ve_1237 definition
  public
  final
  create public.

  public section.
    interfaces if_sadl_exit_calc_element_read.
endclass.

class zcl_inct_prio_ve_1237 implementation.


  method if_sadl_exit_calc_element_read~get_calculation_info.

    data(lv_entity) = to_upper( iv_entity ).

    case lv_entity.
      when 'ZR_DT_INCT_1237'
        or 'ZC_DT_INCT_1237'.

        if line_exists( it_requested_calc_elements[ table_line = 'PRIORITYCRITICALITY' ] ).

          append conv string( 'PRIORITY' ) to et_requested_orig_elements.

        endif.

    endcase.
  endmethod.


  method if_sadl_exit_calc_element_read~calculate.

    data lt_data type standard table of zc_dt_inct_1237 with default key.
    lt_data = corresponding #( it_original_data ).

    field-symbols:
      <ls_row>  type any,
      <lv_prio> type any,
      <lv_crit> type any.

LOOP AT lt_data ASSIGNING <ls_row>.
  ASSIGN COMPONENT 'PRIORITY'            OF STRUCTURE <ls_row> TO <lv_prio>.
  ASSIGN COMPONENT 'PRIORITYCRITICALITY' OF STRUCTURE <ls_row> TO <lv_crit>.

  IF <lv_prio> IS ASSIGNED AND <lv_crit> IS ASSIGNED.
    DATA(lv_p) = to_upper( CONV string( <lv_prio> ) ).

    CASE lv_p.
      WHEN 'H'.  <lv_crit> = 1.  " Rojo (Negative)
      WHEN 'M'.  <lv_crit> = 2.  " Amarillo (Critical)
      WHEN 'L'.  <lv_crit> = 3.  " Verde (Positive)
      WHEN OTHERS.
                 <lv_crit> = 0.
    ENDCASE.
  ENDIF.
ENDLOOP.

ct_calculated_data = CORRESPONDING #( lt_data ).


    ct_calculated_data = corresponding #( lt_data ).
  endmethod.

endclass.
