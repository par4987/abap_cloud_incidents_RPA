@EndUserText.label: 'Parámetros para cambio de Status'
define abstract entity ZC_AE_Change_Status_1237
{
@EndUserText.label: 'Change Status'
@Consumption.valueHelpDefinition: [{
    entity.name: 'ZC_AE_Status_1237_VH',
    entity.element: 'StatusCode',
    useForValidation: true
    }]
    status : zde_status_1237;
    @EndUserText.label: 'Description'
    Text : abap.char(60);
    
}
