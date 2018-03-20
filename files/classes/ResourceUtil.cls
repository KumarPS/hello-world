public class ResourceUtil {
    public static ResourceController.Resource getResourceEntries(Date aStartofWeek,String aSearchStr, String aLevelStr){
        Date lDt = aStartofWeek;
        Date lWeekStart = lDt.toStartofWeek() + 1;
        Date lWeekEnd = lDt.toStartofWeek() + 6;
        set<Id> resourceIds = new set<Id>();
        Date[] lDaysforWeek = new list<date>();
        Resource__c[] resourcesList = new List<Resource__c>();
        Integer[] hoursList = new list<integer>();

        // ADDED BY Kumar Sarkar, 23-01-18 [START]
        List<ResourceController.utilHoursColorCodes> lUtilHourColorCodeList = new List<ResourceController.utilHoursColorCodes>();
        Map<String, Map<Integer, String>> lUtilHourColorCodeMap = new Map<String, Map<Integer, String>>();
        List<Utilization_Slab__c> resourceUtilizationDetails = [SELECT Name, Lower_Slab__c, Upper_Slab__c FROM Utilization_Slab__c];
        for(Utilization_Slab__c resourceUtilizationDetailsVar : resourceUtilizationDetails)
        {
            Map<Integer, String> lHoursColorCodesPerResource = new Map<Integer, String>();
            lHoursColorCodesPerResource.put(Integer.valueOf(resourceUtilizationDetailsVar.Lower_Slab__c), 'tier-one');
            lHoursColorCodesPerResource.put(Integer.valueOf(resourceUtilizationDetailsVar.Upper_Slab__c), 'tier-two');
            lUtilHourColorCodeMap.put(resourceUtilizationDetailsVar.Name, lHoursColorCodesPerResource);
        }
        // ADDED BY Kumar Sarkar, 23-01-18 [END]

        map<Date,Integer> hoursMap = new map<Date,Integer>();
        ResourceController.Resource lResource = new ResourceController.Resource();
        //ResourceController.ResourceEntryRow lresourceSheet = new ResourceController.ResourceEntryRow();
        Map<String, ResourceController.ResourceEntryRow> lResourceRowMap = new Map<String, ResourceController.ResourceEntryRow>();
        String query = 'select id, Name, Huron_Title__c, Role__c from Resource__c';
        // to store the current week dates
        for(Integer i=0; i < 7; i++){
            Date startDate = lWeekStart.addDays(i);
            lDaysforWeek.add(startDate);
        } 
        // To get 3 weeks based on the current date
        String[] weeksList = new List<String>();
        Date[] startDatesList = new List<Date>();
        Integer j=0;
        Date startDate = lWeekStart;
        for(Integer i=0; i < 3; i++){
            startDate = startDate.addDays(j);
            Date endDate = (startDate + 6);
            String startDatetoDisplay = startDate.format();
            String endDatetoDisplay = endDate.format();
            startDatesList.add(startDate);
            weeksList.add(startDatetoDisplay + '\n' + '-' + endDatetoDisplay);    
            j=7;
        }
		// query to get the resource records based on filters
        if(String.isBlank(aSearchStr) && String.isBlank(aLevelStr))
            query += '';
        else if(String.isBlank(aSearchStr) && !(String.isBlank(aLevelStr))){
            query += ' WHERE Huron_Title__c =: aLevelStr';
        }else if(!(String.isBlank(aSearchStr)) && String.isBlank(aLevelStr)){
            query += ' WHERE Name LIKE \'%' + aSearchStr + '%\'';
        }else if(!(String.isBlank(aSearchStr)) && !(String.isBlank(aLevelStr))){
            query += ' WHERE Name LIKE \'%' + aSearchStr  + '%\' AND Huron_Title__c =: aLevelStr';
        }
        resourcesList = Database.query(query);
        //to store the resource Ids
        for(Resource__c res:resourcesList){
            resourceIds.add(res.Id);
        }
        
        //hoursMap = getResourceAllocationList(resourcesList);
        for(Resource__c res:resourcesList){
            hoursList = new List<Integer>();
            lUtilHourColorCodeList = new List<ResourceController.utilHoursColorCodes>();    //ADDED BY Kumar Sarkar
            //lresourceSheet.mResourceName = res.Name;
            String lKey = res.Name;
            String lTitle = res.Huron_Title__c; //ADDED BY Kumar Sarkar, 22-01-18
            ResourceController.ResourceEntryRow lResourceEntryRow = lResourceRowMap.get(lKey);

            if(null == lResourceEntryRow) {
                lResourceEntryRow = new ResourceController.ResourceEntryRow(lKey, lTitle);
                lResourceRowMap.put(lResourceEntryRow.mResourceName, lResourceEntryRow);
            }
            hoursMap = getResourceAllocationList(res.Id, startDatesList);

            for(Date d : startDatesList){
                String colorCode = 'tier-one';
                Integer counter = 0;
                if(hoursMap.get(d) != null){
                    for(Integer iterator : lUtilHourColorCodeMap.get(lTitle).keySet()) {
                        counter++;
                        if(hoursMap.get(d) <= iterator) {
                            colorCode = lUtilHourColorCodeMap.get(lTitle).get(iterator);
                            break;
                        }
                        if(counter == lUtilHourColorCodeMap.get(lTitle).keySet().size()) {
                            colorCode = 'tier-three';
                        }
                    }
                    lUtilHourColorCodeList.add(new ResourceController.utilHoursColorCodes(hoursMap.get(d), colorCode));
                    hoursList.add(hoursMap.get(d));
                    lResourceEntryRow.mhoursList = hoursList;
                    lResourceEntryRow.mUtilData = lUtilHourColorCodeList;
                }
                else{
                    Boolean isAllocationForElsePartDone = false;
                    for(Date hoursMapDateVar : hoursMap.keyset()) {
                        if(d.daysBetween(hoursMapDateVar) > 0 && d.daysBetween(hoursMapDateVar) <= 5) {
                            for(Integer iterator : lUtilHourColorCodeMap.get(lTitle).keySet()) {
                                counter++;
                                if(hoursMap.get(hoursMapDateVar) <= iterator) {
                                    colorCode = lUtilHourColorCodeMap.get(lTitle).get(iterator);
                                    break;
                                }
                                if(counter == lUtilHourColorCodeMap.get(lTitle).keySet().size()) {
                                    colorCode = 'tier-three';
                                }
                            }
                            lUtilHourColorCodeList.add(new ResourceController.utilHoursColorCodes(hoursMap.get(hoursMapDateVar), colorCode));
                            hoursList.add(hoursMap.get(hoursMapDateVar));
                            lResourceEntryRow.mhoursList = hoursList;
                            lResourceEntryRow.mUtilData = lUtilHourColorCodeList;
                            isAllocationForElsePartDone = true;
                        }
                    }
                    if(!isAllocationForElsePartDone)
                    {
                        lUtilHourColorCodeList.add(new ResourceController.utilHoursColorCodes(0, colorCode));
                        hoursList.add(0);
                        lResourceEntryRow.mhoursList = hoursList;
                        lResourceEntryRow.mUtilData = lUtilHourColorCodeList;
                    }
                }
            }
        }
        lResource.mResources = resourcesList;
        lResource.mDatesforWeek = weeksList;
        lResource.mStartDayofWeek = lWeekStart;
        lResource.mResourcesSheet = lResourceRowMap.values();

        return lResource;
    }

    public static Integer getWorkingDaysWithinDates(Date sDate, Date eDate) {
        Integer workingMonthDays = 0;
        for(integer z=0; z <= sDate.daysBetween(eDate); z++)
        {
            Date mdt = sDate + z;
            DateTime currMonDate = DateTime.newInstance(mdt.year(), mdt.month(), mdt.day());
            String tDay = currMonDate.format('EEEE');
            if(tDay != 'Saturday' && tDay !='Sunday')
            {
                workingMonthDays = workingMonthDays + 1;
            }
        }
        return workingMonthDays;
    }
    
    public static map<Date,Integer> getResourceAllocationList(Id aResourceId, Date[] startDatesList){
        map<Date,Integer> hoursMap = new map<Date,Integer>();
        // EDITED BY Kumar Sarkar, 21-01-18
        Map<Id, Resource_Allocation__c> mapResourceAllocation =new Map<Id, Resource_Allocation__c>(
                                                                [SELECT Id,
                                                                    Name,
                                                                    Hours__c,
                                                                    Start_Date__c,
                                                                    End_Date__c,
                                                                    Total_Planned_Hours__c,
                                                                    Proposed_Resource__c,
                                                                    Proposed_Resource__r.Name,
                                                                    Resource_Request__c,
                                                                    Resource_Request__r.Week_Month__c FROM Resource_Allocation__c
                                                                WHERE Proposed_Resource__c =: aResourceId
                                                                    AND Resource_Request__r.Status__c = 'Accepted'
                                                                ]);
        
        for(Resource_Allocation__c ra : mapResourceAllocation.values()) {
            if(ra.Resource_Request__r.Week_Month__c == 'Week') {
                if(!(hoursMap.containsKey(ra.Start_Date__c))) {
                    hoursMap.put(ra.Start_Date__c, (Integer)ra.Hours__c);
                }
                else {
                    integer hr = hoursMap.get(ra.Start_Date__c);
                    integer nhr = hr+ (Integer)ra.Hours__c;
                    hoursMap.put(ra.Start_Date__c, nhr);
                }
            }
            else if(ra.Resource_Request__r.Week_Month__c == 'Month') {
                Date sDate = ra.Start_Date__c;
                Date eDate = ra.End_Date__c;
                Datetime dt= datetime.newInstance(sDate.year(), sDate.month(),sDate.day());
                Datetime stDate = dt;
                Integer numberOfDays = Date.daysInMonth(sDate.year(), sDate.month());
                Date lastDayOfMonth = Date.newInstance(sDate.year(), sDate.month(), numberOfDays) < eDate ? Date.newInstance(sDate.year(), sDate.month(), numberOfDays) : eDate;
                Datetime lDayofMonth = Datetime.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), lastDayOfMonth.day());
                Integer workingMonthDays = getWorkingDaysWithinDates(sDate, lastDayOfMonth);

                Integer i = 1;
                Decimal hoursPerDay = ra.Hours__c/workingMonthDays;
                Integer hours = 0;
                
                for(Date startDatesListVar : startDatesList) {
                    while(sDate <= eDate) {
                        hours = (Integer)(sDate.toStartOfWeek().addDays(5) < eDate ? hoursPerDay*sDate.daysBetween(sDate.toStartOfWeek().addDays(6)) : hoursPerDay*(sDate.daysBetween(eDate)+1));
                        hoursMap.put(sDate, hours);
                        sDate = sDate.toStartOfWeek().addDays(8);
                        i++;
                    }
                }
            }
        }

        return hoursMap;
    }
}