@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incidentes'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_DT_INCT_1237 
as select from zdt_inct_1237
composition [0..*] of ZR_DT_INCT_H_1237 as _History // Asociation Composition to history CDS Entity
{
  key inc_uuid              as IncUUID,
      incident_id           as IncidentID,
      title                 as Title,
      description           as Description,
      status                as Status,
      priority              as Priority,
      creation_date         as CreationDate,
      changed_date          as ChangedDate,

      //AUDIT FIELDS
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      //LOCAL Etag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      //TOTAL Etag
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
     
      _History // Make association public
    

}
