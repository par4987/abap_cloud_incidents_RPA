@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumo historial incidentes'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true


define view entity ZC_DT_INCT_H_1237
  as projection on ZR_DT_INCT_H_1237
{
  key HisUuid,
  key IncUuid,
      Hisid,
      PreviousStatus,
      NewStatus,
      Text,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Incident : redirected to parent ZC_DT_INCT_1237
}
