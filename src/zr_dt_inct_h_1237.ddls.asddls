@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Historial incidentes'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_DT_INCT_H_1237 
as select from zdt_inct_h_1237
association to parent ZR_DT_INCT_1237 as _Incident 
on $projection.IncUuid = _Incident.IncUUID

{
    key his_uuid as HisUuid,
    key inc_uuid as IncUuid,
    his_id as Hisid,
    previous_status as PreviousStatus,
    new_status as NewStatus,
    text as Text,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt,
    _Incident // Make association public
}
