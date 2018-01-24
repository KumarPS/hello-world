({
    validateEventForm : function(component) {
         // Show error messages if required fields are blank
        var allValid = component.find('contactField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
            return true;
        }
        else
            return false;
    },

    checkRoomBtnHandler : function(component, event, helper) {
        console.log('checkRoomBtnHandler() called.');

        helper.createEventRecordHandler(component, event);

        var finisheEventCreationBtnContainer = component.find('finisheEventCreationBtnContainer');
        var saveEventAndCheckRoomBtn = component.find('saveEventAndCheckRoomBtn');

        $A.util.addClass(finisheEventCreationBtnContainer, 'slds-show');
        //$A.util.addClass(roomSectionContainer, 'slds-visible');
    },

    createEventRecordHandler : function(component, event) {
        console.log('finishBtnHandler() called.');

        var eventName = component.get('v.eventName');
        var eventStartDate = component.get('v.eventStartDate');
        var eventStartPrepTime = component.get('v.eventStartPrepTime');
        var eventEndDate = component.get('v.eventEndDate');
        var eventEndPrepTime = component.get('v.eventEndPrepTime');
        var allowDonations = component.get('v.allowDonations');
        var acceptDiscounts = component.get('v.acceptDiscounts');
        var allowDietSpecs = component.get('v.allowDietSpecs');
        var allowWaitlist = component.get('v.allowWaitlist');
        var eventStatus = component.get('v.eventStatus');
        var eventTypes = component.get('v.eventTypes');
        var eventCategory = component.get('v.eventCategory');
        var eventLocation = component.get('v.eventLocation');

        var action = component.get("c.createEventAndRoomRequests");
        action.setParams({
            'eventName' : eventName,
            'eventStartDate' : eventStartDate,
            'eventStartPrepTime' : eventStartPrepTime,
            'eventEndDate' : eventEndDate,
            'eventEndPrepTime' : eventEndPrepTime,
            'allowDonations' : false,
            'acceptDiscounts' : false,
            'allowDietSpecs' : allowDietSpecs,
            'allowWaitlist' : false,
            'eventStatus' : eventStatus,
            'eventTypes' : eventTypes,
            'eventCategory' : eventCategory,
            'eventLocation' : eventLocation
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("response.getReturnValue().split('-')[0] = " + response.getReturnValue().split('-')[0]);
                if(response.getReturnValue().split('-')[0] == 'true')
                {
                    component.set('v.eventCreated', true);
                    component.set("v.iFrameURL", '../apex/AvailableRooms?eventId='+response.getReturnValue().split('-')[1]+'');
                    var eventDMLErrorMessageContainer = component.find('eventDMLErrorMessageContainer');
                    $A.util.removeClass(eventDMLErrorMessageContainer, 'slds-show');
                    var eventDMLSuccessMessageContainer = component.find('eventDMLSuccessMessageContainer');
                    $A.util.addClass(eventDMLSuccessMessageContainer, 'slds-show');
                    var eventsDetailsFormContainer = component.find('eventsDetailsFormContainer');
                    $A.util.addClass(eventsDetailsFormContainer, 'eventDataContainerReadOnly');
                    var checkRoomBtn = component.find('checkRoomBtn');
                    $A.util.addClass(checkRoomBtn, 'slds-hide');
                    var roomSectionContainer = component.find('roomSectionContainer');
                    $A.util.addClass(roomSectionContainer, 'slds-visible');
                    var eventListBtn = component.find('eventListBtn');
        			      $A.util.addClass(eventListBtn, 'slds-show');
                    return false;
                }
                else
                {
                    component.set('v.eventCreated', false);
                    var eventDMLErrorMessageContainer = component.find('eventDMLErrorMessageContainer');
                    $A.util.addClass(eventDMLErrorMessageContainer, 'slds-show');
                    return false;
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("Callout incomplete.");
                console.log('response.getReturnValue() = ' + response.getReturnValue());
                component.set('v.eventCreated', false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                        component.set('v.eventCreated', false);
                        console.log('response.getReturnValue() = ' + response.getReturnValue());
                    }
                } else {
                    console.log("Unknown error");
                    component.set('v.eventCreated', false);
                    console.log('response.getReturnValue() = ' + response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action);
    }
})