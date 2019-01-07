public class MaintenanceRequestHelper {
    private static List<Work_Part__c> allWorkParts = new List<Work_Part__c>();

    //version 1, pass in closed case ID List
    public static void updateWorkOrders(Set<Id> closedCaseIds) {
        // update workorders
        // get closed cases, and related work parts
        // a method to get the latest/shortest work part date to set the due date
        // only trigger for cases with related work part(s), so filter out on work order case
        // SELECT Id, (SELECT Id FROM Work_Parts__r) FROM CASE
        
        /*---
            Anonymous execute

            List<Case> test = [SELECT Id, (SELECT Id FROM Work_Parts__r) FROM CASE WHERE Id = '5000l000003MmVoAAK'];
            if(test[0].Work_Parts__r == null) {
                system.debug('is null');
            } else if (test[0].Work_Parts__r.size() == 0) {
                system.debug('is 0');
            } else {
                system.debug('size is ' + test[0].Work_Parts__r.size());
            }

            Result is 0, if no nested work part

        ---*/

        //list of new cases and related work parts
        List<Case> newCaseList = new List<Case>();

        //potential case list with work parts
        List<Case> closedCases = [SELECT Id, Status, Type, Origin, Reason, Vehicle__c, Equipment__c, Subject, Previous_Maintenance_Request__c,
                                    (SELECT Id FROM Work_Parts__r)
                                    FROM Case 
                                    WHERE Id IN: closedCaseIds];

        Map<Id, List<Work_Part__c>> mainWorkPartMap = getRequestWorkPartMap(closedCaseIds);

        for ( Case singleCase : closedCases ) {

            List<Work_Part__c> workParts = mainWorkPartMap.get(singleCase.Id);

            if ( workParts.size() > 0 ) {
                Case newCase = new Case(
                    Status              = 'New',
                    Type                = 'Routine Maintenance',
                    Origin              = singleCase.Origin,
                    Reason              = singleCase.Reason,
                    Vehicle__c          = singleCase.Vehicle__c,
                    Equipment__c        = singleCase.Equipment__c,  
                    Previous_Maintenance_Request__c = singleCase.Id,
                    Date_Reported__c    = System.today(),
                    Date_Due__c         = System.today() + getShortestCycle(singleCase.Id),             
                    //newCase.Subject = 'New Rountine Maintenance';
                    Subject = String.isBlank(singleCase.Subject) ? 'Routine Maintenance Request' :
                        singleCase.Subject
                );
                
                    newCaseList.add( newCase );
                }          
        }

        if ( newCaseList != NULL && newCaseList.size() > 0 ) {
            insert newCaseList;
            updateRelatedWorkParts(newCaseList);
        }
    }    

    //method to update related work part
    private static void updateRelatedWorkParts(List<Case> newCases){
    	Map<Id, Id> oldToNewCaseMap = new Map<Id, Id>();
    	for(Case singleCase : newCases){
    		oldToNewCaseMap.put(Id.valueOf(singleCase.Previous_Maintenance_Request__c),singleCase.Id);
    	}

    	if(allWorkParts != null){
    		for(Work_Part__c singleWorkPart : allWorkParts){ 
    			singleWorkPart.Maintenance_Request__c = oldToNewCaseMap.get(singleWorkPart.Maintenance_Request__c);
    		}
    	}

    	if(allWorkParts != null && allWorkParts.size() > 0){
    		update allWorkParts;
    	}
    }


    //get request and work part map
    private static Map<Id, List<Work_Part__c>> getRequestWorkPartMap (Set<Id> caseIds) {
        allWorkParts = [SELECT ID, Equipment__c, Maintenance_Request__c, Quantity__c FROM Work_Part__c 
    			WHERE Maintenance_Request__c in: caseIds];
    	Map<Id, List<Work_Part__c>> mainWorkPartMap = new Map<Id, List<Work_Part__c>>();
    	for(Work_Part__c singleWorkPart : allWorkParts){
    		List<Work_Part__c> tempList;
    		if(mainWorkPartMap.get(singleWorkPart.Maintenance_Request__c) == null){
    			tempList = new List<Work_Part__c>();
    		}else{
    			tempList = mainWorkPartMap.get(singleWorkPart.Maintenance_Request__c);
    		}
    		tempList.add(singleWorkPart);
    		mainWorkPartMap.put(singleWorkPart.Maintenance_Request__c, tempList);
    	}

    	return mainWorkPartMap;
    }

    //method to return the shortest cycle date in a case
    private static Integer getShortestCycle(Id caseId) {
        Integer shortestCycle;

        Work_Part__c part = [SELECT Id, Maintenance_Cycle__c FROM Work_Part__c 
                            WHERE Maintenance_Request__c = :caseId 
                            ORDER BY Maintenance_Cycle__c ASC NULLS LAST 
                            LIMIT 1 ];

        if ( part != NULL && part.Maintenance_Cycle__c != NULL ) {
            shortestCycle = Integer.valueOf(part.Maintenance_Cycle__c);
        }

        return shortestCycle;
    } 
}