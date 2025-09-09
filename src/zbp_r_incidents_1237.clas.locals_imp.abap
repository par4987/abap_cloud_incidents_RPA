CLASS lhc_Incidents DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

    " Status constants
    CONSTANTS: BEGIN OF mc_status,
                 open        TYPE zde_status_1237 VALUE 'OP',  " Newly created
                 in_progress TYPE zde_status_1237 VALUE 'IP',  " Work ongoing
                 pending     TYPE zde_status_1237 VALUE 'PE',  " Waiting on something
                 completed   TYPE zde_status_1237 VALUE 'CO',  " Finished (not necessarily closed)
                 closed      TYPE zde_status_1237 VALUE 'CL',  " Fully closed
                 canceled    TYPE zde_status_1237 VALUE 'CN',  " Aborted
               END OF mc_status.


  PRIVATE SECTION.


    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Incidents RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Incidents RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Incidents RESULT result.

    METHODS changeStatus FOR MODIFY
      IMPORTING keys FOR ACTION Incidents~changeStatus RESULT result.

    METHODS setHistory FOR MODIFY
      IMPORTING keys FOR ACTION Incidents~setHistory.

    METHODS setDefaultValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Incidents~setDefaultValues.

    METHODS setDefaultHistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incidents~setDefaultHistory.

    " Purpose: Return current max HisID for an Incident (so we can increment).
    METHODS get_history_index EXPORTING ev_incuuid      TYPE sysuuid_x16
                              RETURNING VALUE(rv_index) TYPE zdt_inct_h_1237-his_id.


ENDCLASS.

CLASS lhc_Incidents IMPLEMENTATION.

  method setDefaultValues.
    " Read current temp records to validate & enrich
    read entities of zr_dt_inct_1237 in local mode
     entity Incidents
     fields ( CreationDate
              Status ) with corresponding #( keys )
     result data(incidents).

    " Prevent future CreationDate (if user filled something manually)
    data(lv_current_date) = cl_abap_context_info=>get_system_date( ).

    loop at incidents into data(ls_incident) where CreationDate is not initial.
      if ls_incident-CreationDate > lv_current_date.
        append value #(
          %tky = ls_incident-%tky
          %msg = new zcl_incidents_messages_1237(
            textid = zcl_incidents_messages_1237=>future_date_not_allowed
            incident_id = |{ ls_incident-IncidentID }|
            severity = if_abap_behv_message=>severity-error
          )
          %element-CreationDate = if_abap_behv=>mk-on
          %state_area = 'VALIDATE_DATE'
        ) to reported-incidents.
      endif.
    endloop.

    " Drop ones that already had a CreationDate (we only fill blanks)
    delete incidents where CreationDate is not initial.

    " Nothing to do? bail
    check incidents is not initial.

    " Get next IncidentID (simple max + 1)
    select from zdt_inct_1237
      fields max( incident_id ) as max_inct_id
      where incident_id is not null
      into @data(lv_max_inct_id).

    if lv_max_inct_id is initial.
      lv_max_inct_id = 1.
    else.
      lv_max_inct_id += 1.
    endif.

    " Push generated defaults
    modify entities of zr_dt_inct_1237 in local mode
      entity Incidents
      update
      fields ( IncidentID
               CreationDate
               Status )
      with value #(  for incident in incidents ( %tky = incident-%tky
                                                 IncidentID = lv_max_inct_id
                                                 CreationDate = cl_abap_context_info=>get_system_date( )
                                                 Status       = mc_status-open )  ).
  endmethod.

  method get_instance_features.
    " Decide which actions / associations are active
    data lv_history_index type i.
    read entities of zr_dt_inct_1237 in local mode
       entity Incidents
         fields ( Status )
         with corresponding #( keys )
       result data(incidents)
       failed failed.

    " If exactly one row, check if history exists; else default enable
    data(lv_create_action) = lines( incidents ).
    if lv_create_action eq 1.
      lv_history_index = get_history_index( importing ev_incuuid = incidents[ 1 ]-IncUUID ).
    else.
      lv_history_index = 1.
    endif.

    " Build feature flags (disable when terminal or no history index)
    result = value #( for incident in incidents
                          ( %tky                   = incident-%tky
                            %action-ChangeStatus   = cond #( when incident-Status = mc_status-completed or
                                                                  incident-Status = mc_status-closed    or
                                                                  incident-Status = mc_status-canceled  or
                                                                  lv_history_index = 0
                                                             then if_abap_behv=>fc-o-disabled
                                                             else if_abap_behv=>fc-o-enabled )
                            %assoc-_History       = cond #( when incident-Status = mc_status-completed or
                                                                 incident-Status = mc_status-closed    or
                                                                 incident-Status = mc_status-canceled  or
                                                                 lv_history_index = 0
                                                            then if_abap_behv=>fc-o-disabled
                                                            else if_abap_behv=>fc-o-enabled )
                          ) ).
  endmethod.

  method changeStatus.
    " Change status + log history (with validation)
    data: lt_updated_root_entity type table for update zr_dt_inct_1237,
          lt_association_entity  type table for create zr_dt_inct_1237\_History,
          lv_status              type zde_status_1237,
          lv_text                type zdt_inct_h_1237-text,
          lv_exception           type string,
          lv_error               type c,
          ls_incident_history    type zdt_inct_h_1237,
          lv_max_his_id          type zdt_inct_h_1237-his_id,
          lv_wrong_status        type zde_status_1237.

    " Pull current full records for given keys
    read entities of zr_dt_inct_1237 in local mode
         entity Incidents
         all fields with corresponding #( keys )
         result data(incidents)
         failed failed.

    loop at incidents assigning field-symbol(<incident>).
      " Requested target status
      lv_status = keys[ key id %tky = <incident>-%tky ]-%param-status.

      " Block invalid transition: pending -> (closed | completed)
      if <incident>-Status eq mc_status-pending and lv_status eq mc_status-closed or
         <incident>-Status eq mc_status-pending and lv_status eq mc_status-completed.
        append value #( %tky = <incident>-%tky ) to failed-incidents.
        lv_wrong_status = lv_status.
        append value #( %tky = <incident>-%tky
                        %msg = new zcl_incidents_messages_1237(
                          textid = zcl_incidents_messages_1237=>status_invalid
                          status = |{ lv_wrong_status }|
                          severity = if_abap_behv_message=>severity-error
                        )
                        %state_area = 'VALIDATE_COMPONENT'
                      ) to reported-incidents.
        lv_error = abap_true.
        exit.
      endif.

      " Stage update for root
      append value #( %tky = <incident>-%tky
                      ChangedDate = cl_abap_context_info=>get_system_date( )
                      Status = lv_status ) to lt_updated_root_entity.

      " History text (param)
      lv_text = keys[ key id %tky = <incident>-%tky ]-%param-text.

      " Next history id
      lv_max_his_id = get_history_index(
                  importing
                    ev_incuuid = <incident>-IncUUID ).
      if lv_max_his_id is initial.
        ls_incident_history-his_id = 1.
      else.
        ls_incident_history-his_id = lv_max_his_id + 1.
      endif.

      ls_incident_history-new_status = lv_status.
      ls_incident_history-text = lv_text.

      " Generate UUID
      try.
          ls_incident_history-inc_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        catch cx_uuid_error into data(lo_error).
          lv_exception = lo_error->get_text(  ).
      endtry.

      " Stage new history entry
      if ls_incident_history-his_id is not initial.
        append value #( %tky = <incident>-%tky
                        %target = value #( (  HisUUID = ls_incident_history-inc_uuid
                                              IncUUID = <incident>-IncUUID
                                              HisID = ls_incident_history-his_id
                                              PreviousStatus = <incident>-Status
                                              NewStatus = ls_incident_history-new_status
                                              Text = ls_incident_history-text ) )
                                               ) to lt_association_entity.
      endif.
    endloop.
    unassign <incident>.

    " Abort if validation failed
    check lv_error is initial.

    " Apply status changes
    modify entities of zr_dt_inct_1237 in local mode
    entity Incidents
    update  fields ( ChangedDate
                     Status )
    with lt_updated_root_entity.

    free incidents.

    " Persist history child entries
    modify entities of zr_dt_inct_1237 in local mode
     entity Incidents
     create by \_History fields ( HisUUID
                                  IncUUID
                                  HisID
                                  PreviousStatus
                                  NewStatus
                                  Text )
        auto fill cid
        with lt_association_entity
     mapped mapped
     failed failed
     reported reported.

    " Return updated root entities (UI sync)
    read entities of zr_dt_inct_1237 in local mode
    entity Incidents
    all fields with corresponding #( keys )
    result incidents
    failed failed.

    result = value #( for incident in incidents ( %tky = incident-%tky
                                                  %param = incident ) ).
  endmethod.

  method setDefaultHistory.
    " Trigger internal action to seed first history line
    modify entities of zr_dt_inct_1237 in local mode
    entity Incidents
    execute setHistory
       from corresponding #( keys ).
  endmethod.

  method get_history_index.
    " Get current max history ID (HisID) for given incident
    select from zdt_inct_h_1237
      fields max( his_id ) as max_his_id
      where inc_uuid eq @ev_incuuid and
            his_uuid is not null
      into @rv_index.
  endmethod.

  method setHistory.
    " Create initial history entry (used on save)
    data: lt_updated_root_entity type table for update zr_dt_inct_1237,
          lt_association_entity  type table for create zr_dt_inct_1237\_History,
          lv_exception           type string,
          ls_incident_history    type zdt_inct_h_1237,
          lv_max_his_id          type zdt_inct_h_1237-his_id.

    " Load incidents
    read entities of zr_dt_inct_1237 in local mode
         entity Incidents
         all fields with corresponding #( keys )
         result data(incidents).

    loop at incidents assigning field-symbol(<incident>).
      lv_max_his_id = get_history_index( importing ev_incuuid = <incident>-IncUUID ).
      if lv_max_his_id is initial.
        ls_incident_history-his_id = 1.
      else.
        ls_incident_history-his_id = lv_max_his_id + 1.
      endif.

      try.
          ls_incident_history-inc_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        catch cx_uuid_error into data(lo_error).
          lv_exception = lo_error->get_text(  ).
      endtry.

      if ls_incident_history-his_id is not initial.
        append value #( %tky = <incident>-%tky
                        %target = value #( (  HisUUID = ls_incident_history-inc_uuid
                                              IncUUID = <incident>-IncUUID
                                              HisID = ls_incident_history-his_id
                                              NewStatus = <incident>-Status
                                              Text = 'First Incident' ) )
                                           ) to lt_association_entity.
      endif.
    endloop.
    unassign <incident>.

    free incidents.

    " Persist first history record(s)
    modify entities of zr_dt_inct_1237 in local mode
     entity Incidents
     create by \_History fields ( HisUUID
                                  IncUUID
                                  HisID
                                  PreviousStatus
                                  NewStatus
                                  Text )
        auto fill cid
        with lt_association_entity.
  endmethod.

  method get_global_authorizations.
    " No global auth logic (placeholder)
  endmethod.

  method get_instance_authorizations.
    " No per-instance auth logic (placeholder)
  endmethod.

ENDCLASS.
