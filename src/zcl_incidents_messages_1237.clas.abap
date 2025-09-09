class zcl_incidents_messages_1237 definition
  public
  inheriting from cx_static_check
  final
  create public.

  public section.
    interfaces if_abap_behv_message.
    interfaces if_t100_message.

    " Constants for each message for the incidents app
    constants:
      begin of status_invalid,
        msgid type symsgid value 'ZMC_INC_1237',
        msgno type symsgno value '001',
        attr1 type scx_attrname value 'STATUS',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of status_invalid,

      begin of incident_not_found,
        msgid type symsgid value 'ZMC_INC_1237',
        msgno type symsgno value '002',
        attr1 type scx_attrname value 'INCIDENT_ID',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of incident_not_found,

      begin of incident_created,
        msgid type symsgid value 'ZMC_INC_1237',
        msgno type symsgno value '003',
        attr1 type scx_attrname value 'INCIDENT_ID',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of incident_created,

      begin of status_change_approval,
        msgid type symsgid value 'ZMC_INC_1237',
        msgno type symsgno value '004',
        attr1 type scx_attrname value 'OLD_STATUS',
        attr2 type scx_attrname value 'NEW_STATUS',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of status_change_approval,

      begin of processing_info,
        msgid type symsgid value 'ZMC_INC_1237',
        msgno type symsgno value '005',
        attr1 type scx_attrname value 'INCIDENT_ID',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of processing_info,

    " Agregar después de tus constantes existentes
    begin of future_date_not_allowed,
    msgid type symsgid value 'ZMC_INC_1237',
    msgno type symsgno value '006',
    attr1 type scx_attrname value 'INCIDENT_ID',
    attr2 type scx_attrname value '',
    attr3 type scx_attrname value '',
    attr4 type scx_attrname value '',
    end of future_date_not_allowed.

    "Attributes for the message
    data: status      type string,
          incident_id type string,
          old_status  type string,
          new_status  type string.

    " Constructor
    methods constructor
      importing
        !textid      type scx_t100key optional
        !previous    type ref to cx_root optional
        !severity    type if_abap_behv_message=>t_severity optional
        !status      type string optional
        !incident_id type string optional
        !old_status  type string optional
        !new_status  type string optional.

  protected section.
  private section.
endclass.

class zcl_incidents_messages_1237 implementation.
  method constructor ##ADT_SUPPRESS_GENERATION.
    call method super->constructor
      exporting
        previous = previous.

    "TextID
    me->if_t100_message~t100key = cond #( when textid is supplied
                                          then textid
                                          else status_invalid ).

    "Severity
    me->if_abap_behv_message~m_severity = cond #( when severity is supplied
                                                  then severity
                                                  else if_abap_behv_message=>severity-error ).

    me->status = status.
    me->incident_id = incident_id.
    me->old_status = old_status.
    me->new_status = new_status.
  endmethod.
endclass.
