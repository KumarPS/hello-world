({
    init : function(component, event, helper) {
        // Prepare a new record from template
        component.find("eventRecordCreator").getNewRecord(
            "Event__c", // sObject type (entityApiName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newEvent");
                var error = component.get("v.newEventError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
                console.log("Record template initialized: " + rec.sobjectType);
            })
        );

        var action = component.get("c.fetchEventTypeFieldData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
                component.set('v.types', response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                console.log("Callout incomplete.");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

        action = component.get("c.fetchEventLocationFieldData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
                component.set('v.locations', response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                console.log("Callout incomplete.");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

        action = component.get("c.fetchCategoryFieldData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
                component.set('v.categories', response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                console.log("Callout incomplete.");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

        action = component.get("c.fetchTimeintervals");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
                component.set('v.timeIntervals', response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                console.log("Callout incomplete.");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    checkRoomBtnClicked : function(component, event, helper) {
        console.log('checkRoomBtnClicked() called.');
        var nameForm = component.find("nameForm");
        var nameInput = component.find("eventName").get("v.value");
        var nameError = component.find("invalidName");
        var startDateForm = component.find("startDateForm");
        var startDateForm1 = component.find("startDateForm1");
        var startDateInput = component.find("startDate").get("v.value");
        var startDateError = component.find("invalidStartDate");
        var startDateError2 = component.find("invalidStartDate2");
        var startPrepTimeForm = component.find("startPrepTimeForm");
        var startPrepTimeInput = component.find("eventStartPrepTime").get("v.value");
        var startPrepTimeError = component.find("invalidStartPrepTime");
        var endDateForm = component.find("endDateForm");
     
        var endDateInput = component.find("endDate").get("v.value");
        var endDateError = component.find("invalidEndDate");
        var endDateError2 = component.find("invalidEndDate2");
        var endDateError3 = component.find("invalidEndDate3");
        var endPrepTimeForm = component.find("endPrepTimeForm");
        var endPrepTimeInput = component.find("eventEndPrepTime").get("v.value");
        var endPrepTimeError = component.find("invalidEndPrepTime");
        var validationCounter = 0;
        
        
        
         
        
      
        
        if(!nameInput){
            $A.util.addClass(nameForm, 'slds-has-error');
            $A.util.removeClass(nameError, 'slds-hide');
        }
        else{
            $A.util.removeClass(nameForm, 'slds-has-error');
            $A.util.addClass(nameError, 'slds-hide');
            validationCounter++;
        }
        if(!startDateInput){
            $A.util.addClass(startDateForm, 'slds-has-error');
            $A.util.removeClass(startDateError, 'slds-hide');
        }else if(new Date(startDateInput) < new Date()){
            $A.util.addClass(startDateForm, 'slds-has-error');
            $A.util.addClass(startDateError, 'slds-hide');
           $A.util.removeClass(startDateError2, 'slds-hide');
        }
        else{
            $A.util.removeClass(startDateForm, 'slds-has-error');
           $A.util.addClass(startDateError2, 'slds-hide');
             $A.util.addClass(startDateError, 'slds-hide');
            validationCounter++;
        }
       
        if(startPrepTimeInput.split(' ')[0] == '0'){
            $A.util.addClass(startPrepTimeForm, 'slds-has-error');
            $A.util.removeClass(startPrepTimeError, 'slds-hide');
        }
        else{
            $A.util.removeClass(startPrepTimeForm, 'slds-has-error');
            $A.util.addClass(startPrepTimeError, 'slds-hide');
            validationCounter++;
        }
        if(!endDateInput){
            $A.util.addClass(endDateForm, 'slds-has-error');
            $A.util.removeClass(endDateError, 'slds-hide');
        } else if(new Date(endDateInput) < new Date()){
            $A.util.addClass(endDateForm, 'slds-has-error');
            $A.util.addClass(endDateError, 'slds-hide');
            $A.util.removeClass(endDateError3, 'slds-hide');
        }else  if(startDateInput > endDateInput){
            $A.util.addClass(endDateForm, 'slds-has-error');
            $A.util.addClass(endDateError, 'slds-hide');
            $A.util.addClass(endDateError3, 'slds-hide');
            $A.util.removeClass(endDateError2, 'slds-hide');
        }
       
       
        else{
            $A.util.removeClass(endDateForm, 'slds-has-error');
         
            $A.util.addClass(endDateError, 'slds-hide');
            $A.util.addClass(endDateError2, 'slds-hide');
            $A.util.addClass(endDateError3, 'slds-hide');
            validationCounter++;
        }
        if(endPrepTimeInput.split(' ')[0] == '0'){
            $A.util.addClass(endPrepTimeForm, 'slds-has-error');
            $A.util.removeClass(endPrepTimeError, 'slds-hide');
        }
        else{
            $A.util.removeClass(endPrepTimeForm, 'slds-has-error');
            $A.util.addClass(endPrepTimeError, 'slds-hide');
            validationCounter++;
        }
       
        
        if(validationCounter === 6)
            helper.checkRoomBtnHandler(component, event, helper);
    },

    editEventsBtnClicked : function(component, event, helper) {
        console.log('editEventsBtnClicked() called.');
        helper.editEventsBtnHandler(component, event);
    },

    finishBtnClicked : function(component, event, helper) {
    	console.log('finishBtnClicked() called.');
        window.location.href = '..apex/EventManagement_Students';
    	//helper.finishBtnHandler(component, event);	//executed when room availability button is clicked.
    },

    eventsListBtnClicked : function(component, event, helper) {
    	console.log('eventsListBtnClicked() called.');
        window.open("/apex/EventList");
    }
})