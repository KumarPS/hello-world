public class StudentsEventsManagement_Controller
{
    @AuraEnabled
    public static List<String> fetchCategoryFieldData()
    {
        system.debug('fetchAllRequiredFieldData() called.');

        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getValue());
        }

        return options;
    }

    @AuraEnabled
    public static List<String> fetchEventLocationFieldData()
    {
        system.debug('fetchEventLocationFieldData() called.');

        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event__c.Event_Location__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getValue());
        }

        return options;
    }

    @AuraEnabled
    public static List<String> fetchEventStatusFieldData()
    {
        system.debug('fetchEventLocationFieldData() called.');

        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getValue());
        }

        return options;
    }

    @AuraEnabled
    public static List<String> fetchEventTypeFieldData()
    {
        system.debug('fetchEventLocationFieldData() called.');

        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getValue());
        }

        return options;
    }

    @AuraEnabled
    public static List<String> fetchTimeintervals()
    {
        system.debug('fetchTimeintervals() called.');

        List<String> options = new List<String>();
        options.add('0.5 hrs');
        options.add('1 hr');
        options.add('1.5 hr');
        options.add('2 hrs');

        return options;
    }

    @AuraEnabled
    public static String createEventAndRoomRequests(String eventName, DateTime eventStartDate, String eventStartPrepTime, DateTime eventEndDate, String eventEndPrepTime,
                                                    Boolean allowDonations, Boolean acceptDiscounts, Boolean allowDietSpecs, Boolean allowWaitlist, String eventStatus,
                                                    String eventTypes, String eventCategory, String eventLocation)
    {
        system.debug('createEvent&RoomRequests() called.');

        try {
            eventStartPrepTime = (Decimal.valueOf(eventStartPrepTime.split(' ')[0])*-60).format();
            eventEndPrepTime = (Decimal.valueOf(eventEndPrepTime.split(' ')[0])*60).format();

            Event__c tempEventRecord = new Event__c();
            tempEventRecord.Student_Created_Event__c = true;
            tempEventRecord.Name = eventName;
            tempEventRecord.Start_Date__c = eventStartDate;
            tempEventRecord.Event_Setup_Start_Time__c = eventStartDate.addMinutes(Integer.valueOf(eventStartPrepTime));
            tempEventRecord.End_Date__c = eventEndDate;
            tempEventRecord.Event_Setup_End_Time__c = eventEndDate.addMinutes(Integer.valueOf(eventEndPrepTime));
            tempEventRecord.Allow_Donations__c = allowDonations;
            tempEventRecord.Accept_Discount_Code__c = acceptDiscounts;
            tempEventRecord.Allow_Diet_Specification__c = allowDietSpecs;
            tempEventRecord.Allow_Waitlist__c = allowWaitlist;
            tempEventRecord.Status__c = eventStatus;
            tempEventRecord.Type__c = eventTypes;
            tempEventRecord.Category__c = eventCategory;
            tempEventRecord.Event_Location__c = eventLocation;

            insert tempEventRecord;
            system.debug('tempEventRecord = ' + tempEventRecord);

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitted for approval. Kindly Check.');
            req.setObjectId(tempEventRecord.Id);
            Approval.ProcessResult result = Approval.process(req);

            return 'true-'+tempEventRecord.id;
        } catch(Exception e) {
            return 'false- ' + e.getTypeName() + ', Exception: ' + e.getMessage() + ' ; at line number: ' + e.getLineNumber();
        }
    }
}