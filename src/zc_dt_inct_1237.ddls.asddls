@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumo incidentes'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true 

define root view entity ZC_DT_INCT_1237 
provider contract transactional_query
as projection on ZR_DT_INCT_1237
{
   key IncUUID,
      @Search.defaultSearchElement: true  // Default search element
      @Search.fuzzinessThreshold: 0.8     // Fuzziness threshold for search *Umbral de búsqueda*
      @Search.ranking: #MEDIUM            // Ranking for search *Importancia Clasificación de búsqueda
      IncidentID,
      @Search.defaultSearchElement: true  // Default search element
      @Search.fuzzinessThreshold: 0.8     // Fuzziness threshold for search *Umbral de búsqueda*
      @Search.ranking: #MEDIUM            // Ranking for search *Importancia Clasificación de búsqueda
      Title,
      @Search.defaultSearchElement: true  // Default search element
      @Search.fuzzinessThreshold: 0.8     // Fuzziness threshold for search *Umbral de búsqueda*
      @Search.ranking: #MEDIUM            // Ranking for search *Importancia Clasificación de búsqueda
      Description,
    Status,
    Priority,
                // Virtual element para criticality (0..3)
      @EndUserText.label: 'PriorityCriticality' // Label for the virtual field     
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_INCT_PRIO_VE_FJCM'
 virtual     PriorityCriticality : abap.int1,
@Search.defaultSearchElement: true  // Default search element
      @Search.fuzzinessThreshold: 0.8     // Fuzziness threshold for search *Umbral de búsqueda*
      @Search.ranking: #MEDIUM            // Ranking for search *Importancia Clasificación de búsqueda
      CreationDate,
      @Search.defaultSearchElement: true  // Default search element
      @Search.fuzzinessThreshold: 0.8     // Fuzziness threshold for search *Umbral de búsqueda*
      @Search.ranking: #MEDIUM            // Ranking for search *Importancia Clasificación de búsqueda
      ChangedDate,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _History : redirected to composition child ZC_DT_INCT_H_1237
}
