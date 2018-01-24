@isTest 
private class StudentsEventsManagementController_Test {
    static testMethod void initExecutor()
    {
        StudentsEventsManagement_Controller.fetchCategoryFieldData();
        StudentsEventsManagement_Controller.fetchEventLocationFieldData();
        StudentsEventsManagement_Controller.fetchEventStatusFieldData();
        StudentsEventsManagement_Controller.fetchEventTypeFieldData();
        StudentsEventsManagement_Controller.fetchTimeintervals();
    }
    
    static testMethod void saveMethodExecutor()
    {
        StudentsEventsManagement_Controller.createEventAndRoomRequests('eventName', Date.today(), '1', Date.today(), '1', false, false, false, false, 'eventStatus', 'eventTypes', 'eventCategory', 'eventLocation');
        StudentsEventsManagement_Controller.createEventAndRoomRequests('eventName', Date.today(), '1', Date.today(), '1', false, false, false, false, 'eventStatus', 'eventTypes', 'eventCategory', 'eventLocation');
    }
}