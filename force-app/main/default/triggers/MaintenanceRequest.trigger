trigger MaintenanceRequest on Case ( before update, after update ) {
    // call MaintenanceRequestHelper.updateWorkOrders  
    // MaintenanceRequestHelper.updateWorkOrders();


    //version 1, pass in closed case ID List
    Set<Id> closedCaseIds = new Set<Id>();
    
    if ( Trigger.isAfter ) {
        if ( Trigger.isUpdate ) {
            for ( Case singleCase : Trigger.New ) {
                if ( singleCase.Status == 'Closed' 
                && Trigger.oldMap.get( singleCase.Id ).Status != 'Closed'
                && ( singleCase.Type == 'Repair' || singleCase.Type == 'Routine Maintenance' )) {

                    closedCaseIds.add( singleCase.Id );
                    system.debug( 'singleCase id is ' + singleCase.Id );
                    
                }
            }
        }
    }

    if ( closedCaseIds != NULL && closedCaseIds.size() > 0 ) {

        MaintenanceRequestHelper.updateWorkOrders(closedCaseIds);

    }

}